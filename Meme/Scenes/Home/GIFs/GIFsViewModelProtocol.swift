//
//  GIFsViewModelProtocol.swift
//  Meme
//
//  Created by DAO on 2024/9/22.
//

import Foundation
import RxSwift

protocol GIFsViewModelProtocol: LoadingStateProtocol {
    var keywordObserver: AnyObserver<String?> { get }
    var keyword: Observable<String?> { get }
    var gridCollectionViewModel: GridCollectionViewModelProtocol { get }
    func loadFirstDataIfNeeded()
    func fetchGIFs()
}
