//
//  BaseViewController.swift
//  Meme
//
//  Created by DAO on 2024/9/20.
//

import UIKit
import SnapKit

class BaseViewController: UIViewController {
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
    }
    
    // MARK: - Setup
    private func setup() {
        view.backgroundColor = .secondarySystemBackground
    }
}
