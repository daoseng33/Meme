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
    
    var loadingStateObservable: Observable<LoadingState> {
        return loadingStateRelay.asObservable()
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
    
    private var randomMediaType: MemeMediaType {
        return MemeMediaType.allCases.randomElement() ?? .image
    }
    private let randomMemeWebAPI: MemeAPIServiceProtocol
    private let mediaRelay = BehaviorRelay<(mediaURL: URL?, type: MemeMediaType)>(value: (nil, .image))
    private let descriptionRelay = BehaviorRelay<String>(value: "")
    private let loadingStateRelay = BehaviorRelay<LoadingState>(value: .initial)
    private let disposeBag = DisposeBag()
    
    // MARK: - Init
    init(webService: MemeAPIServiceProtocol) {
        randomMemeWebAPI = webService
    }
    
    // MARK: - Get data
    func loadFirstMemeIfNeeded() {
        if loadingState == .initial {
            fetchRandomMeme()
        }
    }

    func fetchRandomMeme() {
        loadingStateRelay.accept(.loading)
        
        var keyword: String = ""
        if let value: String = keywordRelay.value {
            keyword = value
        }
        randomMemeWebAPI.fetchRandomMeme(with: keyword, mediaType: randomMediaType, minRating: 8)
            .subscribe(onSuccess: { [weak self] result in
                guard let self = self else { return }
                
                switch result {
                case .success(let randomMeme):
                    DispatchQueue.main.async {
                        DataStorageManager.shared.save(randomMeme)
                    }

                    let mediaType = Utility.getMediaType(with: randomMeme.type)
                    mediaRelay.accept((randomMeme.url, mediaType))
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
}
