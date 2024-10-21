//
//  EmptyContentViewModel.swift
//  Meme
//
//  Created by DAO on 2024/10/21.
//

import Foundation
import RxRelay

final class EmptyContentViewModel: EmptyContentViewModelProtocol {
    let actionButtonRelay = PublishRelay<Void>()
}
