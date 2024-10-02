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
    case meme(url: URL, description: String, mediaType: MemeMediaType)
    case joke(joke: String)
    case gif(url: URL)
}

protocol GeneralContentCellViewModelProtocol {
    var content: GeneralContentCellType { get }
    var shareButtonTappedRelay: PublishRelay<GeneralContentCellType> { get }
    var imageTappedRelay: PublishRelay<URL> { get }
    init(content: GeneralContentCellType)
}
