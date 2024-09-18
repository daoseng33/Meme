//
//  RandomJokeViewModelProtocol.swift
//  Meme
//
//  Created by DAO on 2024/9/18.
//

import Foundation
import RxSwift
import MemeData

protocol RandomJokeViewModelProtocol: LoadingStateProtocol {
    func loadFirstMemeIfNeeded()
    func fetchRandomJoke()
    var joke: Observable<String> { get }
}
