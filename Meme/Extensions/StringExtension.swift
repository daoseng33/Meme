//
//  StringExtension.swift
//  Meme
//
//  Created by DAO on 2024/9/12.
//

import Foundation

extension String {
    func localized() -> String {
        return NSLocalizedString(self, comment: "")
    }
}
