//
//  GIFsViewController.swift
//  Meme
//
//  Created by DAO on 2024/9/22.
//

import UIKit
import SnapKit
import RxCocoa

final class GIFsViewController: BaseViewController {
    // MARK: - Properties
    private let viewModel: GIFsViewModelProtocol
    private lazy var gridCollectionView = GridCollectionView(viewModel: viewModel.gridCollectionViewModel)
    private let keywordTextField = KeywordTextField()
    private let generateGifsButton: RoundedRectangleButton = {
        let button = RoundedRectangleButton()
        button.title = "Generate GIFs".localized()
        button.titleColor = .white
        button.buttonBackgroundColor = .systemIndigo
        
        return button
    }()
    
    // MARK: - Init
    init(viewModel: GIFsViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupBinding()
        setupActions()
        viewModel.loadFirstDataIfNeeded()
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        navigationBar.topItem?.title = "GIFs".localized()
        
        view.addSubview(gridCollectionView)
        gridCollectionView.snp.makeConstraints {
            $0.top.equalTo(navigationBar.snp.bottom)
            $0.left.right.equalToSuperview()
        }
        
        let stackView: UIStackView = {
            let stackView = UIStackView(arrangedSubviews: [keywordTextField, generateGifsButton])
            stackView.axis = .vertical
            stackView.spacing = Constant.spacing2
            
            return stackView
        }()
        
        view.addSubview(stackView)
        stackView.snp.makeConstraints {
            $0.top.equalTo(gridCollectionView.snp.bottom).offset(Constant.spacing1)
            $0.left.right.bottom.equalTo(view.safeAreaLayoutGuide).inset(Constant.spacing2)
        }
        
        generateGifsButton.snp.makeConstraints {
            $0.height.equalTo(50)
        }
        
        keywordTextField.snp.makeConstraints {
            $0.height.equalTo(35)
        }
    }
    
    private func setupBinding() {
        viewModel.keyword
            .bind(to: keywordTextField.textBinder)
            .disposed(by: rx.disposeBag)
        
        keywordTextField.textBinder
            .bind(to: viewModel.keywordObserver)
            .disposed(by: rx.disposeBag)
        
        viewModel.loadingStateObservable
            .asDriver(onErrorJustReturn: .initial)
            .drive(with: self, onNext: { (self, state) in
                switch state {
                case .initial, .loading:
                    self.keywordTextField.isUserInteractionEnabled = false
                    self.generateGifsButton.isEnabled = false
                case .success:
                    self.keywordTextField.isUserInteractionEnabled = true
                    self.generateGifsButton.isEnabled = true
                case .failure(error: let error):
                    self.keywordTextField.isUserInteractionEnabled = true
                    self.generateGifsButton.isEnabled = true
                }
            })
            .disposed(by: rx.disposeBag)
    }
    
    private func setupActions() {
        generateGifsButton.tapEvent
            .withUnretained(self)
            .subscribe(onNext: { (self, _) in
                self.viewModel.fetchGIFs()
            })
            .disposed(by: rx.disposeBag)
    }
}
