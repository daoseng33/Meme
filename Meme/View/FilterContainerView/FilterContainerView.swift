//
//  FilterContainerView.swift
//  Meme
//
//  Created by DAO on 2024/10/3.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class FilterContainerView: UIView {
    // MARK: - Properties
    private let viewModel: FilterContainerViewModelProtocol
    
    // MARK: - UI
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.text = "\("Ordering".localized()):"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .label
        
        return label
    }()
    
    private let dateMenuButton: MenuButton = {
        let contentStrings = MenuDate.allCases.map(\.rawValue)
        let button = MenuButton(contentStrings: contentStrings, arrowDirection: .down)
        
        return button
    }()
    
    private let categoryLabel: UILabel = {
        let label = UILabel()
        label.text = "\("Category".localized()):"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .label
        
        return label
    }()
    
    private let categoryMenuButton: MenuButton = {
        let contentStrings = MenuCategory.allCases.map(\.rawValue)
        let button = MenuButton(contentStrings: contentStrings, arrowDirection: .down)
        
        return button
    }()
    
    // MARK: - Init
    init(viewModel: FilterContainerViewModelProtocol) {
        self.viewModel = viewModel
        
        super.init(frame: .zero)
        
        setupUI()
        setupBinding()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupUI() {
        backgroundColor = .secondarySystemBackground
        
        let stackView: UIStackView = {
            let stackView = UIStackView(arrangedSubviews: [
                dateLabel,
                dateMenuButton,
                categoryLabel,
                categoryMenuButton
            ])
            stackView.axis = .horizontal
            stackView.spacing = Constant.spacing1
            
            return stackView
        }()
        
        addSubview(stackView)
        stackView.snp.makeConstraints {
            $0.centerX.centerY.equalToSuperview()
        }
    }
    
    private func setupBinding() {
        dateMenuButton.selectedOptionObservable
            .compactMap { MenuDate(rawValue: $0) }
            .bind(to: viewModel.selectedDateRelay)
            .disposed(by: rx.disposeBag)
        
        categoryMenuButton.selectedOptionObservable
            .compactMap { MenuCategory(rawValue: $0) }
            .bind(to: viewModel.selectedCategoryRelay)
            .disposed(by: rx.disposeBag)
    }
}
