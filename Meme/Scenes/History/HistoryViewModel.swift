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

final class HistoryViewModel: HistoryViewModelProtocol {
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    private var generalContentCellViewModels: [GeneralContentCellViewModelProtocol] = []
    private let reloadDataRelay = PublishRelay<Void>()
    private let memeDatasRelay = PublishRelay<[RandomMeme]>()
    private let jokeDatasRelay = PublishRelay<[RandomJoke]>()
    private let imageDatasRelay = PublishRelay<[ImageData]>()
    
    var reloadDataSignal: Signal<Void> {
        reloadDataRelay.asSignal()
    }
    
    // MARK: - Init
    init() {
        setupObserver()
    }

    // MARK: - SetupObserver
    private func setupObserver() {
        Observable.combineLatest(memeDatasRelay, jokeDatasRelay, imageDatasRelay)
            .withUnretained(self)
            .subscribe(onNext: { (self, combined) in
                let (memes, jokes, images) = combined
                
                let memeCellViewModels = memes
                    .filter{ $0.url != nil }
                    .map({ meme in
                        let content = GeneralContentCellType.meme(url: meme.url!, description: meme.memeDescription, mediaType: Utility.getMediaType(with: meme.type))
                        let cellViewModel = GeneralContentCellViewModel(content: content, createdAt: meme.createdAt)
                        return cellViewModel
                    })
                
                let jokeCellViewModels = jokes
                    .map({ joke in
                        let content = GeneralContentCellType.joke(joke: joke.joke)
                        let cellViewModel = GeneralContentCellViewModel(content: content, createdAt: joke.createdAt)
                        return cellViewModel
                    })
                
                let imageCellViewModels = images
                    .filter{ $0.url != nil }
                    .map({ imageData in
                        let content = GeneralContentCellType.gif(url: imageData.url!)
                        let cellViewModel = GeneralContentCellViewModel(content: content, createdAt: imageData.createdAt)
                        return cellViewModel
                    })
                
                self.generalContentCellViewModels = (memeCellViewModels + jokeCellViewModels + imageCellViewModels).sorted(by: {
                    $0.createdAt > $1.createdAt
                })
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
        generalContentCellViewModels[indexPath.row]
    }
    
    func getRowsCount(with section: Int) -> Int {
        generalContentCellViewModels.count
    }
}
