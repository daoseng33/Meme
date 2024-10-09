//
//  GridCollectionViewModelProtocol.swift
//  Meme
//
//  Created by DAO on 2024/9/22.
//

import Foundation
import RxSwift
import RxRelay

protocol GridCollectionViewModelProtocol {
    var numberOfItems: Int { get }
    var gridDatasObserver: AnyObserver<[GridData]> { get }
    var shouldReloadData: Observable<Void> { get }
    var favoriteButtonTappedRelay: PublishRelay<(gridImageType: GridImageType, isFavorite: Bool)> { get }
    var shareButtonTappedRelay: PublishRelay<GridImageType> { get }
    init(gridDatas: [GridData])
    func gridCellViewModel(with index: Int) -> GridCellViewModelProtocol
}
