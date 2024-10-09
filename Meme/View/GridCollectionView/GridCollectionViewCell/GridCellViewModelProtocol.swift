//
//  GridCellViewModelProtocol.swift
//  Meme
//
//  Created by DAO on 2024/9/22.
//

import Foundation
import RxSwift
import RxRelay

protocol GridCellViewModelProtocol: FavoriteStateProtocol {
    var titleObservable: Observable<String?> { get }
    var imageTypeObservable: Observable<GridImageType> { get }
    var currentImageType: GridImageType { get }
    var favoriteButtonTappedRelay: PublishRelay<(gridImageType: GridImageType, isFavorite: Bool)> { get }
    var shareButtonTappedRelay: PublishRelay<GridImageType> { get }
    init(gridData: GridData)
}
