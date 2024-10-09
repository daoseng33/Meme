//
//  RandomJokeViewModel.swift
//  Meme
//
//  Created by DAO on 2024/9/18.
//

import Foundation
import RxSwift
import RxRelay
import RxCocoa
import HumorAPIService

final class RandomJokeViewModel: RandomJokeViewModelProtocol {
    var loadingStateDriver: Driver<LoadingState> {
        loadingStateRelay.asDriver()
    }
    
    var loadingState: LoadingState {
        loadingStateRelay.value
    }
    
    // MARK: - Porperties
    var jokeObservable: Observable<String> {
        jokeRelay.asObservable()
    }
    
    var joke: String {
        jokeRelay.value
    }
    
    var categories: [String] {
        JokeCategory.allCases.map(\.rawValue)
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
    
    let isFavoriteRelay = BehaviorRelay(value: false)
    
    private let webService: JokeAPIServiceProtocol
    private let jokeRelay: BehaviorRelay<String> = .init(value: "")
    private let selectedCategorySubject = BehaviorSubject<String>(value: JokeCategory.Random.rawValue)
    private let loadingStateRelay: BehaviorRelay<LoadingState> = .init(value: .initial)
    private let disposeBag = DisposeBag()
    private var currentJoke: RandomJoke?
    
    // MARK: - Init
    init(webService: JokeAPIServiceProtocol) {
        self.webService = webService
        
        setupObservable()
    }
    
    // MARK: - Get data
    func refreshData() {
        if loadingState == .initial {
            fetchData()
        } else if let currentJoke = self.currentJoke {
            DispatchQueue.main.async {
                if let localJoke = try? DataStorageManager.shared.fetch(RandomJoke.self, primaryKey: currentJoke.id) {
                    self.isFavoriteRelay.accept(localJoke.isFavorite)
                }
            }
        }
    }
    
    func fetchData() {
        loadingStateRelay.accept(.loading)
        
        webService.fetchRandomJoke(tags: [selectedCategory], excludedTags: [], minRating: 9, maxLength: 999)
            .subscribe(onSuccess: { [weak self] result in
                guard let self = self else { return }
                
                switch result {
                case .success(let joke):
                    self.currentJoke = joke
                    
                    DispatchQueue.main.async {
                        DataStorageManager.shared.save(joke)
                    }
                    
                    self.isFavoriteRelay.accept(joke.isFavorite)
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
    
    private func setupObservable() {
        isFavoriteRelay
            .withUnretained(self)
            .subscribe(onNext: { (self, isFavorite) in
                DispatchQueue.main.async {
                    guard let currentJoke = self.currentJoke else {
                        return
                    }
                    
                    DataStorageManager.shared.update(currentJoke, with: [Constant.Key.isFavorite: isFavorite])
                }
            })
            .disposed(by: disposeBag)
    }
}
