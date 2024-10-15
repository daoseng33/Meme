//
//  MemeTabBarController.swift
//  Meme
//
//  Created by DAO on 2024/9/6.
//

import UIKit

enum MemeTabBarItem: Int, CaseIterable {
    case home
    case history
    case favorite
    case settings
}

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
        let homeViewController = BaseNavigationController(rootViewController: HomePageViewController())
        homeViewController.tabBarItem = UITabBarItem(title: "Home".localized(), image: Asset.Tabbar.home.image, tag: MemeTabBarItem.home.rawValue)
        
        let historyViewController = BaseNavigationController(rootViewController: HistoryViewController(viewModel: GeneralContentViewModel(), title: "History".localized(), tabBarType: .history))
        historyViewController.tabBarItem = UITabBarItem(title: "History".localized(), image: Asset.Tabbar.history.image, tag: MemeTabBarItem.history.rawValue)
        
        let predicate = NSPredicate(format: "isFavorite == %@", NSNumber(value: true))
        let favoriteViewModel = GeneralContentViewModel(predicate: predicate)
        let favoriteViewController = BaseNavigationController(rootViewController: FavoriteViewController(viewModel: favoriteViewModel, title: "Favorite".localized(), tabBarType: .favorite))
        favoriteViewController.tabBarItem = UITabBarItem(title: "Favorite".localized(), image: Asset.Tabbar.favorite.image, tag: MemeTabBarItem.favorite.rawValue)
        
        let settingViewController = BaseNavigationController(rootViewController: SettingViewController(viewModel: SettingViewModel()))
        settingViewController.tabBarItem = UITabBarItem(title: "Setting".localized(), image: Asset.Tabbar.settings.image, tag: MemeTabBarItem.settings.rawValue)
        
        viewControllers = [homeViewController, historyViewController, favoriteViewController, settingViewController]
    }
}
