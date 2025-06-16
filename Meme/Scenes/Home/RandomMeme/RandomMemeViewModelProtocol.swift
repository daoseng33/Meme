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
import Combine

protocol MemeDisplayProtocol {
    var mediaPublisher: AnyPublisher<(mediaURL: URL?, type: MemeMediaType), Never> { get }
    var media: (mediaURL: URL?, type: MemeMediaType) { get }
    var descriptionPublisher: AnyPublisher<String, Never> { get }
    var description: String { get }
}

protocol MemeDataFetchingProtocol {
    func refreshData()
    func fetchData()
    func fetchUpVote()
    func fetchDownVote()
}

protocol MemeInteractionProtocol {
    var keywordSubject: CurrentValueSubject<String?, Never> { get }
    var shareButtonTappedSubject: PassthroughSubject<Void, Never> { get }
    var inAppReviewHandler: InAppReviewHandler { get }
}

protocol RandomMemeViewModelProtocol: MemeDisplayProtocol, MemeDataFetchingProtocol, MemeInteractionProtocol, LoadingStateProtocol, AdHandlerProtocol, FavoriteStateProtocol { }
