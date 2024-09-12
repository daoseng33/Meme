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
    
    var description: Observable<String> {
        descriptionRelay.asObservable()
    }
    
    private let randomMemeWebAPI = MemeAPIService()
    private let mediaRelay = BehaviorRelay<(mediaURL: URL?, type: MemeMediaType)>(value: (nil, .image))
    private let descriptionRelay = BehaviorRelay<String>(value: "")
    private let disposeBag = DisposeBag()
    
    // MARK: - Get data
    func loadFirstMemeIfNeeded() {
        if descriptionRelay.value.isEmpty {
            fetchRandomMeme(mediaType: randomMediaType)
        }
    }
    
    func fetchRandomMeme(with keyword: String = "", mediaType: MemeMediaType = .image) {
        randomMemeWebAPI.fetchRandomMeme(with: keyword, mediaType: mediaType, minRating: 8)
            .subscribe(onSuccess: { [weak self] randomMeme in
                guard let self = self else { return }
                let mediaType = getMediaType(with: randomMeme.type)
                mediaRelay.accept((randomMeme.url, mediaType))
                descriptionRelay.accept(randomMeme.description)
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
