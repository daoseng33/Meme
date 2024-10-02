//
//  ContentTextView.swift
//  Meme
//
//  Created by DAO on 2024/9/18.
//

import UIKit
import RxCocoa
import SnapKit

final class ContentTextView: UIView {
    // MARK: - UI
    private let textView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        textView.textColor = .label
        textView.isEditable = false
        textView.backgroundColor = .clear
        
        return textView
    }()
    
    var enableScroll: Bool {
        get { textView.isScrollEnabled }
        set { textView.isScrollEnabled = newValue }
    }
    
    var text: String? {
        get { textView.text }
        set { textView.text = newValue }
    }
    
    var textBinder: ControlProperty<String?> {
        return textView.rx.text
    }
    
    // MARK: - Init
    init() {
        super.init(frame: .zero)
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setup() {
        addSubview(textView)
        textView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}
