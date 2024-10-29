//
//  GridCollectionView.swift
//  Meme
//
//  Created by DAO on 2024/9/9.
//

import UIKit
import RxCocoa
import SnapKit
import RxDataSources

protocol GridCollectionViewDelegate: AnyObject {
    func gridCollectionView(_ gridCollectionView: GridCollectionView, didSelectItemAt index: Int)
}

final class GridCollectionView: UIView, UIScrollViewDelegate {
    // MARK: - Properties
    weak var delegate: GridCollectionViewDelegate?
    private var viewModel: GridCollectionViewModelProtocol
    
    // MARK: - UI
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewCompositionalLayout { (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in
            let collectionViewPadding = Constant.UI.spacing2
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                  heightDimension: .estimated(186))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                   heightDimension: .estimated(186))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 2)
            group.interItemSpacing = .fixed(collectionViewPadding)
            
            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = collectionViewPadding
            section.contentInsets = NSDirectionalEdgeInsets(top: collectionViewPadding, leading: collectionViewPadding, bottom: collectionViewPadding, trailing: collectionViewPadding)
            
            return section
        }
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(GridCell.self)
        collectionView.backgroundColor = .secondarySystemBackground
        
        return collectionView
    }()
    
    // MARK: - Init
    init(viewModel: GridCollectionViewModelProtocol) {
        self.viewModel = viewModel
        
        super.init(frame: .zero)
        
        setupCollectionView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupCollectionView() {
        addSubview(collectionView)
        collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        collectionView.rx.setDelegate(self)
            .disposed(by: rx.disposeBag)
        
        let dataSource = RxCollectionViewSectionedAnimatedDataSource<GridSection>(configureCell: { [weak self] dataSource, collectionView, indexPath, gridData in
            let cell: GridCell = collectionView.dequeueReusableCell(for: indexPath)
            
            guard let self = self else { return cell }
            
            let cellViewModel = self.viewModel.gridCellViewModel(with: indexPath.item)
            
            cellViewModel.favoriteButtonTappedRelay
                .subscribe(with: self, onNext: { (self, gifInfo) in
                    self.viewModel.favoriteButtonTappedRelay.accept((gifInfo.gridImageType,
                                                                     gifInfo.isFavorite,
                                                                     indexPath.item))
                })
                .disposed(by: cell.rx.disposeBag)
            
            cellViewModel.shareButtonTappedRelay
                .bind(to: self.viewModel.shareButtonTappedRelay)
                .disposed(by: cell.rx.disposeBag)
            
            cell.configure(viewModel: cellViewModel)
            
            return cell
        })
        
        viewModel.dataSource = dataSource
        viewModel.sectionsRelay
            .bind(to: collectionView.rx.items(dataSource: dataSource))
            .disposed(by: rx.disposeBag)
        
        collectionView.rx.itemSelected
            .subscribe(with: self) { (self, indexPath) in
                self.delegate?.gridCollectionView(self, didSelectItemAt: indexPath.item)
            }
            .disposed(by: rx.disposeBag)
    }
}
