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
import SwiftyGif

final class GridCollectionViewCell: UICollectionViewCell {
    // MARK: - UI
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .darkText
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
        contentView.addSubview(imageView)
        contentView.addSubview(titleLabel)
        
        imageView.snp.makeConstraints {
            $0.top.left.right.equalToSuperview()
            $0.height.equalTo(150)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(imageView.snp.bottom).offset(8)
            $0.left.right.equalTo(imageView)
            $0.bottom.lessThanOrEqualToSuperview().offset(-8).priority(.high)
        }
    }
    
    func configure(viewModel: GridCollectionViewCellViewModel) {
        viewModel.title
            .bind(to: titleLabel.rx.text)
            .disposed(by: rx.disposeBag)
        
        viewModel.imageData
            .withUnretained(self)
            .subscribe(onNext: {  (self, imageData) in
                switch imageData.type {
                case .static:
                    self.imageView.image = imageData.image
                case .gif:
                    self.imageView.setGifImage(imageData.image)
                }
            })
            .disposed(by: rx.disposeBag)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.clear()
        var mutableSelf = self
        mutableSelf.rx.disposeBag = DisposeBag()
    }
}
