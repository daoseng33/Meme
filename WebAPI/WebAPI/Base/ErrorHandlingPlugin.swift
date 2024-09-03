//
//  ErrorHandlingPlugin.swift
//  WebAPI
//
//  Created by DAO on 2024/9/2.
//

import Foundation
import Moya

class ErrorHandlingPlugin: PluginType {
    func didReceive(_ result: Result<Response, MoyaError>, target: TargetType) {
        switch result {
        case .success(let response):
            if (200...299).contains(response.statusCode) {
                print("Request successful: \(response)")
            } else {
                APIErrorHandleManager.shared.httpErrorHandler.onNext(response.statusCode)
            }
        case .failure(let error):
            APIErrorHandleManager.shared.requestErrorHandler.onNext(error)
        }
    }
}
