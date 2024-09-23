//
//  GridCellViewModel.swift
//  Meme
//
//  Created by DAO on 2024/9/9.
//

import UIKit
import RxSwift
import RxRelay

final class GridCellViewModel: GridCellViewModelProtocol {
    // MARK: - Properties
    private let titleRelay: BehaviorRelay<String?>
    private let imageTypeRelay: BehaviorRelay<GridImageType>
    
    var currentImageType: GridImageType {
        imageTypeRelay.value
    }
    
    var title: Observable<String?> {
        titleRelay.asObservable()
    }
    
    var imageType: Observable<(GridImageType)> {
        imageTypeRelay.asObservable()
    }
    
    // MARK: - Init
    init(gridData: GridData) {
        titleRelay = BehaviorRelay<String?>(value: gridData.title)
        imageTypeRelay = BehaviorRelay<(GridImageType)>(value: (gridData.imageType))
    }
}
