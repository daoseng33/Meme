//
//  GridCollectionViewModelProtocol.swift
//  Meme
//
//  Created by DAO on 2024/9/22.
//

import Foundation
import RxSwift
import RxRelay
import RxDataSources

protocol GridCollectionViewModelProtocol {
    var favoriteButtonTappedRelay: PublishRelay<(gridImageType: GridImageType, isFavorite: Bool, index: Int)> { get }
    var shareButtonTappedRelay: PublishRelay<GridImageType> { get }
    var dataSource: RxCollectionViewSectionedAnimatedDataSource<GridSection>? { get set }
    var sectionsRelay: BehaviorRelay<[GridSection]> { get }
    init(gridDatas: [GridData])
    func gridCellViewModel(with index: Int) -> GridCellViewModelProtocol
}
