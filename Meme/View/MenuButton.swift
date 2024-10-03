//
//  MenuButton.swift
//  Meme
//
//  Created by DAO on 2024/10/3.
//

import UIKit
import SnapKit
import RxSwift
import RxRelay
import RxCocoa
import SFSafeSymbols

enum MenuButtonArrowDirection {
    case up
    case down
}

final class MenuButton: UIView {
    // MARK: - Properties
    private var _contentStrings: [String] = []
    
    var contentStrings: [String] {
        get {
            _contentStrings
        }
        
        set {
            if selectedOption.isEmpty, let firstItem = newValue.first {
                selectedOptionRelay.accept(firstItem)
            }
            
            let actions = newValue.map { option in
                UIAction(title: option.localized()) { action in
                    self.selectedOptionRelay.accept(option)
                }
            }

            button.menu = UIMenu(children: actions)
            
            _contentStrings = newValue
        }
    }
    
    private var _arrowDirection: MenuButtonArrowDirection = .up
    
    var arrowDirection: MenuButtonArrowDirection {
        get {
            _arrowDirection
        }
        
        set {
            let image: UIImage
            let symbolConfig = UIImage.SymbolConfiguration(pointSize: 12, weight: .black)
            switch newValue {
            case .up:
                image = UIImage(systemSymbol: .chevronUpCircleFill,
                                    withConfiguration: symbolConfig)
                    .withTintColor(.accent, renderingMode: .alwaysOriginal)
                
            case .down:
                image = UIImage(systemSymbol: .chevronDownCircleFill,
                                    withConfiguration: symbolConfig)
                    .withTintColor(.accent, renderingMode: .alwaysOriginal)
            }
            
            button.configuration?.image = image
            
            _arrowDirection = newValue
        }
    }
    
    private lazy var selectedOptionRelay = BehaviorRelay<String>(value: contentStrings.first ?? "")
    
    var selectedOption: String {
        selectedOptionRelay.value
    }
    
    var selectedOptionObservable: Observable<String> {
        selectedOptionRelay.asObservable()
    }
    
    // MARK: - UI
    private lazy var button: UIButton = {
        let button = UIButton()
        
        var config: UIButton.Configuration = {
            var config = UIButton.Configuration.filled()
            config.imagePlacement = .trailing
            config.imagePadding = Constant.spacing1
            config.baseForegroundColor = .label
            config.baseBackgroundColor = .secondarySystemBackground
            config.contentInsets.leading = Constant.spacing2
            config.contentInsets.trailing = Constant.spacing2
            config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
                var outgoing = incoming
                outgoing.font = .systemFont(ofSize: 16, weight: .medium)
                return outgoing
            }
            
            return config
        }()
        
        button.showsMenuAsPrimaryAction = true
        
        button.configuration = config
        
        return button
    }()
    
    // MARK: - Init
    init(contentStrings: [String] = [], arrowDirection: MenuButtonArrowDirection = .up) {
        super.init(frame: .zero)
        
        self.contentStrings = contentStrings
        self.arrowDirection = arrowDirection
        
        setupUI()
        setupObservable()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupUI() {
        addSubview(button)
        
        button.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    private func setupObservable() {
        selectedOptionRelay
            .asDriver()
            .drive(with: self) { (self, option) in
                self.button.configuration?.title = option.localized()
                self.button.menu?.children.forEach({ item in
                    guard let action = item as? UIAction else { return }
                    action.state = action.title == option.localized() ? .on : .off
                })
            }
            .disposed(by: rx.disposeBag)
    }
}
