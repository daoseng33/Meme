//
//  GeneralContentCell.swift
//  Meme
//
//  Created by DAO on 2024/10/1.
//

import UIKit
import Kingfisher
import SnapKit
import RxSwift

final class GeneralContentCell: UITableViewCell {
    // MARK: - Properties
    private var viewModel: GeneralContentCellViewModelProtocol?
    
    // MARK: - UI
    private lazy var animatedImageView: AnimatedImageView = {
        let imageView = AnimatedImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.kf.indicatorType = .activity
        imageView.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapGestureAction))
        imageView.addGestureRecognizer(tapGesture)
        
        return imageView
    }()
    
    private let videoPlayerView = VideoPlayerView()
    private let containerTextView = UIView()
    private let descriptionTextView: ContentTextView = {
        let textView = ContentTextView()
        textView.enableScroll = false
        
        return textView
    }()
    
    private let actionsContainerView = ActionsContainerView()
    
    private let bottomSeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemBackground
        
        return view
    }()
    
    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupUI() {
        contentView.backgroundColor = UIColor(dynamicProvider: { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ? .tertiarySystemGroupedBackground : .secondarySystemGroupedBackground
        })
        
        animatedImageView.addSubview(videoPlayerView)
        videoPlayerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        containerTextView.addSubview(descriptionTextView)
        descriptionTextView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.left.right.equalToSuperview().inset(Constant.UI.spacing2)
        }
        
        let stackView: UIStackView = {
            let stackView = UIStackView(arrangedSubviews: [animatedImageView, containerTextView, actionsContainerView, bottomSeparatorView])
            stackView.axis = .vertical
            stackView.spacing = Constant.UI.spacing2
            stackView.layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: Constant.UI.spacing2, right: 0)
            stackView.isLayoutMarginsRelativeArrangement = true
            
            return stackView
        }()
        
        contentView.addSubview(stackView)
        stackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        animatedImageView.snp.makeConstraints {
            $0.height.equalTo(contentView.snp.width).priority(.high)
        }
        
        actionsContainerView.snp.makeConstraints {
            $0.height.equalTo(35)
        }
        
        bottomSeparatorView.snp.makeConstraints {
            $0.height.equalTo(Constant.UI.spacing2)
        }
    }
    
    func configure(with viewModel: GeneralContentCellViewModelProtocol, isLast: Bool) {
        self.viewModel = viewModel
        switch viewModel.content {
        case .meme(let meme):
            animatedImageView.isHidden = false
            containerTextView.isHidden = false
            actionsContainerView.favoriteButton.isSelected = meme.isFavorite
            
            switch meme.mediaType {
            case .image:
                videoPlayerView.isHidden = true
                animatedImageView.kf.setImage(with: meme.url) { [weak self] result in
                    guard let self = self else { return }
                    switch result {
                    case .success:
                        break
                        
                    case .failure(let error):
                        print("kf load image error: \(error.localizedDescription)")
                        animatedImageView.image = Asset.Global.imageNotFound.image
                    }
                }
                
            case .video:
                guard let url = meme.url else { return }
                videoPlayerView.isHidden = false
                videoPlayerView.loadVideo(from: url, shouldAutoPlay: false)
            }
            
            descriptionTextView.text = meme.memeDescription
            
        case .joke(let joke):
            animatedImageView.isHidden = true
            containerTextView.isHidden = false
            
            descriptionTextView.text = joke.joke
            
        case .gif(let imageData):
            animatedImageView.isHidden = false
            containerTextView.isHidden = true
            
            animatedImageView.kf.setImage(with: imageData.url)
        }
        
        actionsContainerView.shareButton.rx.tap
            .map { viewModel.content }
            .bind(to: viewModel.shareButtonTappedRelay)
            .disposed(by: rx.disposeBag)
        
        viewModel.isFavoriteRelay
            .bind(to: actionsContainerView.favoriteButton.rx.isSelected)
            .disposed(by: rx.disposeBag)
        
        actionsContainerView.favoriteButton.rx.tap
            .withUnretained(self)
            .subscribe(onNext: { (self, _) in
                guard let viewModel = self.viewModel else { return }
                viewModel.toggleIsFavorite()
                AnalyticsManager.shared.logFavoriteEvent(isFavorite: viewModel.isFavoriteRelay.value)
                InAppReviewManager.shared.requestReview()
            })
            .disposed(by: rx.disposeBag)
        
        videoPlayerView.handleErrorObservable
            .withUnretained(self)
            .subscribe(onNext: { (self, _) in
                self.videoPlayerView.reset()
                self.animatedImageView.image = Asset.Global.imageNotFound.image
            })
            .disposed(by: rx.disposeBag)
        
        bottomSeparatorView.isHidden = isLast
    }
    
    func pauseViedoPlayer() {
        videoPlayerView.pause()
    }
    
    // MARK: - Actions
    @objc private func tapGestureAction() {
        guard let viewModel = viewModel else { return }
        switch viewModel.content {
        case .meme(let meme):
            switch meme.mediaType {
            case .image:
                guard let url = meme.url else { return }
                viewModel.imageTappedRelay.accept(url)
                
            case .video:
                if videoPlayerView.timeStatus == .playing {
                    videoPlayerView.pause()
                } else {
                    videoPlayerView.play()
                }
            }
            
        case .joke:
            break
            
        case .gif(let imageData):
            guard let url = imageData.url else { return }
            viewModel.imageTappedRelay.accept(url)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        animatedImageView.image = nil
        animatedImageView.kf.cancelDownloadTask()
        descriptionTextView.text = nil
        videoPlayerView.reset()
        
        var mutableSelf = self
        mutableSelf.rx.disposeBag = DisposeBag()
    }
}
