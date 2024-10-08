//
//  FavoriteStateProtocol.swift
//  Meme
//
//  Created by DAO on 2024/10/8.
//

import Foundation
import RxRelay

protocol FavoriteStateProtocol {
    var isFavoriteRelay: BehaviorRelay<Bool> { get }
    func toggleIsFavorite()
}

extension FavoriteStateProtocol {
    func toggleIsFavorite() {
        isFavoriteRelay.accept(!isFavoriteRelay.value)
    }
}
