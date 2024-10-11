//
//  SettingViewModel.swift
//  Meme
//
//  Created by DAO on 2024/10/11.
//

import Foundation
import RxRelay

enum SettingSectionType: String {
    case general = "General"
    case sponsor = "Sponsor"
    case about = "About"
}

enum SettingRowType: String {
    case appearance = "Appearance"
    case language = "Display Language"
    case removeAds = "Remove Ads"
    case restorePurchases = "Restore Purchases"
    case version = "App Version"
    case contactUs = "Contact Us"
}

final class SettingViewModel {
    // MARK: - Properties
    lazy var appearanceTableViewModel = AppearanceTableViewModel(appearance: appearanceRelay.value)
    let appearanceRelay: BehaviorRelay<AppearanceStyle>
    
    private let sectionTypeDict: IndexedDictionary<SettingSectionType, [SettingRowType]> = {
        var sections = IndexedDictionary<SettingSectionType, [SettingRowType]>()
        sections[.general] = [.appearance, .language]
        sections[.sponsor] = [.removeAds, .restorePurchases]
        sections[.about] = [.contactUs, .version]
        
        return sections
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
        sectionTypeDict.keys.count
    }
    
    func getNumberOfRows(in section: Int) -> Int {
        sectionTypeDict[getSectionType(with: section)]?.count ?? 0
    }
    
    func getSectionType(with section: Int) -> SettingSectionType {
        switch section {
        case sectionTypeDict.index(forKey: .general):
            return .general
            
        case sectionTypeDict.index(forKey: .sponsor):
            return .sponsor
            
        case sectionTypeDict.index(forKey: .about):
            return .about
            
        default:
            print("Invalid section: \(section).")
            return .general
        }
    }
    
    func getRowType(with indexPath: IndexPath) -> SettingRowType? {
        switch indexPath.section {
        case sectionTypeDict.index(forKey: .general):
            return sectionTypeDict[.general]?[indexPath.row]
            
        case sectionTypeDict.index(forKey: .sponsor):
            return sectionTypeDict[.sponsor]?[indexPath.row]
            
        case sectionTypeDict.index(forKey: .about):
            return sectionTypeDict[.about]?[indexPath.row]
            
        default:
            print("Invalid row: \(indexPath).")
            return nil
        }
    }
    
    func getSectionTitle(with section: Int) -> String? {
        switch section {
        case sectionTypeDict.index(forKey: .general):
            return SettingSectionType.general.rawValue.localized()
            
        case sectionTypeDict.index(forKey: .sponsor):
            return SettingSectionType.sponsor.rawValue.localized()
            
        case sectionTypeDict.index(forKey: .about):
            return SettingSectionType.about.rawValue.localized()
            
        default:
            print("Invalid section: \(section).")
            return nil
        }
    }
    
    func getRowTitle(with indexPath: IndexPath) -> String? {
        switch indexPath.section {
        case sectionTypeDict.index(forKey: .general):
            return sectionTypeDict[.general]?[indexPath.row].rawValue.localized()
            
        case sectionTypeDict.index(forKey: .sponsor):
            return sectionTypeDict[.sponsor]?[indexPath.row].rawValue.localized()
            
        case sectionTypeDict.index(forKey: .about):
            return sectionTypeDict[.about]?[indexPath.row].rawValue.localized()
            
        default:
            print("Invalid row: \(indexPath).")
            return nil
        }
    }
    
    func getRowSecondaryTitle(with indexPath: IndexPath) -> String? {
        let rowType = getRowType(with: indexPath)
        switch rowType {
        case .appearance:
            return appearanceRelay.value.rawValue.localized()
            
        case .language:
            return Locale.current.languageCode
            
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
