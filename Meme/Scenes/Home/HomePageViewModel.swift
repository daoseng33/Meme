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
            GridData(title: "GIFs".localized(), imageType: .gif(fileName: "banana-cheerer")),
        ]
        
        return datas
    }()
    
    let randomMemeViewModel: RandomMemeViewModelProtocol = RandomMemeViewModel()
}
