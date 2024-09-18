//
//  RandomJokeViewController.swift
//  Meme
//
//  Created by DAO on 2024/9/18.
//

import UIKit
import SnapKit
import RxCocoa

final class RandomJokeViewController: UIViewController {
    // MARK: - Properties
    private let viewModel: RandomJokeViewModelProtocol
    
    // MARK: - UI
    private let jokeTextView = ContentTextView()
    private let generateJokeButton: RoundedRectangleButton = {
        let button = RoundedRectangleButton()
        button.title = "Generate Joke".localized()
        button.titleColor = .white
        button.buttonBackgroundColor = .systemIndigo
        
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
        view.backgroundColor = .systemBackground
        
        let stackView: UIStackView = {
           let stackView = UIStackView(arrangedSubviews: [
            jokeTextView,
            generateJokeButton
           ])
            stackView.axis = .vertical
            stackView.spacing = Constant.spacing2
            
            return stackView
        }()
        
        view.addSubview(stackView)
        stackView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide).inset(Constant.spacing2)
        }
        
        generateJokeButton.snp.makeConstraints {
            $0.height.equalTo(50)
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
    }
    
    private func setupBinding() {
        viewModel.joke
            .bind(to: jokeTextView.textBinder)
            .disposed(by: rx.disposeBag)
        
        viewModel.loadingStateObservable
            .asDriver(onErrorJustReturn: .initial)
            .drive(onNext: { state in
                switch state {
                case .initial, .loading:
                    self.generateJokeButton.isEnabled = false
                case .success, .failure:
                    self.generateJokeButton.isEnabled = true
                }
            })
            .disposed(by: rx.disposeBag)
    }
}
