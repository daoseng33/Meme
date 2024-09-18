//
//  LoadingStateProtocol.swift
//  Meme
//
//  Created by DAO on 2024/9/18.
//

import Foundation
import RxSwift

enum LoadingState: Equatable {
    case initial
    case loading
    case success
    case failure(error: Error)
    
    static func == (lhs: LoadingState, rhs: LoadingState) -> Bool {
        switch (lhs, rhs) {
        case (.initial, .initial),
             (.loading, .loading),
             (.success, .success):
            return true
            
        case let (.failure(lhsError), .failure(rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription
            
        default:
            return false
        }
    }
}


protocol LoadingStateProtocol {
    var loadingState: LoadingState { get }
    var loadingStateObservable: Observable<LoadingState> { get }
}
