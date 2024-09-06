//
//  HomePageViewModel.swift
//  Meme
//
//  Created by DAO on 2024/9/5.
//

import Foundation
import WebAPI
import RxSwift

final class HomePageViewModel {
    // MARK: - Properties
    private let memeAPIServcie = MemeAPIService()
    private let disposeBag = DisposeBag()
    
    // MARK: - API Calls
    func fetchRandomMeme() {
        memeAPIServcie.fetchRandomMeme(with: "", mediaType: .image, minRating: 8)
            .subscribe(onSuccess: { meme in
                
            })
            .disposed(by: disposeBag)
    }
}
