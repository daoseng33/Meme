//
//  RandomJokeViewModel.swift
//  Meme
//
//  Created by DAO on 2024/9/18.
//

import Foundation
import RxSwift
import RxRelay
import WebAPI

final class RandomJokeViewModel: RandomJokeViewModelProtocol {
    var loadingStateObservable: Observable<LoadingState> {
        loadingStateRelay.asObservable()
    }
    
    var loadingState: LoadingState {
        loadingStateRelay.value
    }
    
    // MARK: - Porperties
    var joke: Observable<String> {
        return jokeRelay.asObservable()
    }
    
    var categories: [String] {
        return JokeCategory.allCases.map(\.rawValue)
    }
    
    var selectedCategoryObserver: AnyObserver<String> {
        selectedCategorySubject.asObserver()
    }
    
    var selectedCategory: JokeCategory {
        guard let string = try? selectedCategorySubject.value(),
                let category = JokeCategory(rawValue: string) else {
            return .Random
        }
        
        return category
    }
    
    private let webService: JokeAPIServiceProtocol
    private let jokeRelay: BehaviorRelay<String> = .init(value: "")
    private let selectedCategorySubject = BehaviorSubject<String>(value: JokeCategory.Random.rawValue)
    private let loadingStateRelay: BehaviorRelay<LoadingState> = .init(value: .initial)
    private let disposeBag = DisposeBag()
    
    // MARK: - Init
    init(webService: JokeAPIServiceProtocol) {
        self.webService = webService
    }
    
    // MARK: - Get data
    func loadFirstMemeIfNeeded() {
        if loadingState == .initial {
            fetchRandomJoke()
        }
    }
    
    func fetchRandomJoke() {
        loadingStateRelay.accept(.loading)
        
        webService.fetchRandomJoke(tags: [selectedCategory], excludedTags: [], minRating: 8, maxLength: 999)
            .subscribe(onSuccess: { [weak self] result in
                guard let self = self else { return }
                
                switch result {
                case .success(let joke):
                    self.jokeRelay.accept(joke.joke)
                    
                case .failure(let error):
                    self.jokeRelay.accept(error.message)
                }
                
                self.loadingStateRelay.accept(.success)
            }, onFailure: { [weak self] error in
                guard let self = self else { return }
                self.loadingStateRelay.accept(.failure(error: error))
            })
            .disposed(by: disposeBag)
    }
}
