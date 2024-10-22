//
//  HomePageViewController.swift
//  Meme
//
//  Created by DAO on 2024/8/30.
//

import UIKit
import SnapKit
import GoogleMobileAds
import RxCocoa

final class HomePageViewController: BaseViewController {
    // MARK: - UI
    private lazy var adBannerView = AdBannerView(parentVC: self)
    
    // MARK: - Properties
    let viewModel = HomePageViewModel()
    private lazy var homePageCollectionView = GridCollectionView(viewModel: viewModel.gridCollectionViewModel)
    
    // MARK: - View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupObservable()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        AnalyticsManager.shared.logScreenView(screenName: .homepage)
    }

    // MARK: - Setup
    private func setupUI() {
        navigationItem.title = "Memepire".localized()
        homePageCollectionView.delegate = self
        adBannerView.isHidden = !RemoteConfigManager.shared.getBool(forKey: .enableAds)

        let stackView: UIStackView = {
            let stackView = UIStackView(arrangedSubviews: [homePageCollectionView, adBannerView])
            stackView.axis = .vertical
            stackView.spacing = 0
            return stackView
        }()
        
        view.addSubview(stackView)
        stackView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        adBannerView.snp.makeConstraints {
            $0.height.equalTo(Constant.Ad.adBannerHeight).priority(.high)
        }
    }
    
    private func setupObservable() {
        PurchaseManager.shared.isSubscribedRelay
            .asDriver()
            .skip(1)
            .drive(with: self) { (self, isSubscribed) in
                self.adBannerView.isHidden = isSubscribed
            }
            .disposed(by: rx.disposeBag)
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
