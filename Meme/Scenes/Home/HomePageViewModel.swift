//
//  HomePageViewModel.swift
//  Meme
//
//  Created by DAO on 2024/9/5.
//

import UIKit

final class HomePageViewModel {
    // MARK: - Properties
    let gridDatas: [GridData] = {
        var datas = [
            GridData(title: "Random Meme".localized(), imageType: .static(image: R.image.memeApi()!)),
            GridData(title: "Random Joke".localized(), imageType: .static(image: R.image.jokeApi()!)),
        ]
        
        if let gifUrl = R.file.bananaCheererGif() {
            datas.append(GridData(title: "GIFs".localized(), imageType: .gif(url: gifUrl)))
        }
        
        return datas
    }()
    
    let randomMemeViewModel: RandomMemeViewModelProtocol = RandomMemeViewModel()
    let randomJokeViewModel: RandomJokeViewModelProtocol = RandomJokeViewModel()
}
