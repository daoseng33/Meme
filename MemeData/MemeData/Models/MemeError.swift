//
//  MemeError.swift
//  MemeData
//
//  Created by DAO on 2024/9/16.
//

import Foundation

public struct MemeError: Decodable {
    public let status: String
    public let message: String
    public let code: Int
}
