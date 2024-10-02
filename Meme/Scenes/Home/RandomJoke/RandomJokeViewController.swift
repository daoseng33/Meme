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
        
        return label
    }()
    
    private lazy var categorySelectedButton: UIButton = {
        let button = UIButton()
        
        var config: UIButton.Configuration = {
            var config = UIButton.Configuration.filled()
            config.title = viewModel.selectedCategory.rawValue.localized()
            let symbolConfig = UIImage.SymbolConfiguration(pointSize: 12, weight: .black)
            let image = UIImage(systemSymbol: .chevronUpCircleFill, withConfiguration: symbolConfig).withTintColor(.accent, renderingMode: .alwaysOriginal)
            config.image = image
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
        
        let actions = viewModel.categories.map { [weak viewModel] option in
            UIAction(title: option.localized()) { [weak button] _ in
                button?.configuration?.title = option.localized()
                viewModel?.selectedCategoryObserver.onNext(option)
            }
        }

        button.menu = UIMenu(children: actions)
        button.showsMenuAsPrimaryAction = true
        
        button.configuration = config
        
        return button
    }()
    
    private let shareButton: UIButton = {
        let button = UIButton()
        button.setImage(Asset.Global.share.image, for: .normal)
        
        return button
    }()
    
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
        viewModel.loadFirstMemeIfNeeded()
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
        
        view.addSubview(stackView)
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
        
        categorySelectedView.addSubview(shareButton)
        shareButton.snp.makeConstraints {
            $0.width.equalTo(35)
            $0.right.top.bottom.equalToSuperview()
        }
        
        categorySelectedView.addSubview(categorySelectedLabel)
        categorySelectedLabel.snp.makeConstraints {
            $0.top.left.bottom.equalToSuperview()
        }
        
        categorySelectedView.addSubview(categorySelectedButton)
        categorySelectedButton.snp.makeConstraints {
            $0.left.equalTo(categorySelectedLabel.snp.right).offset(Constant.spacing1)
            $0.top.bottom.equalToSuperview()
            $0.right.lessThanOrEqualTo(shareButton.snp.left)
        }
    }

    private func setupActions() {
        generateJokeButton.tapEvent
            .withUnretained(self)
            .subscribe(onNext: { (self, _) in
                self.generateJokeButton.isEnabled = false
                self.viewModel.fetchRandomJoke()
            })
            .disposed(by: rx.disposeBag)
        
        shareButton.rx.tap
            .withUnretained(self)
            .subscribe(onNext: { (self, _) in
                let joke = self.viewModel.joke
                Utility.showShareSheet(items: [joke], parentVC: self)
            })
            .disposed(by: rx.disposeBag)
    }
    
    private func setupBinding() {
        viewModel.jokeObservable
            .bind(to: jokeTextView.textBinder)
            .disposed(by: rx.disposeBag)
        
        viewModel.loadingStateObservable
            .asDriver(onErrorJustReturn: .initial)
            .drive(onNext: { state in
                switch state {
                case .initial, .loading:
                    self.generateJokeButton.isEnabled = false
                case .success:
                    self.generateJokeButton.isEnabled = true
                    
                case .failure(let error):
                    self.generateJokeButton.isEnabled = true
                    GlobalErrorHandleManager.shared.popErrorAlert(error: error, presentVC: self) { [weak self] in
                        guard let self = self else { return }
                        self.viewModel.fetchRandomJoke()
                    }
                }
            })
            .disposed(by: rx.disposeBag)
    }
}
