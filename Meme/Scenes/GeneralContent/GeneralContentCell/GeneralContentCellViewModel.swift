//
//  GeneralContentCellViewModel.swift
//  Meme
//
//  Created by DAO on 2024/10/1.
//

import Foundation
import RxSwift
import RxRelay
import HumorAPIService

final class GeneralContentCellViewModel: GeneralContentCellViewModelProtocol {
    // MARK: - Properties
    var content: GeneralContentCellType
    var shareButtonTappedRelay = PublishRelay<GeneralContentCellType>()
    var imageTappedRelay = PublishRelay<URL>()
    var isFavoriteRelay: BehaviorRelay<Bool>
    let createdAt: Date
    private let disposeBag = DisposeBag()
    private let memeWebService = MemeAPIService()
    private let jokeWebService = JokeAPIService()
    private let remoteConfigHandler = RemoteConfigHandler()
    
    // MARK: - Init
    init(content: GeneralContentCellType) {
        self.content = content
        switch content {
        case .meme(let meme):
            isFavoriteRelay = BehaviorRelay(value: meme.isFavorite)
            createdAt = meme.createdAt
            
        case .joke(let joke):
            isFavoriteRelay = BehaviorRelay(value: joke.isFavorite)
            createdAt = joke.createdAt
            
        case .gif(let imageData):
            isFavoriteRelay = BehaviorRelay(value: imageData.isFavorite)
            createdAt = imageData.createdAt
        }
        
        setupObservable()
    }
    
    private func setupObservable() {
        isFavoriteRelay
            .skip(1)
            .withUnretained(self)
            .subscribe(onNext: { (self, isFavorite) in
                DispatchQueue.main.async {
                    switch self.content {
                    case .meme(let meme):
                        DataStorageManager.shared.updateAsync(meme, with: [Constant.Key.isFavorite: isFavorite])
                        if self.remoteConfigHandler.getBool(forKey: .enableContentVoteApi) {
                            if isFavorite {
                                _ = self.memeWebService.fetchUpVoteMeme(with: meme.id).subscribe()
                            } else {
                                _ = self.memeWebService.fetchDownVoteMeme(with: meme.id).subscribe()
                            }
                        }
                        
                        
                    case .joke(let joke):
                        DataStorageManager.shared.updateAsync(joke, with: [Constant.Key.isFavorite: isFavorite])
                        if self.remoteConfigHandler.getBool(forKey: .enableContentVoteApi) {
                            if isFavorite {
                                _ = self.jokeWebService.fetchUpVoteJoke(with: joke.id).subscribe()
                            } else {
                                _ = self.jokeWebService.fetchDownVoteJoke(with: joke.id).subscribe()
                            }
                        }
                        
                    case .gif(let imageData):
                        DataStorageManager.shared.updateAsync(imageData, with: [Constant.Key.isFavorite: isFavorite])
                    }
                }
            })
            .disposed(by: disposeBag)
    }
}
