//
//  RandomJokeViewController.swift
//  Meme
//
//  Created by DAO on 2024/9/18.
//

import UIKit
import SnapKit
import RxCocoa
import SFSafeSymbols
import ProgressHUD
import StoreKit

final class RandomJokeViewController: BaseViewController {
    // MARK: - Properties
    private let viewModel: RandomJokeViewModelProtocol
    
    // MARK: - UI
    private let jokeTextView = ContentTextView()
    
    private let categorySelectedLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .label
        label.text = "\("Joke category".localized()):"
        label.lineBreakMode = .byTruncatingTail
        
        return label
    }()
    
    private lazy var categorySelectedButton = MenuButton(contentStrings: viewModel.categories,
                                                         arrowDirection: .up)
    
    private let actionsContainerView = ActionsContainerView()
    
    private let generateJokeButton: RoundedRectangleButton = {
        let button = RoundedRectangleButton()
        button.title = "Generate Joke".localized()
        button.titleColor = .white
        button.buttonBackgroundColor = .accent
        
        return button
    }()
    
    // MARK: - Init
    init(viewModel: RandomJokeViewModelProtocol) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupBinding()
        setupActions()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        viewModel.refreshData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        AnalyticsManager.shared.logScreenView(screenName: .randomJoke)
    }
    
    // MARK: - Setup
    private func setupUI() {
        navigationItem.title = "Random Joke".localized()
        
        let categorySelectedView = UIView()
        
        let stackView: UIStackView = {
           let stackView = UIStackView(arrangedSubviews: [
            jokeTextView,
            categorySelectedView,
            generateJokeButton
           ])
            stackView.axis = .vertical
            stackView.spacing = Constant.spacing2
            
            return stackView
        }()
        
        let categoryMenuStackView: UIStackView = {
            let stackView = UIStackView(arrangedSubviews: [
                categorySelectedLabel,
                categorySelectedButton
            ])
            stackView.axis = .horizontal
            stackView.spacing = Constant.spacing1
            
            return stackView
        }()
        
        categorySelectedLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        categorySelectedLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        
        categorySelectedButton.setContentCompressionResistancePriority(.required, for: .horizontal)
        categorySelectedButton.setContentHuggingPriority(.required, for: .horizontal)
        
        view.addSubview(stackView)
        categorySelectedView.addSubview(actionsContainerView)
        categorySelectedView.addSubview(categoryMenuStackView)
        
        stackView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.left.right.bottom.equalTo(view.safeAreaLayoutGuide).inset(Constant.spacing2)
        }
        
        generateJokeButton.snp.makeConstraints {
            $0.height.equalTo(50)
        }
        
        categorySelectedView.snp.makeConstraints {
            $0.height.equalTo(35)
        }
        
        actionsContainerView.snp.makeConstraints {
            $0.right.top.bottom.equalToSuperview()
            $0.width.greaterThanOrEqualTo(78)
        }
        
        categoryMenuStackView.snp.makeConstraints {
            $0.left.top.bottom.equalToSuperview()
            $0.right.lessThanOrEqualTo(actionsContainerView.snp.left).offset(-8)
        }
    }

    private func setupActions() {
        generateJokeButton.tapEvent
            .withUnretained(self)
            .subscribe(onNext: { (self, _) in
                self.viewModel.fetchData()
            })
            .disposed(by: rx.disposeBag)
        
        actionsContainerView.shareButton.rx.tap
            .withUnretained(self)
            .subscribe(onNext: { (self, _) in
                self.viewModel.shareButtonTappedRelay.accept(())
                let joke = self.viewModel.joke
                Utility.showShareSheet(items: [joke], parentVC: self) {
                    InAppReviewManager.shared.requestReview()
                }
            })
            .disposed(by: rx.disposeBag)
        
        actionsContainerView.favoriteButton.rx.tap
            .withUnretained(self)
            .subscribe(onNext: { (self, _) in
                self.viewModel.toggleIsFavorite()
                InAppReviewManager.shared.requestReview()
            })
            .disposed(by: rx.disposeBag)
    }
    
    private func setupBinding() {
        viewModel.jokeObservable
            .bind(to: jokeTextView.textBinder)
            .disposed(by: rx.disposeBag)
        
        viewModel.loadingStateDriver
            .drive(with: self, onNext: { (self, state) in
                switch state {
                case .initial, .loading:
                    self.generateJokeButton.isEnabled = false
                    self.actionsContainerView.shareButton.isEnabled = false
                    self.actionsContainerView.favoriteButton.isEnabled = false
                    ProgressHUD.animate("Loading".localized(), interaction: false)
                    
                case .success:
                    self.generateJokeButton.isEnabled = true
                    self.actionsContainerView.shareButton.isEnabled = true
                    self.actionsContainerView.favoriteButton.isEnabled = true
                    ProgressHUD.dismiss()
                    
                case .failure(let error):
                    self.generateJokeButton.isEnabled = true
                    self.actionsContainerView.shareButton.isEnabled = false
                    self.actionsContainerView.favoriteButton.isEnabled = false
                    ProgressHUD.dismiss()
                    GlobalErrorHandleManager.shared.popErrorAlert(error: error, presentVC: self) { [weak self] in
                        guard let self = self else { return }
                        self.viewModel.fetchData()
                    }
                }
            })
            .disposed(by: rx.disposeBag)
        
        categorySelectedButton.selectedOptionObservable
            .bind(to: viewModel.selectedCategoryObserver)
            .disposed(by: rx.disposeBag)
        
        viewModel.isFavoriteRelay
            .bind(to: actionsContainerView.favoriteButton.rx.isSelected)
            .disposed(by: rx.disposeBag)
    }
}
