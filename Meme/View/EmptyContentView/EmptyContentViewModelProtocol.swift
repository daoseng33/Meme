//
//  EmptyContentViewModelProtocol.swift
//  Meme
//
//  Created by DAO on 2024/10/21.
//

import Foundation
import RxRelay

protocol EmptyContentViewModelProtocol {
    var actionButtonRelay: PublishRelay<Void> { get }
}
