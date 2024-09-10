//
//  GridData.swift
//  Meme
//
//  Created by DAO on 2024/9/9.
//

import UIKit

struct GridData {
    let title: String
    let image: UIImage
    let imageType: GridImageType
}

enum GridImageType {
    case `static`
    case gif
}
