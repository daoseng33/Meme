//
//  GridData.swift
//  Meme
//
//  Created by DAO on 2024/9/9.
//

import UIKit
import Differentiator

struct GridData {
    let title: String?
    let imageType: GridImageType
    var isFavorite: Bool = false
}

extension GridData: IdentifiableType, Equatable {
    typealias Identity = String
    
    var identity: String {
        switch self.imageType {
        case .gif(let url):
            return url.absoluteString
            
        case .static:
            return title ?? ""
        }
    }
    
    static func == (lhs: GridData, rhs: GridData) -> Bool {
        if case .gif(let lhsURL) = lhs.imageType, case .gif(let rhsURL) = rhs.imageType {
            return lhsURL == rhsURL
        } else {
            return lhs.title == rhs.title
        }
    }
}

enum GridImageType {
    case `static`(image: UIImage)
    case gif(url: URL)
}
