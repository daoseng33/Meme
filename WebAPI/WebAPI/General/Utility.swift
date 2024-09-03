//
//  Utility.swift
//  WebAPI
//
//  Created by DAO on 2024/9/3.
//

import Foundation

struct Utility {
    static func loadJSON(filename: String) -> Data {
        guard let path = Bundle(identifier: "com.likeabossapp.WebAPI")?.path(forResource: filename, ofType: "json"),
           let data = try? Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe) else {
            return Data()
        }
        
        return data
    }
}
