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
            GridData(title: "Random Meme", image: R.image.memeApi()!, imageType: .static),
            GridData(title: "Random Joke", image: R.image.jokeApi()!, imageType: .static),
        ]
        if let memesGIF = try? UIImage(gifName: "banana-cheerer.gif") {
            datas.append(GridData(title: "Memes", image: memesGIF, imageType: .gif))
        }
        
        return datas
    }()
}
