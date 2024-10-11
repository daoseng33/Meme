//
//  GeneralContentViewModel.swift
//  Meme
//
//  Created by DAO on 2024/10/8.
//

import Foundation
import RxSwift
import RxRelay
import RxCocoa
import HumorAPIService
import RealmSwift

class GeneralContentViewModel: @preconcurrency GeneralContentViewModelProtocol {
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    private let reloadDataRelay = PublishRelay<Void>()
    private let memeDatasRelay = PublishRelay<[RandomMeme]>()
    private let jokeDatasRelay = PublishRelay<[RandomJoke]>()
    private let imageDatasRelay = PublishRelay<[ImageData]>()
    private var sectionTypeDict = IndexedDictionary<DateCategory, [GeneralContentCellViewModelProtocol]>()
    let predicate: NSPredicate?
    
    let filterContainerViewModel: FilterContainerViewModelProtocol = FilterContainerViewModel()
    
    var reloadDataSignal: Signal<Void> {
        reloadDataRelay.asSignal()
    }
    
    // MARK: - Init
    required init(predicate: NSPredicate? = nil) {
        self.predicate = predicate
        setupObserver()
    }

    // MARK: - SetupObserver
    private func setupObserver() {
        Observable.combineLatest(memeDatasRelay,
                                 jokeDatasRelay,
                                 imageDatasRelay,
                                 filterContainerViewModel.selectedDateRelay,
                                 filterContainerViewModel.selectedCategoryRelay)
        .debounce(.milliseconds(100), scheduler: MainScheduler.instance)
        .withUnretained(self)
        .subscribe(onNext: { (self, combined) in
            self.sectionTypeDict.reset()
            
            let (memes, jokes, images, date, category) = combined
            
            let memeCellViewModels = memes
                .filter{ $0.url != nil }
                .map({ meme in
                    let content = GeneralContentCellType.meme(meme: meme)
                    let cellViewModel = GeneralContentCellViewModel(content: content)
                    return cellViewModel
                })
            
            let jokeCellViewModels = jokes
                .map({ joke in
                    let content = GeneralContentCellType.joke(joke: joke)
                    let cellViewModel = GeneralContentCellViewModel(content: content)
                    return cellViewModel
                })
            
            let imageCellViewModels = images
                .filter{ $0.url != nil }
                .map({ imageData in
                    let content = GeneralContentCellType.gif(imageData: imageData)
                    let cellViewModel = GeneralContentCellViewModel(content: content)
                    return cellViewModel
                })
            
            var cellViewModels: [GeneralContentCellViewModelProtocol]
            
            switch category {
            case .all:
                cellViewModels = memeCellViewModels + jokeCellViewModels + imageCellViewModels
                
            case .meme:
                cellViewModels = memeCellViewModels
                
            case .joke:
                cellViewModels = jokeCellViewModels
                
            case .gifs:
                cellViewModels = imageCellViewModels
            }
            
            switch date {
            case .newest:
                cellViewModels.sort {
                    $0.createdAt > $1.createdAt
                }
                
            case .oldest:
                cellViewModels.sort {
                    $0.createdAt < $1.createdAt
                }
            }
            
            cellViewModels.forEach { cellViewModel in
                let dateCategory = self.categorizeDate(cellViewModel.createdAt)
                
                if self.sectionTypeDict[dateCategory] == nil {
                    self.sectionTypeDict[dateCategory] = [cellViewModel]
                } else {
                    self.sectionTypeDict[dateCategory]?.append(cellViewModel)
                }
            }
            
            self.reloadDataRelay.accept(())
        })
        .disposed(by: disposeBag)
    }
    
    // MARK: - Getter
    @MainActor func getLocalDatas() {
        let memeLocalDatas = DataStorageManager.shared.fetch(RandomMeme.self, predicate: self.predicate)
        self.memeDatasRelay.accept(memeLocalDatas)
        
        let jokeLocalDatas = DataStorageManager.shared.fetch(RandomJoke.self, predicate: self.predicate)
        self.jokeDatasRelay.accept(jokeLocalDatas)
        
        let imageLocalDatas = DataStorageManager.shared.fetch(ImageData.self, predicate: self.predicate)
        self.imageDatasRelay.accept(imageLocalDatas)
    }
    
    func getCellViewModel(at indexPath: IndexPath) -> GeneralContentCellViewModelProtocol? {
        switch indexPath.section {
        case sectionTypeDict.index(forKey: .today):
            return sectionTypeDict[.today]![indexPath.row]
            
        case sectionTypeDict.index(forKey: .yesterday):
            return sectionTypeDict[.yesterday]![indexPath.row]
            
        case sectionTypeDict.index(forKey: .thisWeek):
            return sectionTypeDict[.thisWeek]![indexPath.row]
            
        case sectionTypeDict.index(forKey: .whileAgo):
            return sectionTypeDict[.whileAgo]![indexPath.row]
            
        default:
            print("Error: Unknown section type")
            return nil
        }
    }
    
    func getNumberOfSections() -> Int {
        sectionTypeDict.keys.count
    }
    
    func getRowsCount(with section: Int) -> Int {
        switch section {
        case sectionTypeDict.index(forKey: .today):
            return sectionTypeDict[.today]!.count
            
        case sectionTypeDict.index(forKey: .yesterday):
            return sectionTypeDict[.yesterday]!.count
            
        case sectionTypeDict.index(forKey: .thisWeek):
            return sectionTypeDict[.thisWeek]!.count
            
        case sectionTypeDict.index(forKey: .whileAgo):
            return sectionTypeDict[.whileAgo]!.count
            
        default:
            print("Error: Unknown section type")
            return 0
        }
    }
    
    func getSectionTitle(at section: Int) -> String? {
        switch section {
        case sectionTypeDict.index(forKey: .today):
            return DateCategory.today.rawValue.localized()
            
        case sectionTypeDict.index(forKey: .yesterday):
            return DateCategory.yesterday.rawValue.localized()
            
        case sectionTypeDict.index(forKey: .thisWeek):
            return DateCategory.thisWeek.rawValue.localized()
            
        case sectionTypeDict.index(forKey: .whileAgo):
            return DateCategory.whileAgo.rawValue.localized()
            
        default:
            print("Error: Unknown section type")
            return nil
        }
    }
    
    // MARL: - Date cateogory
    enum DateCategory: String {
        case today = "Today"
        case yesterday = "Yesterday"
        case thisWeek = "Within last 7 days"
        case whileAgo = "A while ago"
    }

    private func categorizeDate(_ date: Date) -> DateCategory {
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.day], from: date, to: now)
        
        if calendar.isDateInToday(date) {
            return .today
        } else if calendar.isDateInYesterday(date) {
            return .yesterday
        } else if let days = components.day, days < 7 {
            return .thisWeek
        } else {
            return .whileAgo
        }
    }
}
