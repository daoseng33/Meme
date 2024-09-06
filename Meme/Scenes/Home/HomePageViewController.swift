//
//  HomePageViewController.swift
//  Meme
//
//  Created by DAO on 2024/8/30.
//

import UIKit

final class HomePageViewController: UIViewController {
    // MARK: - Properties
    let viewModel = HomePageViewModel()
    
    // MARK: - View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        viewModel.fetchRandomMeme()
    }

    // MARK: - Setup
    private func setup() {
//        view.backgroundColor = .white
    }
}

