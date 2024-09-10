//
//  RoundedRectangleButton.swift
//  Meme
//
//  Created by DAO on 2024/9/10.
//

import UIKit

class RoundedRectangleButton: UIButton {
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: .zero)
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setup() {
        layer.cornerRadius = 10
        clipsToBounds = true
        titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        setTitleColor(.systemGray6, for: .disabled)
    }
}
