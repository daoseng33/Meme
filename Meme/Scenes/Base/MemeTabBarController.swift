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
        
        setupUI()
        setupViewControllers()
    }

    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .secondarySystemBackground
        
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .secondarySystemBackground
        appearance.shadowColor = .opaqueSeparator
        appearance.shadowImage = UIImage()
        
        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
    }
    
    private func setupViewControllers() {
        let homeViewController = UINavigationController(rootViewController: HomePageViewController())
        homeViewController.tabBarItem = UITabBarItem(title: "Home".localized(), image: Asset.Tabbar.home.image, tag: 0)
        
        let historyViewController = UINavigationController(rootViewController: HistoryViewController())
        historyViewController.tabBarItem = UITabBarItem(title: "History".localized(), image: Asset.Tabbar.history.image, tag: 1)
        
        let favoriteViewController = UINavigationController(rootViewController: FavoriteViewController())
        favoriteViewController.tabBarItem = UITabBarItem(title: "Favorite".localized(), image: Asset.Tabbar.favorite.image, tag: 2)
        
        let settingViewController = UINavigationController(rootViewController: SettingViewController())
        settingViewController.tabBarItem = UITabBarItem(title: "Setting".localized(), image: Asset.Tabbar.settings.image, tag: 3)
        
        viewControllers = [homeViewController, historyViewController, favoriteViewController, settingViewController]
    }
}
