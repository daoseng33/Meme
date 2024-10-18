//
//  SettingViewModel.swift
//  Meme
//
//  Created by DAO on 2024/10/11.
//

import Foundation
import RxRelay

enum SettingSectionType: Int, CaseIterable {
    case general
    case sponsor
    case about
    
    var title: String {
        switch self {
        case .general: return "General".localized()
        case .sponsor: return "Sponsor".localized()
        case .about: return "About".localized()
        }
    }
}

enum SettingRowType: Int {
    case appearance
    case language
    case removeAds
    case restorePurchases
    case version
    case contactUs
    
    var title: String {
        switch self {
        case .appearance: return "Appearance".localized()
        case .language: return "Display Language".localized()
        case .removeAds: return "Remove Ads".localized()
        case .restorePurchases: return "Restore Purchases".localized()
        case .version: return "App Version".localized()
        case .contactUs: return "Contact Us".localized()
        }
    }
}

final class SettingViewModel {
    // MARK: - Properties
    lazy var appearanceTableViewModel = AppearanceTableViewModel(appearance: appearanceRelay.value)
    let appearanceRelay: BehaviorRelay<AppearanceStyle>
    
    private let sectionsInfo: [SettingSectionType: [SettingRowType]] = {
        return [
            .general: [.appearance, .language],
            .sponsor: [.removeAds, .restorePurchases],
            .about: [.contactUs, .version]
        ]
    }()
    
    init() {
        if let appearance = UserDefaults.standard.string(forKey: UserDefaults.Key.appearance.rawValue),
            let appearanceStyle = AppearanceStyle(rawValue: appearance) {
            appearanceRelay = BehaviorRelay(value: appearanceStyle)
        } else {
            appearanceRelay = BehaviorRelay(value: .system)
        }
        
        setupBinding()
    }
    
    private func setupBinding() {
        appearanceTableViewModel.appearanceRelay
            .do(onNext: { appearance in
                UserDefaults.standard.set(appearance.rawValue, forKey: UserDefaults.Key.appearance.rawValue)
            })
            .bind(to: appearanceRelay)
            .disposed(by: appearanceTableViewModel.disposeBag)
    }
    
    // MARK: - Getter
    func getNumberOfSections() -> Int {
        return sectionsInfo.keys.count
    }
    
    func getNumberOfRows(in section: Int) -> Int {
        guard let sectionType = SettingSectionType(rawValue: section),
                let rows = sectionsInfo[sectionType] else {
            return 0
        }
        
        return rows.count
    }
    
    func getRowType(with indexPath: IndexPath) -> SettingRowType? {
        guard let sectionType = SettingSectionType(rawValue: indexPath.section),
                let rows = sectionsInfo[sectionType] else {
            return nil
        }
        
        return rows[indexPath.row]
    }
    
    func getSectionTitle(with section: Int) -> String? {
        guard let sectionType = SettingSectionType(rawValue: section) else {
            return nil
        }
        
        return sectionType.title
    }
    
    func getRowTitle(with indexPath: IndexPath) -> String? {
        guard let sectionType = SettingSectionType(rawValue: indexPath.section),
                let rows = sectionsInfo[sectionType] else {
            return nil
        }
        
        return rows[indexPath.row].title
    }
    
    func getRowSecondaryTitle(with indexPath: IndexPath) -> String? {
        let rowType = getRowType(with: indexPath)
        switch rowType {
        case .appearance:
            return appearanceRelay.value.rawValue.localized()
            
        case .language:
            return Locale.current.languageCode
            
        case .removeAds:
            return PurchaseManager.shared.isSubscribedRelay.value ? "Subscribed".localized() : "Unsubscribed".localized()
            
        case .version:
#if RELEASE
                return Bundle.main.releaseVersionNumber
#else
                return "\(Bundle.main.releaseVersionNumber ?? "1.0.0")(\(Bundle.main.buildVersionNumber ?? "0"))"
#endif
            
        default:
            return nil
        }
    }
}
