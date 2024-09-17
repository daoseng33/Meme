//
//  BaseAPIServiceProtocol.swift
//  WebAPI
//
//  Created by DAO on 2024/9/17.
//

import Foundation

public protocol BaseAPIServiceProtocol {
    var useMockData: Bool { get }
    init(useMockData: Bool)
}
