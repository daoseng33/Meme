//
//  MemeTabBarController.swift
//  Meme
//
//  Created by DAO on 2024/9/6.
//

import UIKit

final class MemeTabBarController: UITabBarController {
    // MARK: - Properties
    private let globalErrorHandler = GlobalErrorHandler()
    
    // MARK: - View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        handleGlobalError()
    }

    //MARK: - Setup
    private func setup() {
        view.backgroundColor = .systemBackground
        tabBar.tintColor = .label
        
        let homeViewController = HomePageViewController()
        homeViewController.tabBarItem = UITabBarItem(title: "Home".localized(), image: R.image.home(), tag: 0)
        
        let historyViewController = HistoryViewController()
        historyViewController.tabBarItem = UITabBarItem(title: "History".localized(), image: R.image.history(), tag: 1)
        
        let favoriteViewController = FavoriteViewController()
        favoriteViewController.tabBarItem = UITabBarItem(title: "Favorite".localized(), image: R.image.favorite(), tag: 2)
        
        let settingViewController = SettingViewController()
        settingViewController.tabBarItem = UITabBarItem(title: "Setting".localized(), image: R.image.settings(), tag: 3)
        
        viewControllers = [homeViewController, historyViewController, favoriteViewController, settingViewController]
    }
    
    private func handleGlobalError() {
        globalErrorHandler.handleError()
    }
}
