//
//  GridCell.swift
//  Meme
//
//  Created by DAO on 2024/9/9.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import Kingfisher
import SKPhotoBrowser

final class GridCell: UICollectionViewCell {
    // MARK: - Properties
    private var viewModel: GridCellViewModelProtocol?
    
    // MARK: - UI
    private let gridImageView: AnimatedImageView = {
        let imageView = AnimatedImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.kf.indicatorType = .activity
        
        return imageView
    }()
    
    private let gridTitleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .label
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label.numberOfLines = 2
        
        return label
    }()
    
    private let actionsContainerView = ActionsContainerView()
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupViews() {
        let stackView: UIStackView = {
            let stackView = UIStackView(arrangedSubviews: [gridImageView, gridTitleLabel, actionsContainerView])
            stackView.axis = .vertical
            stackView.spacing = Constant.UI.spacing2
            
            return stackView
        }()
        
        contentView.addSubview(stackView)
        
        stackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        gridImageView.snp.makeConstraints {
            $0.height.equalTo(contentView.snp.width).priority(.high)
        }
        
        actionsContainerView.snp.makeConstraints {
            $0.height.equalTo(35).priority(.high)
        }
    }
    
    func configure(viewModel: GridCellViewModelProtocol) {
        self.viewModel = viewModel
        
        viewModel.titleObservable.map { $0 == nil }
            .withUnretained(self)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { (self, isTextNil) in
                self.gridTitleLabel.isHidden = isTextNil
                self.actionsContainerView.isHidden = !isTextNil
            })
            .disposed(by: rx.disposeBag)
        
        viewModel.titleObservable
            .bind(to: gridTitleLabel.rx.text)
            .disposed(by: rx.disposeBag)
        
        viewModel.imageTypeObservable
            .withUnretained(self)
            .subscribe(onNext: {  (self, imageData) in
                switch imageData {
                case .static(let image):
                    self.gridImageView.image = image
                    
                case .gif(let url):
                    let provider = LocalFileImageDataProvider(fileURL: url)
                    self.gridImageView.kf.setImage(with: provider, options: [.cacheOriginalImage])
                }
            })
            .disposed(by: rx.disposeBag)
        
        viewModel.isFavoriteRelay
            .bind(to: actionsContainerView.favoriteButton.rx.isSelected)
            .disposed(by: rx.disposeBag)
        
        actionsContainerView.favoriteButton.rx.tap
            .subscribe(onNext: {
                viewModel.toggleIsFavorite()
                AnalyticsManager.shared.logFavoriteEvent(isFavorite: viewModel.isFavoriteRelay.value)
                InAppReviewManager.shared.increasePositiveEngageCount()
                InAppReviewManager.shared.requestReview()
            })
            .disposed(by: rx.disposeBag)
        
        actionsContainerView.shareButton.rx.tap
            .subscribe(onNext: {
                viewModel.shareButtonTappedRelay.accept(viewModel.currentImageType)
            })
            .disposed(by: rx.disposeBag)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        gridImageView.kf.cancelDownloadTask()
        gridImageView.image = nil
        var mutableSelf = self
        mutableSelf.rx.disposeBag = DisposeBag()
    }
}
