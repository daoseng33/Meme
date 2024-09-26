//
//  RandomJokeViewModelProtocol.swift
//  Meme
//
//  Created by DAO on 2024/9/18.
//

import Foundation
import RxSwift
import HumorDataModel
import HumorAPIService

protocol RandomJokeViewModelProtocol: AnyObject, LoadingStateProtocol {
    func loadFirstMemeIfNeeded()
    func fetchRandomJoke()
    var jokeObservable: Observable<String> { get }
    var joke: String { get }
    var selectedCategoryObserver: AnyObserver<String> { get }
    var selectedCategory: JokeCategory { get }
    var categories: [String] { get }
}
