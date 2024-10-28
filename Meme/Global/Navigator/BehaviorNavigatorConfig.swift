//
//  BehaviorNavigatorConfig.swift
//  Meme
//
//  Created by DAO on 2024/10/28.
//

import UIKit
import AppNavigator

enum BehaviorURLPath: String {
    case selectTab
    case dismiss
    case backToPrevious
}

struct DismissConfigs: NavigatorConfig {
    let name: String = BehaviorURLPath.dismiss.rawValue
    
    var handler: URLHandlerFactory = { params, context in
        UIApplication.topViewController()?.dismiss(animated: true, completion: nil)
        
        return true
    }
}

struct BackToPreviousConfigs: NavigatorConfig {
    let name: String = BehaviorURLPath.backToPrevious.rawValue
    
    var handler: URLHandlerFactory = { params, context in
        
        if let navigationController = UIApplication.topViewController()?.navigationController {
            navigationController.dismiss(animated: true)
            navigationController.popViewController(animated: true)
        } else if let parentVC = UIApplication.topViewController()?.presentingViewController {
            parentVC.dismiss(animated: false) {
                if let navigationController = UIApplication.topViewController()?.navigationController {
                    navigationController.popViewController(animated: true)
                } else {
                    UIApplication.topViewController()?.dismiss(animated: true, completion: nil)
                }
            }
        }
        
        return true
    }
}

struct SelectTabConfigs: NavigatorConfig {
    let name: String = BehaviorURLPath.selectTab.rawValue
    
    var handler: URLHandlerFactory = { params, context in
        guard let tab = params[Constant.Parameter.tab],
              let tabNumber = Int(tab) else {
            return false
        }
        
        UIApplication.topViewController()?.tabBarController?.dismiss(animated: true)
        UIApplication.topViewController()?.tabBarController?.selectedIndex = tabNumber
        
        return true
    }
}
