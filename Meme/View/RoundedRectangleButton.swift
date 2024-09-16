//
//  RoundedRectangleButton.swift
//  Meme
//
//  Created by DAO on 2024/9/10.
//

import UIKit
import SnapKit
import RxCocoa
import IQKeyboardManagerSwift

final class RoundedRectangleButton: UIView {
    // MARK: - Properties
    var title: String? {
        didSet {
            button.setTitle(title, for: .normal)
        }
    }
    
    var titleColor: UIColor? {
        didSet {
            button.setNeedsUpdateConfiguration()
        }
    }
    
    var buttonBackgroundColor: UIColor? {
        didSet {
            button.setNeedsUpdateConfiguration()
        }
    }
    
    lazy var tapEvent: ControlEvent<Void> = {
        let tapObservable = button.rx.tap
            .do(onNext: { _ in
                IQKeyboardManager.shared.resignFirstResponder()
            })
        
        return ControlEvent(events: tapObservable)
    }()
    
    var isEnabled: Bool = true {
        didSet {
            button.isEnabled = isEnabled
        }
    }
    
    // MARK: - UI
    private lazy var button: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 10
        button.clipsToBounds = true
        button.titleLabel?.font = UIFont.systemFont(ofSize: 24, weight: .medium)
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.titleLabel?.minimumScaleFactor = 0.5
        button.configuration = UIButton.Configuration.filled()
        button.configurationUpdateHandler = { [weak self] button in
            guard let self = self else { return }
            var config = button.configuration
            switch button.state {
            case .normal:
                config?.background.backgroundColor = buttonBackgroundColor
                config?.baseForegroundColor = titleColor
                
            case .disabled:
                config?.background.backgroundColor = .systemGray5
                config?.baseForegroundColor = .gray
                
            case .highlighted:
                config?.background.backgroundColor = buttonBackgroundColor?.withAlphaComponent(0.8)
                config?.baseForegroundColor = titleColor?.withAlphaComponent(0.8)
                
            default:
                break
            }
            button.configuration = config
        }
        
        return button
    }()
    
    // MARK: - Init
    init() {
        super.init(frame: .zero)
        
        setup()
    }
    
    convenience init(title: String? = nil, titleColor: UIColor? = nil, backgroundColor: UIColor? = nil) {
        self.init()
        
        self.title = title
        self.titleColor = titleColor
        self.buttonBackgroundColor = backgroundColor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setup() {
        addSubview(button)
        button.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}
