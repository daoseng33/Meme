//
//  HistoryViewController.swift
//  Meme
//
//  Created by DAO on 2024/10/15.
//

import UIKit

final class HistoryViewController: GeneralContentViewController {
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        AnalyticsManager.shared.logScreenView(screenName: .history)
    }
}
