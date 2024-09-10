//
//  HomePageViewController.swift
//  Meme
//
//  Created by DAO on 2024/8/30.
//

import UIKit
import SnapKit

final class HomePageViewController: UIViewController {
    // MARK: - Properties
    let viewModel = HomePageViewModel()
    private lazy var homePageCollectionView: GridCollectionView = {
        let gridCollectionViewModel = GridCollectionViewModel(gridDatas: viewModel.gridDatas)
        let collectionView = GridCollectionView(viewModel: gridCollectionViewModel)
        
        return collectionView
    }()
    
    // MARK: - View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }

    // MARK: - Setup
    private func setupUI() {
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
        
    }
}
