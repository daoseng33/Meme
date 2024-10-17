//
//  AdFullPageHandler.swift
//  Meme
//
//  Created by DAO on 2024/10/16.
//

import GoogleMobileAds
import UIKit
import RxRelay
import RxSwift

final class AdFullPageHandler: NSObject {
    // MARK: - Properties
    var dismissAdObservable: Observable<Void> {
        return dismissAdRelay.asObservable()
    }
    
    var shouldDisplayAd: Bool {
        return apiRequestCount >= apiRequestLimit
    }
    
    private var interstitial: GADInterstitialAd?
    private let dismissAdRelay = PublishRelay<Void>()
    private var apiRequestLimit: Int {
        return Int(truncating: RemoteConfigManager.shared.getNumber(forKey: .apiRequestLimit))
    }
    
    private var apiRequestCount: Int {
        get {
            return KeychainManager.loadInt(forKey: .apiRequestCount) ?? 0
        }
        
        set {
            var value = newValue
            let _ = KeychainManager.saveInt(&value, forKey: .apiRequestCount)
        }
    }
    
    // MARK: - Functions
    func increaseRequestCount() {
        apiRequestCount += 1
    }
    
    private func resetRequestCount() {
        apiRequestCount = 0
    }
    
    func loadFullPageAd() {
        Task {
            do {
                #if RELEASE
                let unitId = (Bundle.main.infoDictionary?["GAD_FULL_PAGE_AD_UNIT_ID"] as? String) ?? ""
                #else
                let unitId = "ca-app-pub-3940256099942544/4411468910"
                #endif
                interstitial = try await GADInterstitialAd.load(
                    withAdUnitID: unitId, request: GADRequest())
                interstitial?.fullScreenContentDelegate = self
            } catch {
                print("Failed to load interstitial ad with error: \(error.localizedDescription)")
            }
        }
    }
    
    func presentFullPageAd(parentVC: UIViewController?) {
        guard let interstitial = interstitial else {
          return print("Ad wasn't ready.")
        }

        interstitial.present(fromRootViewController: parentVC)
    }
}

extension AdFullPageHandler: GADFullScreenContentDelegate {
    /// Tells the delegate that the ad failed to present full screen content.
    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("Ad did fail to present full screen content.")
        loadFullPageAd()
    }
    
    /// Tells the delegate that the ad will present full screen content.
    func adWillPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("Ad will present full screen content.")
    }
    
    /// Tells the delegate that the ad dismissed full screen content.
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("Ad did dismiss full screen content.")
        loadFullPageAd()
        resetRequestCount()
        dismissAdRelay.accept(())
    }
}
