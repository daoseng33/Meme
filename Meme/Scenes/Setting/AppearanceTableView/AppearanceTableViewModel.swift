//
//  AppearanceTableViewModel.swift
//  Meme
//
//  Created by DAO on 2024/10/11.
//

import Foundation
import RxSwift
import RxRelay

final class AppearanceTableViewModel {
    let appearanceRelay: BehaviorRelay<AppearanceStyle>
    let disposeBag = DisposeBag()
    
    init (appearance: AppearanceStyle) {
        appearanceRelay = BehaviorRelay(value: appearance)
    }
}
