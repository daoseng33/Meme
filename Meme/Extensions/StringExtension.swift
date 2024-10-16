//
//  StringExtension.swift
//  Meme
//
//  Created by DAO on 2024/9/12.
//

import Foundation

extension String {
    func localized() -> String {
        return String(localized: LocalizationValue(self))
    }
    
    func camelCaseToSnakeCase() -> String {
        let acronymPattern = "([A-Z]+)([A-Z][a-z]|[0-9])"
        let normalPattern = "([a-z0-9])([A-Z])"
        return self.processCamelCase(pattern: acronymPattern)?
            .processCamelCase(pattern: normalPattern)?
            .lowercased() ?? self.lowercased()
    }
    
    private func processCamelCase(pattern: String) -> String? {
        let regex = try? NSRegularExpression(pattern: pattern, options: [])
        let range = NSRange(location: 0, length: self.count)
        return regex?.stringByReplacingMatches(in: self, options: [], range: range, withTemplate: "$1_$2")
    }
    
    func camelCaseToTitleCase() -> String {
        guard !isEmpty else { return self }
        
        var result = ""
        let characters = Array(self)
        
        // Handle the first character
        result.append(characters[0].uppercased())
        
        // Process the remaining characters
        for i in 1..<characters.count {
            if characters[i].isUppercase {
                result.append(" ")
                result.append(characters[i])
            } else {
                result.append(characters[i].lowercased())
            }
        }
        
        // Capitalize the first letter of each word
        return result.capitalized
    }
}
