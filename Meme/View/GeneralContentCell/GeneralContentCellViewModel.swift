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
    let createdAt: Date
    
    // MARK: - Init
    init(content: GeneralContentCellType, createdAt: Date) {
        self.content = content
        self.createdAt = createdAt
    }
}
