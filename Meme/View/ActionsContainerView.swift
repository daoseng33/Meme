//
//  ActionsContainerView.swift
//  Meme
//
//  Created by DAO on 2024/10/5.
//

import UIKit
import SFSafeSymbols
import SnapKit

final class ActionsContainerView: UIView {
    // MARK: - UI
    let shareButton: UIButton = {
        let button = UIButton()
        button.setImage(Asset.Global.share.image, for: .normal)
        
        return button
    }()
    
    let favoriteButton: UIButton = {
        let button = UIButton()
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 25, weight: .regular)
        let image = UIImage(systemSymbol: .heart, withConfiguration: symbolConfig).withRenderingMode(.alwaysOriginal).withTintColor(.systemPink)
        button.setImage(image, for: .normal)
        let selectedImage = UIImage(systemSymbol: .heartFill, withConfiguration: symbolConfig).withRenderingMode(.alwaysOriginal).withTintColor(.systemPink)
        button.setImage(selectedImage, for: .selected)
        button.isSelected = false
        
        return button
    }()
    
    // MARK: - Init
    init() {
        super.init(frame: .zero)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupUI() {
        let actionsStackView: UIStackView = {
            let stackView = UIStackView(arrangedSubviews: [favoriteButton, shareButton])
            stackView.spacing = Constant.spacing2
            stackView.axis = .horizontal
            
            return stackView
        }()
        
        addSubview(actionsStackView)
        actionsStackView.snp.makeConstraints {
            $0.right.top.bottom.equalToSuperview()
            $0.left.lessThanOrEqualToSuperview().priority(.high)
        }
        
        favoriteButton.snp.makeConstraints {
            $0.width.equalTo(35)
        }
        
        shareButton.snp.makeConstraints {
            $0.width.equalTo(35)
        }
    }
}
