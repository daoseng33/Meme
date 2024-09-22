//
//  GridCollectionViewModelProtocol.swift
//  Meme
//
//  Created by DAO on 2024/9/22.
//

import Foundation
import RxSwift

protocol GridCollectionViewModelProtocol {
    var numberOfItems: Int { get }
    var shouldReloadData: Observable<Void> { get }
    init(gridDatas: [GridData])
}
