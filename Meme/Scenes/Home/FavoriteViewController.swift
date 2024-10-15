//
//  FavoriteViewController.swift
//  Meme
//
//  Created by DAO on 2024/10/15.
//

import UIKit

final class FavoriteViewController: GeneralContentViewController {
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        AnalyticsManager.shared.logScreenView(screenName: .favorite)
    }
}
