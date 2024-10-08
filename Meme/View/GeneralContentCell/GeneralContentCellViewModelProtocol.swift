//
//  GeneralContentCellViewModelProtocol.swift
//  Meme
//
//  Created by DAO on 2024/10/1.
//

import Foundation
import HumorAPIService
import RxRelay

enum GeneralContentCellType {
    case meme(meme: RandomMeme)
    case joke(joke: RandomJoke)
    case gif(imageData: ImageData)
}

protocol GeneralContentCellViewModelProtocol {
    var createdAt: Date { get }
    var content: GeneralContentCellType { get }
    var shareButtonTappedRelay: PublishRelay<GeneralContentCellType> { get }
    var imageTappedRelay: PublishRelay<URL> { get }
    var isFavoriteRelay: BehaviorRelay<Bool> { get }
    func toggleIsFavorite()
    init(content: GeneralContentCellType)
}

extension GeneralContentCellViewModelProtocol {
    func toggleIsFavorite() {
        isFavoriteRelay.accept(!isFavoriteRelay.value)
    }
}
