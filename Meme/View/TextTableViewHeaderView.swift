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
        addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints {
            $0.left.right.equalToSuperview().inset(Constant.spacing3)
            $0.top.bottom.equalToSuperview()
        }
    }
}
