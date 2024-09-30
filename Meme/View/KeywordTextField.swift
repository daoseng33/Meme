//
//  KeywordTextField.swift
//  Meme
//
//  Created by DAO on 2024/9/18.
//

import UIKit
import RxCocoa
import SnapKit

final class KeywordTextField: UIView {
    // MARK: - UI
    private let textField: UITextField = {
        let textField = UITextField()
        textField.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        textField.textColor = .label
        textField.backgroundColor = .secondarySystemBackground
        textField.placeholder = "\("Key in keyword".localized())(\("Optional".localized()))"
        textField.layer.cornerRadius = 4
        textField.clipsToBounds = true
        textField.returnKeyType = .done
        textField.clearButtonMode = .whileEditing
        textField.setInsets(left: 8, right: nil)
        
        return textField
    }()
    
    var textBinder: ControlProperty<String?> {
        return textField.rx.text
    }
    
    // MARK: - Init
    init () {
        super.init(frame: .zero)
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setup () {
        addSubview(textField)
        textField.snp.makeConstraints{
            $0.edges.equalToSuperview()
        }
    }
}
