//
//  EmptyContentViewModelProtocol.swift
//  Meme
//
//  Created by DAO on 2024/10/21.
//

import Foundation
import Combine

protocol EmptyContentViewModelProtocol {
    var actionButtonSubject: PassthroughSubject<Void, Never> { get }
}
