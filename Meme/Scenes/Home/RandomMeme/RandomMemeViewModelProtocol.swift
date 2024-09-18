//
//  RandomMemeViewModelProtocol.swift
//  Meme
//
//  Created by DAO on 2024/9/10.
//

import Foundation
import WebAPI
import RxSwift
import UIKit

protocol RandomMemeViewModelProtocol: LoadingStateProtocol {
    func loadFirstMemeIfNeeded()
    func fetchRandomMeme()
    var media: Observable<(mediaURL: URL?, type: MemeMediaType)> { get }
    var keyword: Observable<String?> { get }
    var keywordObserver: AnyObserver<String?> { get }
    var description: Observable<String> { get }
    var randomMediaType: MemeMediaType { get }
}

extension RandomMemeViewModelProtocol {
    var randomMediaType: MemeMediaType {
        return MemeMediaType.allCases.randomElement() ?? .image
    }
}
