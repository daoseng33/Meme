//
//  RandomMemeViewModel.swift
//  Meme
//
//  Created by DAO on 2024/9/10.
//

import Foundation
import HumorAPIService
import RxRelay
import RxCocoa
import RxSwift

final class RandomMemeViewModel: RandomMemeViewModelProtocol {
    var loadingState: LoadingState {
        return loadingStateRelay.value
    }
    
    var loadingStateDriver: Driver<LoadingState> {
        return loadingStateRelay.asDriver()
    }
    
    // MARK: - Properties
    var mediaDriver: Driver<(mediaURL: URL?, type: MemeMediaType)> {
        mediaRelay.asDriver().filter { $0.mediaURL != nil }
    }
    
    var media: (mediaURL: URL?, type: MemeMediaType) {
        mediaRelay.value
    }
    
    var descriptionDriver: Driver<String> {
        descriptionRelay.asDriver()
    }
    
    var description: String {
        descriptionRelay.value
    }
    
    let keywordRelay = BehaviorRelay<String?>(value: nil)
    
    let isFavoriteRelay = BehaviorRelay<Bool>(value: false)
    
    private var randomMediaType: MemeMediaType {
        return MemeMediaType.allCases.randomElement() ?? .image
    }
    private let randomMemeWebAPI: MemeAPIServiceProtocol
    private let mediaRelay = BehaviorRelay<(mediaURL: URL?, type: MemeMediaType)>(value: (nil, .image))
    private let descriptionRelay = BehaviorRelay<String>(value: "")
    private let loadingStateRelay = BehaviorRelay<LoadingState>(value: .initial)
    private let disposeBag = DisposeBag()
    private var currentMeme: RandomMeme?
    
    // MARK: - Init
    init(webService: MemeAPIServiceProtocol) {
        randomMemeWebAPI = webService
        setupObservable()
    }
    
    // MARK: - Get data
    func refreshData() {
        if loadingState == .initial {
            fetchData()
        } else if let currentMeme = currentMeme {
            DispatchQueue.main.async {
                if let localMeme = DataStorageManager.shared.fetch(RandomMeme.self, primaryKey: currentMeme.id) {
                    self.isFavoriteRelay.accept(localMeme.isFavorite)
                }
            }
        }
    }

    func fetchData() {
        loadingStateRelay.accept(.loading)
        
        var keyword: String = ""
        if let value: String = keywordRelay.value {
            keyword = value
        }
        randomMemeWebAPI.fetchRandomMeme(with: keyword, mediaType: randomMediaType, minRating: 9)
            .subscribe(onSuccess: { [weak self] result in
                guard let self = self else { return }
                
                switch result {
                case .success(let randomMeme):
                    currentMeme = randomMeme
                    
                    DispatchQueue.main.async {
                        DataStorageManager.shared.saveAsync(randomMeme)
                    }
                    
                    self.isFavoriteRelay.accept(randomMeme.isFavorite)
                    mediaRelay.accept((randomMeme.url, randomMeme.mediaType))
                    descriptionRelay.accept(randomMeme.memeDescription)
                    
                case .failure(let error):
                    let noResultImageURL = Utility.getImageURL(named: Asset.Global.imageNotFound.name)
                    mediaRelay.accept((noResultImageURL, .image))
                    descriptionRelay.accept(error.message)
                }
                
                self.loadingStateRelay.accept(.success)
            }, onFailure: { [weak self] error in
                guard let self = self else { return }
                self.loadingStateRelay.accept(.failure(error: error))
            })
            .disposed(by: disposeBag)
    }
    
    private func setupObservable() {
        isFavoriteRelay
            .withUnretained(self)
            .subscribe(onNext: { (self, isFavorite) in
                DispatchQueue.main.async {
                    guard let currentMeme = self.currentMeme else {
                        return
                    }
                    
                    DataStorageManager.shared.updateAsync(currentMeme, with: [Constant.Key.isFavorite: isFavorite])
                }
            })
            .disposed(by: disposeBag)
    }
}
