//
//  GridData.swift
//  Meme
//
//  Created by DAO on 2024/9/9.
//

import UIKit

struct GridData {
    let title: String
    let imageType: GridImageType
}

enum GridImageType {
    case `static`(image: UIImage)
    case gif(fileName: String)
}
