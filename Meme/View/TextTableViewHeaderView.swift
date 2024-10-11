//
//  TextTableViewHeaderView.swift
//  Meme
//
//  Created by DAO on 2024/10/4.
//

import UIKit
import SnapKit

final class TextTableViewHeaderView: UIView {
    // MARK: - Properties
    var text: String? {
        get {
            titleLabel.text
        }
        
        set {
            titleLabel.text = newValue
        }
    }
    
    private var _padding: CGFloat = 0
    
    var padding: CGFloat {
        get {
            return _padding
        }
        
        set {
            titleLabel.snp.updateConstraints {
                $0.left.right.equalToSuperview().inset(newValue)
            }
            
            _padding = newValue
        }
    }
    
    // MARK: - UI
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .bold)
        label.textColor = .systemGray
        
        return label
    }()
    
    // MARK: - Init
    init(text: String? = nil) {
        super.init(frame: .zero)
        
        self.text = text
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupUI() {
        backgroundColor = .secondarySystemBackground
        addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints {
            $0.left.right.equalToSuperview()
            $0.top.bottom.equalToSuperview()
        }
    }
}
