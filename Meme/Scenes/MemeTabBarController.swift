//
//  MemeTabBarController.swift
//  Meme
//
//  Created by DAO on 2024/9/6.
//

import UIKit

final class MemeTabBarController: UITabBarController {
    // MARK: - View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }

    //MARK: - Setup
    private func setup() {
        view.backgroundColor = .systemBackground
        tabBar.tintColor = .accent
        
        let homeViewController = HomePageViewController()
        homeViewController.tabBarItem = UITabBarItem(title: "Home".localized(), image: Asset.Tabbar.home.image, tag: 0)
        
        let historyViewController = HistoryViewController()
        historyViewController.tabBarItem = UITabBarItem(title: "History".localized(), image: Asset.Tabbar.history.image, tag: 1)
        
        let favoriteViewController = FavoriteViewController()
        favoriteViewController.tabBarItem = UITabBarItem(title: "Favorite".localized(), image: Asset.Tabbar.favorite.image, tag: 2)
        
        let settingViewController = SettingViewController()
        settingViewController.tabBarItem = UITabBarItem(title: "Setting".localized(), image: Asset.Tabbar.settings.image, tag: 3)
        
        viewControllers = [homeViewController, historyViewController, favoriteViewController, settingViewController]
    }
}
