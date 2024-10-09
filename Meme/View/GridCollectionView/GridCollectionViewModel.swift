//
//  GridCollectionViewModel.swift
//  Meme
//
//  Created by DAO on 2024/9/9.
//

import UIKit
import RxRelay
import RxSwift

final class GridCollectionViewModel: GridCollectionViewModelProtocol {
    // MARK: - Properties
    private let gridDatasSubject: BehaviorSubject<[GridData]>
    let favoriteButtonTappedRelay = PublishRelay<(gridImageType: GridImageType, isFavorite: Bool)>()
    let shareButtonTappedRelay = PublishRelay<GridImageType>()

    var gridDatasObserver: AnyObserver<[GridData]> {
        gridDatasSubject.asObserver()
    }
    
    var numberOfItems: Int {
        return (try? gridDatasSubject.value().count) ?? 0
    }
    
    var shouldReloadData: Observable<Void> {
        return gridDatasSubject
            .map { _ in Void() }
            .asObservable()
    }
    
    // MARK: - Init
    init(gridDatas: [GridData]) {
        gridDatasSubject = BehaviorSubject<[GridData]>(value: gridDatas)
    }
    
    // MARK: - Configures
    func gridCellViewModel(with index: Int) -> GridCellViewModelProtocol {
        guard let gridDatas = try? gridDatasSubject.value() else {
            let noResultGridData = GridData(title: nil, imageType: .static(image: Asset.Global.imageNotFound.image), isFavorite: false)
            return GridCellViewModel(gridData: noResultGridData)
        }
        let gridData = gridDatas[index]
        let cellViewModel = GridCellViewModel(gridData: gridData)
        return cellViewModel
    }
}
