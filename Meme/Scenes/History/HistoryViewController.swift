//
//  HistoryViewController.swift
//  Meme
//
//  Created by DAO on 2024/9/6.
//

import UIKit

final class HistoryViewController: BaseViewController {
    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }
    
    // MARK: - Setup
    private func setupUI() {
        navigationItem.title = "History".localized()
    }
}
