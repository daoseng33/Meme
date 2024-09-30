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
import RxCocoa
import UIKit

protocol RandomMemeViewModelProtocol: LoadingStateProtocol {
    func loadFirstMemeIfNeeded()
    func fetchRandomMeme()
    var mediaDriver: Driver<(mediaURL: URL?, type: MemeMediaType)> { get }
    var media: (mediaURL: URL?, type: MemeMediaType) { get }
    var keywordRelay: BehaviorRelay<String?> { get }
    var descriptionDriver: Driver<String> { get }
    var description: String { get }
}
