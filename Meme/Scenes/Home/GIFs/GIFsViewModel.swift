//
//  GIFsViewModel.swift
//  Meme
//
//  Created by DAO on 2024/9/22.
//

import Foundation
import RxSwift
import RxRelay
import WebAPI

final class GIFsViewModel: GIFsViewModelProtocol {
    // MARK: - Properties
    private let loadingStateRelay = BehaviorRelay<LoadingState>(value: .initial)
    private lazy var keywordBehaviorSubject = BehaviorSubject<String?>(value: nil)
    private var gridCellViewModels: [GridCellViewModelProtocol] = []
    private let webService: GIFsAPIServiceProtocol
    private let disposeBag = DisposeBag()
    let gridCollectionViewModel: GridCollectionViewModelProtocol = GridCollectionViewModel(gridDatas: [])
    
    var keywordObserver: AnyObserver<String?> {
        keywordBehaviorSubject.asObserver()
    }
    
    var keyword: Observable<String?> {
        keywordBehaviorSubject.asObservable()
    }
    
    var loadingState: LoadingState {
        loadingStateRelay.value
    }
    
    var loadingStateObservable: Observable<LoadingState> {
        loadingStateRelay.asObservable()
    }
    
    // MARK: - Init
    init(webService: GIFsAPIServiceProtocol) {
        self.webService = webService
    }
    
    // MARK: - data handler
    func loadFirstDataIfNeeded() {
        guard loadingState == .initial else { return }
        fetchGIFs()
    }
    
    func fetchGIFs() {
        loadingStateRelay.accept(.loading)
        // !query could not be empty string!
        let query: String
        if let keywordString = (try? keywordBehaviorSubject.value()), !keywordString.isEmpty {
            query = keywordString
        } else {
            query = randomWord()
        }
        
        webService.fetchGifs(query: query, number: 10)
            .subscribe(onSuccess: { [weak self] result in
                guard let self else { return }
                
                switch result {
                case .success(let gif):
                    let gridDatas = gif.images.map { GridData(title: nil, imageType: .gif(url: $0.url)) }
                    self.gridCollectionViewModel.gridDatasObserver.onNext(gridDatas)
                    
                    self.loadingStateRelay.accept(.success)
                    
                case .failure(let error):
                    self.loadingStateRelay.accept(.failure(error: NSError(domain: error.message, code: error.code)))
                }
               
            }, onFailure: { [weak self] error in
                guard let self = self else { return }
                self.loadingStateRelay.accept(.failure(error: error))
            })
            .disposed(by: disposeBag)
    }
    
    private func randomWord() -> String {
        let consonants = "bcdfghjklmnpqrstvwxyz"
        let vowels = "aeiou"
        let length = Int.random(in: 3...8)
        var word = ""
        
        for i in 0..<length {
            if i % 2 == 0 {
                word += String(consonants.randomElement()!)
            } else {
                word += String(vowels.randomElement()!)
            }
        }
        
        return word
    }
}
