//
//  RandomMeme.swift
//  MemeData
//
//  Created by DAO on 2024/8/31.
//

import Foundation

public struct RandomMeme: Decodable {
    public let id: Int
    public let description: String
    public let url: String
    public let type: String
}
