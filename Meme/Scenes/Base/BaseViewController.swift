//
//  BaseViewController.swift
//  Meme
//
//  Created by DAO on 2024/9/20.
//

import UIKit
import SnapKit

class BaseViewController: UIViewController {
    // MARK: - View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
    }
    
    // MARK: - Setup
    private func setup() {
        view.backgroundColor = .systemBackground
    }
}
