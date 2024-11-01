//
//  SettingViewModel.swift
//  Meme
//
//  Created by DAO on 2024/10/11.
//

import Foundation
import RxRelay
import RxDataSources

enum SettingSectionType: Int, CaseIterable {
    case general
    case sponsor
    case term
    case about
    
    var title: String {
        switch self {
        case .general: return "General".localized()
        case .sponsor: return "Sponsor".localized()
        case .term: return "Term".localized()
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
    case privacyPolicy
    case termsofUse
    
    var title: String {
        switch self {
        case .appearance: return "Appearance".localized()
        case .language: return "Display Language".localized()
        case .removeAds: return "Remove Ads".localized()
        case .restorePurchases: return "Restore Purchases".localized()
        case .version: return "App Version".localized()
        case .contactUs: return "Contact Us".localized()
        case .privacyPolicy: return "Privacy Policy".localized()
        case .termsofUse: return "Terms of Use".localized()
        }
    }
}

struct SettingSection {
    var header: SettingSectionType
    var items: [SettingRowType]
}

extension SettingSection: SectionModelType {
    init(original: SettingSection, items: [SettingRowType]) {
        self = original
        self.items = items
    }
}

final class SettingViewModel {
    // MARK: - Properties
    let sectionsRelay: BehaviorRelay<[SettingSection]> = {
        let sections = [
            SettingSection(header: .general, items: [.appearance, .language]),
            SettingSection(header: .sponsor, items: [.removeAds, .restorePurchases]),
            SettingSection(header: .term, items: [.privacyPolicy, .termsofUse]),
            SettingSection(header: .about, items: [.contactUs, .version])
        ]
        
        return BehaviorRelay(value: sections)
    }()
    var dataSource: RxTableViewSectionedReloadDataSource<SettingSection>?
    lazy var appearanceTableViewModel = AppearanceTableViewModel(appearance: appearanceRelay.value)
    let appearanceRelay: BehaviorRelay<AppearanceStyle>
    let contactEmail: String = "contact@likeabossapp.com"
    let transparencyPolicyURL = URL(string: "https://likeabossapp.com/memepire-transparency-policy/")
    let termsOfUseURL = URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")
    
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
    func getRowType(with indexPath: IndexPath) -> SettingRowType {
        let item = sectionsRelay.value[indexPath.section].items[indexPath.row]
        
        return item
    }
    
    func getSectionTitle(with section: Int) -> String? {
        guard let sectionType = SettingSectionType(rawValue: section) else {
            return nil
        }
        
        return sectionType.title
    }
    
    func getRowTitle(with indexPath: IndexPath) -> String? {
        let itemTitle = sectionsRelay.value[indexPath.section].items[indexPath.row].title
        
        return itemTitle
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
