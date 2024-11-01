//
//  PageNavigatorConfig.swift
//  Meme
//
//  Created by DAO on 2024/10/28.
//

import UIKit
import AppNavigator

enum PageURLPath: String {
    case randomMeme
    case randomJoke
    case randomGif
    case appearance
}

struct RandomMemePageConfig: NavigatorConfig {
    let name: String = PageURLPath.randomMeme.rawValue
    
    var handler: URLHandlerFactory = { params, context in
        guard let viewModel = context as? RandomMemeViewModelProtocol else {
            return false
        }
        
        let randomMemeVC = RandomMemeViewController(viewModel: viewModel)
        randomMemeVC.hidesBottomBarWhenPushed = true
        UIApplication.topViewController()?.navigationController?.pushViewController(randomMemeVC, animated: true)
        
        return true
    }
}

struct RandomJokePageConfig: NavigatorConfig {
    let name: String = PageURLPath.randomJoke.rawValue
    
    var handler: URLHandlerFactory = { params, context in
        guard let viewModel = context as? RandomJokeViewModelProtocol else {
            return false
        }
        
        let randomJokeVC = RandomJokeViewController(viewModel: viewModel)
        randomJokeVC.hidesBottomBarWhenPushed = true
        UIApplication.topViewController()?.navigationController?.pushViewController(randomJokeVC, animated: true)
        
        return true
    }
}

struct RandomGifPageConfig: NavigatorConfig {
    let name: String = PageURLPath.randomGif.rawValue
    
    var handler: URLHandlerFactory = { params, context in
        guard let viewModel = context as? GIFsViewModelProtocol else {
            return false
        }
        
        let randomGifVC = GIFsViewController(viewModel: viewModel)
        randomGifVC.hidesBottomBarWhenPushed = true
        UIApplication.topViewController()?.navigationController?.pushViewController(randomGifVC, animated: true)
        
        return true
    }
}

struct AppearancePageConfig: NavigatorConfig {
    let name: String = PageURLPath.appearance.rawValue
    
    var handler: URLHandlerFactory = { params, context in
        guard let viewModel = context as? AppearanceTableViewModel else {
            return false
        }
        
        let appearanceVC = AppearanceTableViewController(viewModel: viewModel)
        appearanceVC.hidesBottomBarWhenPushed = true
        UIApplication.topViewController()?.navigationController?.pushViewController(appearanceVC, animated: true)
        
        return true
    }
}
