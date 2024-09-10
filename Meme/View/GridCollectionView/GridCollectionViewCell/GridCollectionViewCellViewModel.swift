//
//  GridCollectionViewCellViewModel.swift
//  Meme
//
//  Created by DAO on 2024/9/9.
//

import UIKit
import RxSwift
import RxRelay

final class GridCollectionViewCellViewModel {
    // MARK: - Properties
    private let titleRelay: BehaviorRelay<String>
    private let imageDataRelay: BehaviorRelay<(type: GridImageType, image: UIImage)>
    
    var title: Observable<String> {
        return titleRelay.asObservable()
    }
    
    var imageData: Observable<(type: GridImageType, image: UIImage)> {
        return imageDataRelay.asObservable()
    }
    
    // MARK: - Init
    init(gridData: GridData) {
        titleRelay = BehaviorRelay<String>(value: gridData.title)
        imageDataRelay = BehaviorRelay<(type: GridImageType, image: UIImage)>(value: (gridData.imageType, gridData.image))
    }
}
