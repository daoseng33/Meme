//
//  HomePageViewController.swift
//  Meme
//
//  Created by DAO on 2024/8/30.
//

import UIKit
import SnapKit

final class HomePageViewController: BaseViewController {
    // MARK: - Properties
    let viewModel = HomePageViewModel()
    private lazy var homePageCollectionView = GridCollectionView(viewModel: viewModel.gridCollectionViewModel)
    
    // MARK: - View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        AnalyticsManager.shared.logScreenView(screenName: .homepage)
    }

    // MARK: - Setup
    private func setupUI() {
        navigationItem.title = "Memepire".localized()
        homePageCollectionView.delegate = self

        view.addSubview(homePageCollectionView)
        homePageCollectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}

// MARK: - GridCollectionViewDelegate
extension HomePageViewController: GridCollectionViewDelegate {
    func gridCollectionView(_ gridCollectionView: GridCollectionView, didSelectItemAt index: Int) {
        let category = Category(rawValue: index)
        let vc: BaseViewController
        switch category {
        case .meme:
            vc = RandomMemeViewController(viewModel: viewModel.randomMemeViewModel)
            
        case .joke:
            vc = RandomJokeViewController(viewModel: viewModel.randomJokeViewModel)
            
        case .gifs:
            vc = GIFsViewController(viewModel: viewModel.gifsViewModel)
            
        case nil:
            return
        }
        
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension HomePageViewController {
    enum Category: Int {
        case meme
        case joke
        case gifs
    }
}
