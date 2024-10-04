//
//  FilterContainerViewModel.swift
//  Meme
//
//  Created by DAO on 2024/10/3.
//

import Foundation
import RxRelay

final class FilterContainerViewModel: FilterContainerViewModelProtocol {
    var selectedDate: MenuDate {
        selectedDateRelay.value
    }
    
    var selectedCategory: MenuCategory {
        selectedCategoryRelay.value
    }
    
    let selectedDateRelay = BehaviorRelay<MenuDate>(value: .newest)
    let selectedCategoryRelay = BehaviorRelay<MenuCategory>(value: .all)
}
