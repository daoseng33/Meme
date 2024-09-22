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
    private let imageDataRelay: BehaviorRelay<(GridImageType)>
    
    var title: Observable<String?> {
        return titleRelay.asObservable()
    }
    
    var imageData: Observable<(GridImageType)> {
        return imageDataRelay.asObservable()
    }
    
    // MARK: - Init
    init(gridData: GridData) {
        titleRelay = BehaviorRelay<String?>(value: gridData.title)
        imageDataRelay = BehaviorRelay<(GridImageType)>(value: (gridData.imageType))
    }
}
