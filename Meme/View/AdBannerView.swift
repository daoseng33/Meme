//
//  AdBannerView.swift
//  Meme
//
//  Created by DAO on 2024/10/16.
//

import UIKit
import GoogleMobileAds
import SnapKit

final class AdBannerView: UIView {
    // MARK: - UI
    private let adBannerView = GADBannerView()
    private var parentVC: UIViewController?
    
    // MARK: - Init
    init(parentVC: UIViewController) {
        self.parentVC = parentVC
        super.init(frame: .zero)
        setupUI()
        loadBanner()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubview(adBannerView)
        adBannerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    // MARK: - Loader
    private func loadBanner() {
        #if RELEASE
        if let adUnitId = Bundle.main.infoDictionary?["GAD_BANNER_AD_UNIT_ID"] as? String {
            adBannerView.adUnitID = adUnitId
        }
        #else
        adBannerView.adUnitID = Constant.DEBUG.gadBannerUnitId
        #endif
        adBannerView.rootViewController = parentVC

        adBannerView.load(GADRequest())
    }
}
