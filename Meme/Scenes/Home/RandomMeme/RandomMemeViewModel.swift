//
//  RandomMemeViewModel.swift
//  Meme
//
//  Created by DAO on 2024/9/10.
//

import Foundation
import HumorAPIService
import HumorDataModel
import RxRelay
import RxSwift

final class RandomMemeViewModel: RandomMemeViewModelProtocol {
    var loadingState: LoadingState {
        return loadingStateRelay.value
    }
    
    var loadingStateObservable: Observable<LoadingState> {
        return loadingStateRelay.asObservable()
    }
    
    // MARK: - Properties
    var mediaObservable: Observable<(mediaURL: URL?, type: MemeMediaType)> {
        mediaRelay.asObservable()
    }
    
    var media: (mediaURL: URL?, type: MemeMediaType) {
        mediaRelay.value
    }
    
    var descriptionObservable: Observable<String> {
        descriptionRelay.asObservable()
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

                    let mediaType = getMediaType(with: randomMeme.type)
                    mediaRelay.accept((randomMeme.url, mediaType))
                    descriptionRelay.accept(randomMeme.memeDescription)
                    
                case .failure(let error):
                    let noResultImageURL = Utility.getImageURL(named: Asset.Global.noResult.name)
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
    
    // MARK: - Utility
    /// type string example: "video/mp4", "image/jpeg"
    private func getMediaType(with typeString: String) -> MemeMediaType {
        // get "video" or "image"
        let components = typeString.components(separatedBy: "/")
        guard let firstPart = components.first,
                let type = MemeMediaType(rawValue: firstPart) else {
            return .image
        }
        
        return type
    }
}
