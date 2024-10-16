//
//  AuthorizationStatusExtension.swift
//  Meme
//
//  Created by DAO on 2024/10/16.
//

import Foundation
import AppTrackingTransparency

extension ATTrackingManager.AuthorizationStatus {
    var statusString: String {
        switch self {
        case .notDetermined:
            return "Not Determined"
        case .restricted:
            return "Restricted"
        case .denied:
            return "Denied"
        case .authorized:
            return "Authorized"
        @unknown default:
            return "Unknown"
        }
    }
}
