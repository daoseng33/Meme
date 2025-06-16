//
//  RandomMemeViewController.swift
//  Meme
//
//  Created by DAO on 2024/9/10.
//

import UIKit
import AVFoundation
import SnapKit
import Kingfisher
import SKPhotoBrowser
import ProgressHUD
import Combine

final class RandomMemeViewController: BaseViewController {
    // MARK: - Properties
    private let viewModel: RandomMemeViewModelProtocol
    private var cancellables = Set<AnyCancellable>()
    
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
        
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
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
        
        AnalyticsManager.shared.logScreenView(screenName: .randomMeme)
    }
    
    // MARK: - Setup
    private func setup() {
        viewModel.adFullPageHandler.loadFullPageAd()
    }
    
    private func setupUI() {
        navigationItem.title = "Random Meme".localized()
        
        let interactionStackView: UIStackView = {
            let stackView = UIStackView(arrangedSubviews: [
                keywordTextField,
                actionsContainerView
            ])
            
            stackView.axis = .horizontal
            stackView.spacing = Constant.UI.spacing1
            
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
            stackView.spacing = Constant.UI.spacing2
            
            return stackView
        }()
        
        view.addSubview(bottomStackView)
        bottomStackView.snp.makeConstraints {
            $0.left.right.bottom.equalTo(view.safeAreaLayoutGuide).inset(Constant.UI.spacing2)
        }
        
        generateMemeButton.snp.makeConstraints {
            $0.height.equalTo(50)
        }
        
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints {
            $0.top.left.right.equalTo(view.safeAreaLayoutGuide)
            $0.bottom.equalTo(bottomStackView.snp.top).offset(-Constant.UI.spacing2)
        }
        
        scrollView.addSubview(containerView)
        containerView.snp.makeConstraints {
            $0.edges.equalTo(scrollView.contentLayoutGuide)
            $0.width.equalTo(scrollView.frameLayoutGuide.snp.width)
        }
        
        containerView.addSubview(imageView)
        imageView.snp.makeConstraints {
            $0.top.left.right.equalToSuperview()
            $0.height.equalTo(containerView.snp.width)
        }
        
        imageView.addSubview(videoPlayerView)
        videoPlayerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        containerView.addSubview(descriptionTextView)
        descriptionTextView.snp.makeConstraints {
            $0.top.equalTo(imageView.snp.bottom).offset(Constant.UI.spacing1)
            $0.left.right.equalToSuperview().inset(Constant.UI.spacing1)
            $0.bottom.equalToSuperview()
        }
    }
    
    private func setupActions() {
        generateMemeButton.tapEvent
            .withUnretained(self)
            .subscribe(onNext: { (self, _) in
                AnalyticsManager.shared.logGenerateContentClickEvent(type: .meme, keyword: self.viewModel.keywordSubject.value)
                self.viewModel.isFavoriteRelay.accept(false)
                self.videoPlayerView.reset()
                
                if self.viewModel.adFullPageHandler.shouldDisplayAd {
                    self.viewModel.adFullPageHandler.presentFullPageAd(parentVC: self)
                } else {
                    self.viewModel.fetchData()
                }
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
                self.viewModel.inAppReviewHandler.increasePositiveEngageCount()
                
                self.viewModel.shareButtonTappedSubject.send(())
                let mediaType = self.viewModel.media.type
                let description = self.viewModel.description
                
                switch mediaType {
                case .image:
                    KingfisherManager.shared.retrieveImage(with: mediaURL) { [weak self] result in
                        guard let self = self else { return }
                        switch result {
                        case .success(let resource):
                            Utility.showShareSheet(items: [mediaURL, resource.image, description], parentVC: self) {
                                self.viewModel.inAppReviewHandler.requestReview()
                            }
                            
                        case .failure:
                            Utility.showShareSheet(items: [mediaURL, description], parentVC: self) {
                                self.viewModel.inAppReviewHandler.requestReview()
                            }
                        }
                    }
                case .video:
                    Utility.showShareSheet(items: [mediaURL, description], parentVC: self) {
                        self.viewModel.inAppReviewHandler.requestReview()
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
                let isFavorite = self.viewModel.isFavoriteRelay.value
                if isFavorite {
                    self.viewModel.fetchUpVote()
                } else {
                    self.viewModel.fetchDownVote()
                }
                
                AnalyticsManager.shared.logFavoriteEvent(isFavorite: isFavorite)
                self.viewModel.inAppReviewHandler.increasePositiveEngageCount()
                self.viewModel.inAppReviewHandler.requestReview()
            })
            .disposed(by: rx.disposeBag)
    }
    
    @objc private func tapGestureAction() {
        if let image = imageView.image {
            let images = [SKPhoto.photoWithImage(image)]
            let browser = SKPhotoBrowser(photos: images)
            
            present(browser, animated: true)
            
            AnalyticsManager.shared.logPhotoBrowserClick()
        } else {
            if videoPlayerView.timeStatus == .playing {
                videoPlayerView.pause()
            } else {
                videoPlayerView.play()
            }
        }
    }
    
    private func setupBinding() {
        viewModel.mediaPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] mediaData in
                guard let self else { return }
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
            .store(in: &cancellables)
        
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
                    self.viewModel.inAppReviewHandler.requestReview()
                    
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
        
        viewModel.descriptionPublisher
            .receive(on: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] value in
                guard let self else { return }
                self.descriptionTextView.text = value
            }
            .store(in: &cancellables)
        
        
        viewModel.keywordSubject
            .receive(on: DispatchQueue.main)
            .sink { [weak self] value in
                if self?.keywordTextField.text != value {
                    self?.keywordTextField.text = value
                }
            }
            .store(in: &cancellables)
        
        keywordTextField.textBinder
            .sink { [weak self] value in
                if self?.viewModel.keywordSubject.value != value {
                    self?.viewModel.keywordSubject.send(value)
                }
            }
            .store(in: &cancellables)
        
        viewModel.adFullPageHandler.dismissAdObservable
            .withUnretained(self)
            .subscribe(onNext: { (self, _) in
                self.viewModel.fetchData()
            })
            .disposed(by: rx.disposeBag)
    }
}
