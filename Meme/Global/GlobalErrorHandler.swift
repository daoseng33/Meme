//
//  GlobalErrorHandler.swift
//  Meme
//
//  Created by DAO on 2024/9/3.
//

import Foundation
import WebAPI
import RxSwift

final class GlobalErrorHandler {
    
    private let disposeBag = DisposeBag()
    
    func handleError() {
        APIErrorHandleManager.shared.httpErrorHandler
            .withUnretained(self)
            .subscribe(onNext: { `self`, statusCode in
                self.handleHttpError(statusCode: statusCode)
            })
            .disposed(by: disposeBag)
        
        APIErrorHandleManager.shared.requestErrorHandler
            .withUnretained(self)
            .subscribe(onNext: { `self`, error in
                self.handleNetworkRequestError(error)
            })
            .disposed(by: disposeBag)
    }
    
    private func handleHttpError(statusCode: Int) {
        switch statusCode {
        case 400:
            print("Bad Request")
        case 401:
            print("Unauthorized")
        case 404:
            print("Not Found")
        case 500:
            print("Internal Server Error")
        default:
            print("Unexpected error: \(statusCode)")
        }
    }

    private func handleNetworkRequestError(_ error: Error) {
        print("Network error occurred: \(error.localizedDescription)")
    }
}
