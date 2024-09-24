//
//  RandomMemeViewController.swift
//  Meme
//
//  Created by DAO on 2024/9/10.
//

import UIKit
import AVFoundation
import SnapKit
//import RxSwift
import RxCocoa
import Kingfisher
//import RxGesture
import SKPhotoBrowser

final class RandomMemeViewController: BaseViewController {
    // MARK: - Properties
    private let viewModel: RandomMemeViewModelProtocol
    
    // MARK: - UI
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.kf.indicatorType = .activity
        imageView.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapGestureAction))
        imageView.addGestureRecognizer(tapGesture)
        
        return imageView
    }()
    
    private let videoPlayerView = VideoPlayerView()
    private let descriptionTextView = ContentTextView()
    private let keywordTextField = KeywordTextField()
    
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
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        navigationBar.topItem?.title = "Random Meme".localized()
        
        view.addSubview(imageView)
        imageView.snp.makeConstraints {
            $0.top.equalTo(navigationBar.snp.bottom)
            $0.left.right.equalToSuperview()
            $0.height.equalTo(view.snp.width)
        }
        
        view.addSubview(videoPlayerView)
        videoPlayerView.snp.makeConstraints {
            $0.edges.equalTo(imageView)
        }
        
        let stackView: UIStackView = {
            let stackView = UIStackView(arrangedSubviews: [
                descriptionTextView,
                keywordTextField,
                generateMemeButton
            ])
            
            stackView.axis = .vertical
            stackView.spacing = Constant.spacing2
            
            return stackView
        }()
        
        view.addSubview(stackView)
        
        stackView.snp.makeConstraints {
            $0.top.equalTo(imageView.snp.bottom).offset(Constant.spacing2)
            $0.left.right.bottom.equalTo(view.safeAreaLayoutGuide).inset(Constant.spacing2)
        }
        
        generateMemeButton.snp.makeConstraints {
            $0.height.equalTo(50)
        }
        
        keywordTextField.snp.makeConstraints {
            $0.height.equalTo(35)
        }
    }
    
    private func setupActions() {
        generateMemeButton.tapEvent
            .withUnretained(self)
            .subscribe(onNext: { (self, _) in
                self.videoPlayerView.reset()
                self.viewModel.fetchRandomMeme()
            })
            .disposed(by: rx.disposeBag)
        
        videoPlayerView.handleErrorObservable
            .asDriver(onErrorJustReturn: ())
            .drive(with: self) { (self, _) in
                self.videoPlayerView.reset()
                self.videoPlayerView.isHidden = true
                self.imageView.isHidden = false
                self.imageView.image = Asset.Global.noResult.image
            }
            .disposed(by: rx.disposeBag)
    }
    
    @objc private func tapGestureAction() {
        guard let image = self.imageView.image else { return }
        let images = [SKPhoto.photoWithImage(image)]
        let browser = SKPhotoBrowser(photos: images)
        
        show(browser, sender: nil)
    }
    
    private func setupBinding() {
        viewModel.media
            .asDriver(onErrorJustReturn: (nil, .image))
            .drive(with: self) { (self, mediaData) in
                switch mediaData.type {
                case .image:
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
            }
            .disposed(by: rx.disposeBag)
        
        viewModel.loadingStateObservable
            .asDriver(onErrorJustReturn: .initial)
            .drive(with: self, onNext: { (self, state) in
                switch state {
                case .initial, .loading:
                    self.generateMemeButton.isEnabled = false
                    
                case .success:
                    self.generateMemeButton.isEnabled = true
                    
                case .failure(let error):
                    self.generateMemeButton.isEnabled = true
                    GlobalErrorHandler.shared.popErrorAlert(error: error, presentVC: self) { [weak self] in
                        guard let self = self else { return }
                        self.viewModel.fetchRandomMeme()
                    }
                }
            })
            .disposed(by: rx.disposeBag)
            
        viewModel.description
            .bind(to: descriptionTextView.textBinder)
            .disposed(by: rx.disposeBag)
        
        viewModel.keyword
            .bind(to: keywordTextField.textBinder)
            .disposed(by: rx.disposeBag)
        
        keywordTextField.textBinder
            .bind(to: viewModel.keywordObserver)
            .disposed(by: rx.disposeBag)
    }
}
