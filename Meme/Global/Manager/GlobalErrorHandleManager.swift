//
//  GlobalErrorHandleManager.swift
//  Meme
//
//  Created by DAO on 2024/9/3.
//

import Foundation
import HumorAPIService
import RxSwift
import UIKit

final class GlobalErrorHandleManager {
    // MARK: - Properties
    static let shared = GlobalErrorHandleManager()
    
    private let disposeBag = DisposeBag()
    
    // MARK: - Init
    private init() {}
    
    // MARK: - Error handler
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
    
    func popErrorAlert(error: Error, presentVC: UIViewController, handler: @escaping (() -> Void)) {
        let alert = UIAlertController(title: "Something went wrong".localized(), message: error.localizedDescription, preferredStyle: .alert)
        
        let retryAction = UIAlertAction(title: "Retry".localized(), style: .default) { _ in
            handler()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel".localized(), style: .cancel)
        
        retryAction.setValue(UIColor.accent, forKey: Constant.Key.titleTextColor)
        cancelAction.setValue(UIColor.accent, forKey: Constant.Key.titleTextColor)
        
        alert.addAction(cancelAction)
        alert.addAction(retryAction)
        
        presentVC.present(alert, animated: true)
    }
}
