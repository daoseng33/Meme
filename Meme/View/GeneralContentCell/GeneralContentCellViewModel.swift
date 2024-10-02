//
//  GeneralContentCellViewModel.swift
//  Meme
//
//  Created by DAO on 2024/10/1.
//

import Foundation
import RxRelay

final class GeneralContentCellViewModel: GeneralContentCellViewModelProtocol {
    // MARK: - Properties
    var content: GeneralContentCellType
    var shareButtonTappedRelay = PublishRelay<GeneralContentCellType>()
    var imageTappedRelay = PublishRelay<URL>()
    
    // MARK: - Init
    init(content: GeneralContentCellType) {
        self.content = content
    }
}
