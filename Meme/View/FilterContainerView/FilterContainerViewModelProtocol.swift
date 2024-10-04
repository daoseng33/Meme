//
//  FilterContainerViewModelProtocol.swift
//  Meme
//
//  Created by DAO on 2024/10/3.
//

import Foundation
import RxRelay

enum MenuDate: String, CaseIterable {
    case newest = "Newest"
    case oldest = "Oldest"
}

enum MenuCategory: String, CaseIterable {
    case all = "All"
    case meme = "Meme"
    case joke = "Joke"
    case gifs = "GIFs"
}

protocol FilterContainerViewModelProtocol {
    var selectedDateRelay: BehaviorRelay<MenuDate> { get }
    var selectedCategoryRelay: BehaviorRelay<MenuCategory> { get }
    var selectedDate: MenuDate { get }
    var selectedCategory: MenuCategory { get }
}
