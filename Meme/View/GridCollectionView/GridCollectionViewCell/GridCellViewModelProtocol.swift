//
//  GridCellViewModelProtocol.swift
//  Meme
//
//  Created by DAO on 2024/9/22.
//

import Foundation
import RxSwift
import RxRelay

protocol GridCellViewModelProtocol {
    var title: Observable<String?> { get }
    var imageType: Observable<GridImageType> { get }
    var currentImageType: GridImageType { get }
    init(gridData: GridData)
}
