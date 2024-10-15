//
//  UIApplicationExtension.swift
//  Meme
//
//  Created by DAO on 2024/10/15.
//

import Foundation
import UIKit

extension UIApplication {
    static var activeScene: UIWindowScene? {
        return shared.connectedScenes
            .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene
    }
}
