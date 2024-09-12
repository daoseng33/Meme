//
//  GridCollectionViewCell.swift
//  Meme
//
//  Created by DAO on 2024/9/9.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import Kingfisher

final class GridCollectionViewCell: UICollectionViewCell {
    // MARK: - UI
    private let gridImageView: AnimatedImageView = {
        let imageView = AnimatedImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        
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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        contentView.addSubview(gridImageView)
        contentView.addSubview(gridTitleLabel)
        
        gridImageView.snp.makeConstraints {
            $0.top.left.right.equalToSuperview()
            $0.height.equalTo(150)
        }
        
        gridTitleLabel.snp.makeConstraints {
            $0.top.equalTo(gridImageView.snp.bottom).offset(8)
            $0.left.right.equalTo(gridImageView)
            $0.bottom.lessThanOrEqualToSuperview().offset(-8).priority(.high)
        }
    }
    
    func configure(viewModel: GridCollectionViewCellViewModel) {
        viewModel.title
            .bind(to: gridTitleLabel.rx.text)
            .disposed(by: rx.disposeBag)
        
        viewModel.imageData
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
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        gridImageView.kf.cancelDownloadTask()
        gridImageView.image = nil
        var mutableSelf = self
        mutableSelf.rx.disposeBag = DisposeBag()
    }
}
