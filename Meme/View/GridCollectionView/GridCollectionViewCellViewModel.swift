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
    private let imageRelay: BehaviorRelay<UIImage>
    
    var title: Observable<String> {
        return titleRelay.asObservable()
    }
    
    var image: Observable<UIImage> {
        return imageRelay.asObservable()
    }
    
    // MARK: - Init
    init(title: String, image: UIImage) {
        titleRelay = BehaviorRelay<String>(value: title)
        imageRelay = BehaviorRelay<UIImage>(value: image)
    }
}
