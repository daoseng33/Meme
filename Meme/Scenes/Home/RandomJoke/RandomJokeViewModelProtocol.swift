//
//  RandomJokeViewModelProtocol.swift
//  Meme
//
//  Created by DAO on 2024/9/18.
//

import Foundation
import RxSwift
import RxRelay
import HumorAPIService

protocol RandomJokeViewModelProtocol: FetchDataProtocol, LoadingStateProtocol, FavoriteStateProtocol {
    var jokeObservable: Observable<String> { get }
    var joke: String { get }
    var selectedCategoryObserver: AnyObserver<String> { get }
    var selectedCategory: JokeCategory { get }
    var categories: [String] { get }
}
