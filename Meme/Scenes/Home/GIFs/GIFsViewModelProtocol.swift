//
//  GIFsViewModelProtocol.swift
//  Meme
//
//  Created by DAO on 2024/9/22.
//

import Foundation
import RxSwift
import RxRelay
import HumorAPIService

protocol GIFsViewModelProtocol: FetchDataProtocol, LoadingStateProtocol, AdHandlerProtocol {
    var inAppReviewHandler: InAppReviewHandler { get }
    var keywordRelay: BehaviorRelay<String?> { get }
    var gridCollectionViewModel: GridCollectionViewModelProtocol { get }
    var imageDatas: [ImageData] { get }
    func saveSelectedImageData(with index: Int)
    func getImageType(with index: Int) -> GridImageType
}
