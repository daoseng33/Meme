//
//  GridCollectionViewCellViewModelProtocol.swift
//  Meme
//
//  Created by DAO on 2024/9/22.
//

import Foundation
import RxSwift

protocol GridCollectionViewCellViewModelProtocol {
    var title: Observable<String?> { get }
    var imageData: Observable<(GridImageType)> { get }
    init(gridData: GridData)
}