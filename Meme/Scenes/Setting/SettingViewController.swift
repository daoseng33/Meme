//
//  SettingViewController.swift
//  Meme
//
//  Created by DAO on 2024/9/6.
//

import UIKit

final class SettingViewController: UIViewController {
    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }
    
    // MARK: - Setup
    private func setupUI() {
        navigationItem.title = "Setting".localized()
    }
}
