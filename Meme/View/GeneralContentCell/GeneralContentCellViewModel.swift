//
//  GeneralContentCellViewModel.swift
//  Meme
//
//  Created by DAO on 2024/10/1.
//

import Foundation
import RxSwift
import RxRelay

final class GeneralContentCellViewModel: GeneralContentCellViewModelProtocol {
    // MARK: - Properties
    var content: GeneralContentCellType
    var shareButtonTappedRelay = PublishRelay<GeneralContentCellType>()
    var imageTappedRelay = PublishRelay<URL>()
    var isFavoriteRelay: BehaviorRelay<Bool>
    let createdAt: Date
    private let disposeBag = DisposeBag()
    
    // MARK: - Init
    init(content: GeneralContentCellType) {
        self.content = content
        switch content {
        case .meme(let meme):
            isFavoriteRelay = BehaviorRelay(value: meme.isFavorite)
            createdAt = meme.createdAt
            
        case .joke(let joke):
            isFavoriteRelay = BehaviorRelay(value: joke.isFavorite)
            createdAt = joke.createdAt
            
        case .gif(let imageData):
            isFavoriteRelay = BehaviorRelay(value: imageData.isFavorite)
            createdAt = imageData.createdAt
        }
        
        setupObservable()
    }
    
    private func setupObservable() {
        isFavoriteRelay
            .withUnretained(self)
            .subscribe(onNext: { (self, isFavorite) in
                DispatchQueue.main.async {
                    switch self.content {
                    case .meme(let meme):
                        DataStorageManager.shared.update(meme, with: [Constant.Key.isFavorite: isFavorite])
                    case .joke(let joke):
                        DataStorageManager.shared.update(joke, with: [Constant.Key.isFavorite: isFavorite])
                    case .gif(let imageData):
                        DataStorageManager.shared.update(imageData, with: [Constant.Key.isFavorite: isFavorite])
                    }
                }
            })
            .disposed(by: disposeBag)
    }
}
