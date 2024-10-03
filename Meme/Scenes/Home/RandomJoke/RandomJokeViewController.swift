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
    
    private lazy var categorySelectedButton = MenuButton(contentStrings: viewModel.categories,
                                                         arrowDirection: .up)
    
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
        
        let categoryMenuStackView: UIStackView = {
            let stackView = UIStackView(arrangedSubviews: [
                categorySelectedLabel,
                categorySelectedButton
            ])
            stackView.axis = .horizontal
            stackView.spacing = Constant.spacing1
            
            return stackView
        }()
        
        categorySelectedView.addSubview(categoryMenuStackView)
        
        categoryMenuStackView.snp.makeConstraints {
            $0.left.top.bottom.equalToSuperview()
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
        
        categorySelectedButton.selectedOptionObservable
            .bind(to: viewModel.selectedCategoryObserver)
            .disposed(by: rx.disposeBag)
    }
}
