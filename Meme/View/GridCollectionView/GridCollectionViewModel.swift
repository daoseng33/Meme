//
//  GridCollectionViewModel.swift
//  Meme
//
//  Created by DAO on 2024/9/9.
//

import UIKit
import RxRelay
import RxSwift

final class GridCollectionViewModel {
    // MARK: - Properties
    private let gridDatasRelay: BehaviorRelay<[GridData]>
    
    var numberOfItems: Int {
        return gridDatasRelay.value.count
    }
    
    var shouldReloadData: Observable<Void> {
        return gridDatasRelay
            .map { _ in Void() }
            .asObservable()
    }
    
    // MARK: - Init
    init(gridDatas: [GridData]) {
        self.gridDatasRelay = BehaviorRelay<[GridData]>(value: gridDatas)
    }
    
    // MARK: - Configures
    func gridCellViewModel(with index: Int) -> GridCollectionViewCellViewModel {
        let gridData = gridDatasRelay.value[index]
        let cellViewModel = GridCollectionViewCellViewModel(gridData: gridData)
        return cellViewModel
    }
}
