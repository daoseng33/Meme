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
import SKPhotoBrowser
import ProgressHUD

final class RandomMemeViewController: BaseViewController {
    // MARK: - Properties
    private let viewModel: RandomMemeViewModelProtocol
    
    // MARK: - UI
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.alwaysBounceVertical = true
        
        return scrollView
    }()
    
    private let containerView = UIView()
    
    private lazy var imageView: AnimatedImageView = {
        let imageView = AnimatedImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.kf.indicatorType = .activity
        imageView.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapGestureAction))
        imageView.addGestureRecognizer(tapGesture)

        return imageView
    }()
    
    private let videoPlayerView = VideoPlayerView()
    private let descriptionTextView: ContentTextView = {
        let view = ContentTextView()
        view.enableScroll = false
        
        return view
    }()
    private let keywordTextField = KeywordTextField()
    private let actionsContainerView = ActionsContainerView()
    private let generateMemeButton: RoundedRectangleButton = {
        let button = RoundedRectangleButton()
        button.title = "Generate Meme".localized()
        button.titleColor = .white
        button.buttonBackgroundColor = .accent
        
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.refreshData()
        
        if videoPlayerView.timeStatus == .paused, videoPlayerView.isHidden == false {
            videoPlayerView.play()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if videoPlayerView.timeStatus == .playing, videoPlayerView.isHidden == false {
            videoPlayerView.pause()
        }
    }
    
    // MARK: - Setup
    private func setupUI() {
        navigationItem.title = "Random Meme".localized()
        
        let interactionStackView: UIStackView = {
            let stackView = UIStackView(arrangedSubviews: [
                keywordTextField,
                actionsContainerView
            ])
            
            stackView.axis = .horizontal
            stackView.spacing = Constant.spacing1
            
            return stackView
        }()
        
        interactionStackView.snp.makeConstraints {
            $0.height.equalTo(35)
        }
        
        let bottomStackView: UIStackView = {
            let stackView = UIStackView(arrangedSubviews: [
                interactionStackView,
                generateMemeButton
            ])
            
            stackView.axis = .vertical
            stackView.spacing = Constant.spacing2
            
            return stackView
        }()
        
        view.addSubview(bottomStackView)
        bottomStackView.snp.makeConstraints {
            $0.left.right.bottom.equalTo(view.safeAreaLayoutGuide).inset(Constant.spacing2)
        }
        
        generateMemeButton.snp.makeConstraints {
            $0.height.equalTo(50)
        }
        
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints {
            $0.top.left.right.equalTo(view.safeAreaLayoutGuide)
            $0.bottom.equalTo(bottomStackView.snp.top).offset(-Constant.spacing2)
        }
        
        scrollView.addSubview(containerView)
        containerView.snp.makeConstraints {
            $0.edges.equalTo(scrollView.contentLayoutGuide)
            $0.width.equalTo(scrollView.frameLayoutGuide.snp.width)
        }
        
        let topStackView: UIStackView = {
            let stackView = UIStackView(arrangedSubviews: [
                imageView,
                descriptionTextView
            ])
            
            stackView.axis = .vertical
            stackView.spacing = Constant.spacing1
            
            return stackView
        }()
        
        containerView.addSubview(topStackView)
        topStackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        imageView.snp.makeConstraints {
            $0.height.equalTo(containerView.snp.width)
        }
        
        imageView.addSubview(videoPlayerView)
        videoPlayerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        containerView.snp.makeConstraints {
            $0.height.greaterThanOrEqualTo(topStackView)
        }
    }
    
    private func setupActions() {
        generateMemeButton.tapEvent
            .withUnretained(self)
            .subscribe(onNext: { (self, _) in
                self.viewModel.isFavoriteRelay.accept(false)
                self.videoPlayerView.reset()
                self.viewModel.fetchData()
            })
            .disposed(by: rx.disposeBag)
        
        videoPlayerView.handleErrorObservable
            .asDriver(onErrorJustReturn: ())
            .drive(with: self) { (self, _) in
                self.videoPlayerView.reset()
                self.videoPlayerView.isHidden = true
                self.imageView.image = Asset.Global.imageNotFound.image
            }
            .disposed(by: rx.disposeBag)
        
        actionsContainerView.shareButton.rx.tap
            .withUnretained(self)
            .subscribe(onNext: { (self, _) in
                guard let mediaURL = self.viewModel.media.mediaURL else { return }
                let description = self.viewModel.description
                
                KingfisherManager.shared.retrieveImage(with: mediaURL) { [weak self] result in
                    guard let self = self else { return }
                    switch result {
                        case .success(let resource):
                        Utility.showShareSheet(items: [mediaURL, resource.image, description], parentVC: self)
                        
                    case .failure:
                        Utility.showShareSheet(items: [mediaURL, description], parentVC: self)
                    }
                }
            })
            .disposed(by: rx.disposeBag)
        
        viewModel.isFavoriteRelay
            .bind(to: actionsContainerView.favoriteButton.rx.isSelected)
            .disposed(by: rx.disposeBag)
        
        actionsContainerView.favoriteButton.rx.tap
            .withUnretained(self)
            .subscribe(onNext: { (self, _) in
                self.viewModel.toggleIsFavorite()
            })
            .disposed(by: rx.disposeBag)
    }
    
    @objc private func tapGestureAction() {
        if let image = imageView.image {
            let images = [SKPhoto.photoWithImage(image)]
            let browser = SKPhotoBrowser(photos: images)
            
            present(browser, animated: true)
        } else {
            if videoPlayerView.timeStatus == .playing {
                videoPlayerView.pause()
            } else {
                videoPlayerView.play()
            }
        }
    }
    
    private func setupBinding() {
        viewModel.mediaDriver
            .drive(with: self) { (self, mediaData) in
                switch mediaData.type {
                case .image:
                    self.videoPlayerView.isHidden = true
                    self.imageView.kf.setImage(with: mediaData.mediaURL) { [weak self] result in
                        guard let self = self else { return }
                        switch result {
                        case .success:
                            break
                            
                        case .failure(let error):
                            print("kf load image error: \(error.localizedDescription)")
                            self.imageView.image = Asset.Global.imageNotFound.image
                        }
                    }
                    
                case .video:
                    if let url = mediaData.mediaURL {
                        self.videoPlayerView.isHidden = false
                        self.imageView.image = nil
                        self.videoPlayerView.loadVideo(from: url)
                    }
                }
            }
            .disposed(by: rx.disposeBag)
        
        viewModel.loadingStateDriver
            .drive(with: self, onNext: { (self, state) in
                switch state {
                case .initial, .loading:
                    self.generateMemeButton.isEnabled = false
                    self.actionsContainerView.favoriteButton.isEnabled = false
                    self.actionsContainerView.shareButton.isEnabled = false
                    ProgressHUD.animate("Loading".localized(), interaction: false)
                    
                case .success:
                    self.generateMemeButton.isEnabled = true
                    self.actionsContainerView.favoriteButton.isEnabled = true
                    self.actionsContainerView.shareButton.isEnabled = true
                    ProgressHUD.dismiss()
                    
                case .failure(let error):
                    self.generateMemeButton.isEnabled = true
                    self.actionsContainerView.shareButton.isEnabled = false
                    self.actionsContainerView.favoriteButton.isEnabled = false
                    ProgressHUD.failed()
                    GlobalErrorHandleManager.shared.popErrorAlert(error: error, presentVC: self) { [weak self] in
                        guard let self = self else { return }
                        self.viewModel.fetchData()
                    }
                }
            })
            .disposed(by: rx.disposeBag)
            
        viewModel.descriptionDriver
            .drive(descriptionTextView.textBinder)
            .disposed(by: rx.disposeBag)
        
        viewModel.keywordRelay
            .bind(to: keywordTextField.textBinder)
            .disposed(by: rx.disposeBag)
        
        keywordTextField.textBinder
            .bind(to: viewModel.keywordRelay)
            .disposed(by: rx.disposeBag)
    }
}
