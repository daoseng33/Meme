//
//  GridCellViewModel.swift
//  Meme
//
//  Created by DAO on 2024/9/9.
//

import UIKit
import RxSwift
import RxRelay
import HumorAPIService

final class GridCellViewModel: GridCellViewModelProtocol {
    // MARK: - Properties
    private let titleRelay: BehaviorRelay<String?>
    private let imageTypeRelay: BehaviorRelay<GridImageType>
    private let disposeBag = DisposeBag()

    let shareButtonTappedRelay = PublishRelay<GridImageType>()
    let favoriteButtonTappedRelay = PublishRelay<(gridImageType: GridImageType, isFavorite: Bool)>()
    let isFavoriteRelay = BehaviorRelay<Bool>(value: false)
    
    var currentImageType: GridImageType {
        imageTypeRelay.value
    }
    
    var titleObservable: Observable<String?> {
        titleRelay.asObservable()
    }
    
    var imageTypeObservable: Observable<(GridImageType)> {
        imageTypeRelay.asObservable()
    }
    
    // MARK: - Init
    init(gridData: GridData) {
        titleRelay = BehaviorRelay<String?>(value: gridData.title)
        imageTypeRelay = BehaviorRelay<(GridImageType)>(value: (gridData.imageType))
        isFavoriteRelay.accept(gridData.isFavorite)
        
        setupObservables()
    }
    
    private func setupObservables() {
        isFavoriteRelay
            .withUnretained(self)
            .subscribe(onNext: { (self, isFavorite) in
                self.favoriteButtonTappedRelay.accept((self.currentImageType, isFavorite))
            })
            .disposed(by: disposeBag)
    }
}
