//
//  BaseViewController.swift
//  Meme
//
//  Created by DAO on 2024/9/20.
//

import UIKit
import SnapKit

class BaseViewController: UIViewController {
    // MARK: - UI
    let navigationBar: UINavigationBar = {
       let navigationBar = UINavigationBar()
        navigationBar.barTintColor = .systemBackground
        
        let appearance: UINavigationBarAppearance = {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.shadowColor = .clear
            return appearance
        }()
        
        navigationBar.standardAppearance = appearance
        navigationBar.scrollEdgeAppearance = appearance
        
        let navigationItem = UINavigationItem()
        let closeBarItem = UIBarButtonItem(barButtonSystemItem: .close, target: nil, action: #selector(closeButtonTapped))
        navigationItem.rightBarButtonItem = closeBarItem
        
        navigationBar.items = [navigationItem]
        
        return navigationBar
    }()
    
    // MARK: - View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
    }
    
    // MARK: - Setup
    private func setup() {
        view.addSubview(navigationBar)
        navigationBar.snp.makeConstraints {
            $0.top.left.right.equalToSuperview()
        }
    }
    
    @objc private func closeButtonTapped() {
        dismiss(animated: true)
    }
}
