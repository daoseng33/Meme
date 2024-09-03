//
//  APIErrorHandleManager.swift
//  WebAPI
//
//  Created by DAO on 2024/9/2.
//

import Foundation
import RxSwift
import Moya

public class APIErrorHandleManager {
    public static let shared = APIErrorHandleManager()
    
    public let httpErrorHandler = PublishSubject<Int>()
    public let requestErrorHandler = PublishSubject<Error>()
    
    private init() {}
}


