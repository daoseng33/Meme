//
//  EmptyContentView.swift
//  Meme
//
//  Created by DAO on 2024/10/21.
//

import UIKit
import SnapKit

final class EmptyContentView: UIView {
    // MARK: - Properties
    private let viewModel: EmptyContentViewModelProtocol
    
    // MARK: - UI
    private let emptyImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = Asset.memeDogeDog.image
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let actionButton: RoundedRectangleButton = {
        let button = RoundedRectangleButton(title: "Go get some fun".localized())
        
        return button
    }()
    
    // MARK: - Init
    init(viewModel: EmptyContentViewModelProtocol) {
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
        let stackView: UIStackView = {
            let stackView = UIStackView(arrangedSubviews: [emptyImageView, actionButton])
            stackView.axis = .vertical
            stackView.spacing = Constant.UI.spacing5
            return stackView
        }()
        
        addSubview(stackView)
        stackView.snp.makeConstraints {
            $0.centerX.centerY.equalToSuperview()
        }
        
        emptyImageView.snp.makeConstraints {
            $0.height.width.equalTo(200)
        }
        
        actionButton.snp.makeConstraints {
            $0.height.equalTo(44)
        }
    }
    
    private func setupBinding() {
        actionButton.tapEvent
            .bind(to: viewModel.actionButtonRelay)
            .disposed(by: rx.disposeBag)
    }
}
