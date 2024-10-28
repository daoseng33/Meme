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
    
    class func topViewController(controller: UIViewController? = nil) -> UIViewController? {
        let controller = controller ?? UIApplication.shared.connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .first(where: { $0 is UIWindowScene })
            .flatMap({ $0 as? UIWindowScene })?.windows
            .first(where: \.isKeyWindow)?
            .rootViewController
        
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController {
            return topViewController(controller: tabController.selectedViewController)
        }
        if let presentedController = controller?.presentedViewController {
            return topViewController(controller: presentedController)
        }
        return controller
    }

}
