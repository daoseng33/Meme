//
//  GridCollectionViewModel.swift
//  Meme
//
//  Created by DAO on 2024/9/9.
//

import UIKit
import RxRelay
import RxSwift
import RxDataSources

struct GridSection {
    var items: [GridData]
}

extension GridSection: AnimatableSectionModelType {
    var identity: String {
        return ""
    }
    
    typealias Identity = String
    
    init(original: GridSection, items: [GridData]) {
        self = original
        self.items = items
    }
}

final class GridCollectionViewModel: GridCollectionViewModelProtocol {
    // MARK: - Properties
    var dataSource: RxCollectionViewSectionedAnimatedDataSource<GridSection>?
    var sectionsRelay: BehaviorRelay<[GridSection]>
    var section: GridSection? {
        sectionsRelay.value.first
    }
    let favoriteButtonTappedRelay = PublishRelay<(gridImageType: GridImageType, isFavorite: Bool, index: Int)>()
    let shareButtonTappedRelay = PublishRelay<GridImageType>()
    
    // MARK: - Init
    init(gridDatas: [GridData]) {
        sectionsRelay = BehaviorRelay(value: [GridSection(items: gridDatas)])
    }
    
    // MARK: - Configures
    func gridCellViewModel(with index: Int) -> GridCellViewModelProtocol {
        guard let gridDatas = section?.items, gridDatas.count > index else {
            let noResultGridData = GridData(title: nil, imageType: .static(image: Asset.Global.imageNotFound.image), isFavorite: false)
            return GridCellViewModel(gridData: noResultGridData)
        }
        let gridData = gridDatas[index]
        let cellViewModel = GridCellViewModel(gridData: gridData)
        return cellViewModel
    }
}
