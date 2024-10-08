//
//  HistoryViewModel.swift
//  Meme
//
//  Created by DAO on 2024/10/2.
//

import Foundation
import RxSwift
import RxRelay
import RxCocoa
import HumorAPIService
import RealmSwift

final class HistoryViewModel: GeneralContentViewModelProtocol {
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    private let reloadDataRelay = PublishRelay<Void>()
    private let memeDatasRelay = PublishRelay<[RandomMeme]>()
    private let jokeDatasRelay = PublishRelay<[RandomJoke]>()
    private let imageDatasRelay = PublishRelay<[ImageData]>()
    private var sectionTypeDict = IndexedDictionary<DateCategory, [GeneralContentCellViewModelProtocol]>()
    
    let filterContainerViewModel: FilterContainerViewModelProtocol = FilterContainerViewModel()
    
    var reloadDataSignal: Signal<Void> {
        reloadDataRelay.asSignal()
    }
    
    // MARK: - Init
    init() {
        setupObserver()
    }

    // MARK: - SetupObserver
    private func setupObserver() {
        Observable.combineLatest(memeDatasRelay,
                                 jokeDatasRelay,
                                 imageDatasRelay,
                                 filterContainerViewModel.selectedDateRelay,
                                 filterContainerViewModel.selectedCategoryRelay)
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
    func getLocalDatas() {
        DispatchQueue.main.async {
            DataStorageManager.shared.fetch(RandomMeme.self) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let datas):
                    self.memeDatasRelay.accept(datas)
                    
                case .failure(let failure):
                    print(failure.localizedDescription)
                }
            }
            
            DataStorageManager.shared.fetch(RandomJoke.self) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let datas):
                    self.jokeDatasRelay.accept(datas)
                    
                case .failure(let failure):
                    print(failure.localizedDescription)
                }
            }
            
            DataStorageManager.shared.fetch(ImageData.self) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let datas):
                    self.imageDatasRelay.accept(datas)
                    
                case .failure(let failure):
                    print(failure.localizedDescription)
                }
            }
        }
    }
    
    func getCellViewModel(at indexPath: IndexPath) -> GeneralContentCellViewModelProtocol {
        switch indexPath.section {
        case sectionTypeDict.index(forKey: .today):
            sectionTypeDict[.today]![indexPath.row]
            
        case sectionTypeDict.index(forKey: .yesterday):
            sectionTypeDict[.yesterday]![indexPath.row]
            
        case sectionTypeDict.index(forKey: .thisWeek):
            sectionTypeDict[.thisWeek]![indexPath.row]
            
        case sectionTypeDict.index(forKey: .whileAgo):
            sectionTypeDict[.whileAgo]![indexPath.row]
            
        default:
            fatalError("Unknown section type")
        }
    }
    
    func getNumberOfSections() -> Int {
        sectionTypeDict.keys.count
    }
    
    func getRowsCount(with section: Int) -> Int {
        switch section {
        case sectionTypeDict.index(forKey: .today):
            sectionTypeDict[.today]!.count
            
        case sectionTypeDict.index(forKey: .yesterday):
            sectionTypeDict[.yesterday]!.count
            
        case sectionTypeDict.index(forKey: .thisWeek):
            sectionTypeDict[.thisWeek]!.count
            
        case sectionTypeDict.index(forKey: .whileAgo):
            sectionTypeDict[.whileAgo]!.count
            
        default:
            fatalError("Unknown section type")
        }
    }
    
    func getSectionTitle(at section: Int) -> String? {
        switch section {
        case sectionTypeDict.index(forKey: .today):
            DateCategory.today.rawValue.localized()
            
        case sectionTypeDict.index(forKey: .yesterday):
            DateCategory.yesterday.rawValue.localized()
            
        case sectionTypeDict.index(forKey: .thisWeek):
            DateCategory.thisWeek.rawValue.localized()
            
        case sectionTypeDict.index(forKey: .whileAgo):
            DateCategory.whileAgo.rawValue.localized()
            
        default:
            fatalError("Unknown section type")
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
