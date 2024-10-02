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
    private let descriptionTextView: ContentTextView = {
        let textView = ContentTextView()
        textView.enableScroll = false
        
        return textView
    }()
    
    private let actionContainerView = UIView()
    private let shareButton: UIButton = {
        let button = UIButton()
        button.setImage(Asset.Global.share.image, for: .normal)
        
        return button
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
        animatedImageView.addSubview(videoPlayerView)
        videoPlayerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        let stackView = UIStackView(arrangedSubviews: [animatedImageView, descriptionTextView, actionContainerView])
        stackView.axis = .vertical
        stackView.spacing = Constant.spacing2
        
        contentView.addSubview(stackView)
        stackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        animatedImageView.snp.makeConstraints {
            $0.height.equalTo(150).priority(.high)
        }
        
        descriptionTextView.snp.makeConstraints {
            $0.height.equalTo(150).priority(.high)
        }
        
        actionContainerView.snp.makeConstraints {
            $0.height.equalTo(35)
        }
        
        actionContainerView.addSubview(shareButton)
        shareButton.snp.makeConstraints {
            $0.right.top.bottom.equalToSuperview()
            $0.width.equalTo(35)
        }
    }
    
    func configure(with viewModel: GeneralContentCellViewModelProtocol) {
        switch viewModel.content {
        case .meme(let url, let description, let mediaType):
            animatedImageView.isHidden = false
            descriptionTextView.isHidden = false
            
            switch mediaType {
            case .image:
                videoPlayerView.reset()
                videoPlayerView.isHidden = true
                animatedImageView.kf.setImage(with: url)
                
            case .video:
                animatedImageView.image = nil
                videoPlayerView.isHidden = false
                videoPlayerView.loadVideo(from: url)
            }
            
            descriptionTextView.text = description
            
        case .joke(let joke):
            animatedImageView.isHidden = true
            descriptionTextView.isHidden = false
            
            descriptionTextView.text = joke
            
        case .gif(let url):
            animatedImageView.isHidden = false
            descriptionTextView.isHidden = true
            
            animatedImageView.kf.setImage(with: url)
        }
        
        shareButton.rx.tap
            .map { viewModel.content }
            .bind(to: viewModel.shareButtonTappedRelay)
            .disposed(by: rx.disposeBag)
    }
    
    // MARK: - Actions
    @objc private func tapGestureAction() {
        guard let viewModel = viewModel else { return }
        switch viewModel.content {
        case .meme(let url, let description, let mediaType):
            viewModel.imageTappedRelay.accept(url)
            
        case .joke(let joke):
            break
            
        case .gif(let url):
            viewModel.imageTappedRelay.accept(url)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        var mutableSelf = self
        mutableSelf.rx.disposeBag = DisposeBag()
    }
}
