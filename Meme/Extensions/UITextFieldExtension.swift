//
//  UITextFieldExtension.swift
//  Meme
//
//  Created by DAO on 2024/9/16.
//

import UIKit

extension UITextField {
    func setInsets(left: CGFloat?, right: CGFloat?) {
        if let left = left {
            let leftPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: left, height: self.frame.height))
            self.leftView = leftPaddingView
            self.leftViewMode = .always
        }
        
        if let right = right {
            let rightPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: right, height: self.frame.height))
            self.rightView = rightPaddingView
            self.rightViewMode = .always
        }
    }
}
