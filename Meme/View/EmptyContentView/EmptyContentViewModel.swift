//
//  EmptyContentViewModel.swift
//  Meme
//
//  Created by DAO on 2024/10/21.
//

import Foundation
import Combine

final class EmptyContentViewModel: EmptyContentViewModelProtocol {
    let actionButtonSubject = PassthroughSubject<Void, Never>()
}
