//
//  RandomMemeViewModelProtocol.swift
//  Meme
//
//  Created by DAO on 2024/9/10.
//

import Foundation
import HumorAPIService
import RxSwift
import RxRelay
import UIKit

protocol RandomMemeViewModelProtocol: LoadingStateProtocol {
    func loadFirstMemeIfNeeded()
    func fetchRandomMeme()
    var mediaObservable: Observable<(mediaURL: URL?, type: MemeMediaType)> { get }
    var media: (mediaURL: URL?, type: MemeMediaType) { get }
    var keywordRelay: BehaviorRelay<String?> { get }
    var descriptionObservable: Observable<String> { get }
    var description: String { get }
}
