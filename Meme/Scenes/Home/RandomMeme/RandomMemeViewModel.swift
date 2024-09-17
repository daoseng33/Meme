//
//  RandomMemeViewModel.swift
//  Meme
//
//  Created by DAO on 2024/9/10.
//

import Foundation
import WebAPI
import RxRelay
import RxSwift

final class RandomMemeViewModel: RandomMemeViewModelProtocol {
    // MARK: - Properties
    var media: Observable<(mediaURL: URL?, type: MemeMediaType)> {
        mediaRelay.asObservable()
    }
    
    var keyword: Observable<String?> {
        keywordSubject.asObservable()
    }
    
    var keywordObserver: AnyObserver<String?> {
        keywordSubject.asObserver()
    }
    
    var description: Observable<String> {
        descriptionRelay.asObservable()
    }
    
    var isLoading: Bool {
        isLoadingRely.value
    }
    
    private let randomMemeWebAPI: MemeAPIServiceProtocol
    private let mediaRelay = BehaviorRelay<(mediaURL: URL?, type: MemeMediaType)>(value: (nil, .image))
    private let keywordSubject = BehaviorSubject<String?>(value: nil)
    private let descriptionRelay = BehaviorRelay<String>(value: "")
    private let isLoadingRely = BehaviorRelay<Bool>(value: false)
    private let disposeBag = DisposeBag()
    
    // MARK: - Init
    init(webService: MemeAPIServiceProtocol = MemeAPIService()) {
        randomMemeWebAPI = webService
    }
    
    // MARK: - Get data
    func loadFirstMemeIfNeeded() {
        if descriptionRelay.value.isEmpty {
            fetchRandomMeme()
        }
    }

    func fetchRandomMeme() {
        isLoadingRely.accept(true)
        
        var keyword: String = ""
        if let value: String = try? keywordSubject.value() {
            keyword = value
        }
        randomMemeWebAPI.fetchRandomMeme(with: keyword, mediaType: randomMediaType, minRating: 8)
            .subscribe(onSuccess: { [weak self] result in
                guard let self = self else { return }
                
                self.isLoadingRely.accept(false)
                
                switch result {
                case .success(let randomMeme):
                    let mediaType = getMediaType(with: randomMeme.type)
                    mediaRelay.accept((randomMeme.url, mediaType))
                    descriptionRelay.accept(randomMeme.description)
                    
                case .failure(let error):
                    let noResultImageURL = Utility.getImageURL(named: R.image.no_result.name)
                    mediaRelay.accept((noResultImageURL, .image))
                    descriptionRelay.accept(error.message)
                }
            }, onFailure: { [weak self] error in
                guard let self = self else { return }
                self.isLoadingRely.accept(false)
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
