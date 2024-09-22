//
//  ImageData.swift
//  MemeData
//
//  Created by DAO on 2024/9/22.
//

import Foundation

public struct ImageData: Decodable {
    public let url: URL?
    public let width: Int
    public let height: Int
}
