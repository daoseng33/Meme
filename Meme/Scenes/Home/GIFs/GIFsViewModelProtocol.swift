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

protocol GIFsViewModelProtocol: FetchDataProtocol, LoadingStateProtocol {
    var keywordRelay: BehaviorRelay<String?> { get }
    var gridCollectionViewModel: GridCollectionViewModelProtocol { get }
    var imageDatas: [ImageData] { get }
    func saveSelectedImageData(with index: Int, isFavorite: Bool)
}
