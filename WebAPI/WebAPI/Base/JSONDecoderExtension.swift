//
//  JSONDecoderExtension.swift
//  Meme
//
//  Created by DAO on 2024/8/30.
//

import Foundation

extension JSONDecoder {
    static let `default`: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()
}
