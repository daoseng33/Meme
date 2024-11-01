//
//  AppearanceTableViewModel.swift
//  Meme
//
//  Created by DAO on 2024/10/11.
//

import Foundation
import RxSwift
import RxRelay
import RxDataSources

struct AppearanceSection {
    var items: [String]
}

extension AppearanceSection: SectionModelType {
    init(original: AppearanceSection, items: [String]) {
        self = original
        self.items = items
    }
}

final class AppearanceTableViewModel {
    var dataSource: RxTableViewSectionedReloadDataSource<AppearanceSection>?
    
    let appearanceRelay: BehaviorRelay<AppearanceStyle>
    let sectionsRelay: BehaviorRelay<[AppearanceSection]> = {
        let styleStrings = AppearanceStyle.allCases.map { $0.rawValue }
        let sections = [AppearanceSection(items: styleStrings)]
        return BehaviorRelay<[AppearanceSection]>(value: sections)
    }()
    
    let disposeBag = DisposeBag()
    
    init (appearance: AppearanceStyle) {
        appearanceRelay = BehaviorRelay(value: appearance)
    }
}
