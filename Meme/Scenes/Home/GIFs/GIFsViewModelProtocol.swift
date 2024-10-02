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

protocol GIFsViewModelProtocol: LoadingStateProtocol {
    var keywordRelay: BehaviorRelay<String?> { get }
    var gridCollectionViewModel: GridCollectionViewModelProtocol { get }
    var imageDatas: [ImageData] { get }
    func loadFirstDataIfNeeded()
    func fetchGIFs()
    func saveSelectedImageData(with index: Int)
}
