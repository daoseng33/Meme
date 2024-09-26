//
//  HomePageViewModel.swift
//  Meme
//
//  Created by DAO on 2024/9/5.
//

import UIKit
import HumorAPIService

final class HomePageViewModel {
    // MARK: - Properties
    private let gridDatas: [GridData] = {
        var datas = [
            GridData(title: "Random Meme".localized(), imageType: .static(image: Asset.Home.memeApi.image)),
            GridData(title: "Random Joke".localized(), imageType: .static(image: Asset.Home.jokeApi.image)),
        ]
  
        datas.append(GridData(title: "GIFs".localized(), imageType: .gif(url: Files.bananaCheererGif.url)))
        
        return datas
    }()
    
    lazy var gridCollectionViewModel = GridCollectionViewModel(gridDatas: gridDatas)
    let randomMemeViewModel: RandomMemeViewModelProtocol = RandomMemeViewModel(webService: MemeAPIService())
    let randomJokeViewModel: RandomJokeViewModelProtocol = RandomJokeViewModel(webService: JokeAPIService())
    let gifsViewModel: GIFsViewModelProtocol = GIFsViewModel(webService: GIFsAPIService())
}
