//
//  RandomMemeViewController.swift
//  Meme
//
//  Created by DAO on 2024/9/10.
//

import UIKit
import AVFoundation
import SnapKit
import RxCocoa
import Kingfisher

final class RandomMemeViewController: UIViewController {
    // MARK: - Properties
    private let viewModel: RandomMemeViewModelProtocol
    
    // MARK: - UI
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.kf.indicatorType = .activity
        
        return imageView
    }()
    
    private let videoPlayerView = VideoPlayerView()
    
    private let descriptionTextView: UITextView = {
        let padding = 8.0
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        textView.textColor = .label
        textView.contentInset = UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding)
        textView.isEditable = false
        
        return textView
    }()
    
    private let keywordTextField: UITextField = {
        let textField = UITextField()
        textField.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        textField.textColor = .label
        textField.backgroundColor = .systemGray6
        textField.placeholder = "\("Key in keyword".localized())(\("Optional".localized()))"
        textField.layer.cornerRadius = 4
        textField.clipsToBounds = true
        textField.returnKeyType = .done
        textField.clearButtonMode = .whileEditing
        textField.setInsets(left: 8, right: 8)
        
        return textField
    }()
    
    private let generateMemeButton: RoundedRectangleButton = {
        let button = RoundedRectangleButton()
        button.title = "Generate Meme".localized()
        button.titleColor = .white
        button.buttonBackgroundColor = .systemIndigo
        button.isEnabled = false
        
        return button
    }()
    
    // MARK: - Init
    init(viewModel: RandomMemeViewModelProtocol) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if videoPlayerView.status == .playing, videoPlayerView.isHidden == false {
            videoPlayerView.pause()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if videoPlayerView.status == .paused, videoPlayerView.isHidden == false {
            videoPlayerView.play()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View lifecycle
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
        
        view.addSubview(imageView)
        imageView.snp.makeConstraints {
            $0.top.left.right.equalToSuperview()
            $0.height.equalTo(view.snp.width)
        }
        
        view.addSubview(videoPlayerView)
        videoPlayerView.snp.makeConstraints {
            $0.top.left.right.equalToSuperview()
            $0.height.equalTo(view.snp.width)
        }
        
        view.addSubview(generateMemeButton)
        generateMemeButton.snp.makeConstraints {
            $0.left.right.equalToSuperview().inset(8)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(8)
            $0.height.equalTo(50)
        }
        
        view.addSubview(keywordTextField)
        keywordTextField.snp.makeConstraints {
            $0.left.right.equalTo(generateMemeButton)
            $0.bottom.equalTo(generateMemeButton.snp.top).offset(-8)
            $0.height.equalTo(35)
        }
        
        view.addSubview(descriptionTextView)
        descriptionTextView.snp.makeConstraints {
            $0.top.equalTo(imageView.snp.bottom)
            $0.left.right.equalToSuperview()
            $0.bottom.equalTo(keywordTextField.snp.top).offset(-8)
        }
    }
    
    private func setupActions() {
        generateMemeButton.tapEvent
            .withUnretained(self)
            .subscribe(onNext: { (self, _) in
                self.generateMemeButton.isEnabled = false
                self.viewModel.fetchRandomMeme()
            })
            .disposed(by: rx.disposeBag)
    }
    
    private func setupBinding() {
        viewModel.media
            .asDriver(onErrorJustReturn: (nil, .image))
            .drive(with: self) { (self, mediaData) in
                switch mediaData.type {
                case .image:
                    self.videoPlayerView.reset()
                    self.videoPlayerView.isHidden = true
                    self.imageView.isHidden = false
                    self.imageView.kf.setImage(with: mediaData.mediaURL)
                    
                case .video:
                    if let url = mediaData.mediaURL {
                        self.videoPlayerView.isHidden = false
                        self.imageView.isHidden = true
                        self.videoPlayerView.loadVideo(from: url)
                    }
                }
                
                self.generateMemeButton.isEnabled = mediaData.mediaURL != nil
            }
            .disposed(by: rx.disposeBag)
            
        viewModel.description
            .bind(to: descriptionTextView.rx.text)
            .disposed(by: rx.disposeBag)
        
        viewModel.keyword
            .bind(to: keywordTextField.rx.text)
            .disposed(by: rx.disposeBag)
        
        keywordTextField.rx.text
            .bind(to: viewModel.keywordObserver)
            .disposed(by: rx.disposeBag)
    }
}
