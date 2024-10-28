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
import AppNavigator

final class HomePageViewController: BaseViewController {
    // MARK: - UI
    private lazy var adBannerView = AdBannerView(parentVC: self)
    private let remoteConfigHandler = RemoteConfigHandler()
    
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
        adBannerView.isHidden = !remoteConfigHandler.getBool(forKey: .enableAds)

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
        switch category {
        case .meme:
            AppNavigator.shared.open(with: .page,
                                     name: PageURLPath.randomMeme.rawValue,
                                     context: viewModel.randomMemeViewModel)
            
        case .joke:
            AppNavigator.shared.open(with: .page,
                                     name: PageURLPath.randomJoke.rawValue,
                                     context: viewModel.randomJokeViewModel)
            
        case .gifs:
            AppNavigator.shared.open(with: .page,
                                     name: PageURLPath.randomGif.rawValue,
                                     context: viewModel.gifsViewModel)
            
        case nil:
            return
        }
    }
}

extension HomePageViewController {
    enum Category: Int {
        case meme
        case joke
        case gifs
    }
}
