//
//  GridCollectionView.swift
//  Meme
//
//  Created by DAO on 2024/9/9.
//

import UIKit
import RxCocoa
import SnapKit

protocol GridCollectionViewDelegate: AnyObject {
    func gridCollectionView(_ gridCollectionView: GridCollectionView, didSelectItemAt index: Int)
}

final class GridCollectionView: UIView {
    // MARK: - Properties
    weak var delegate: GridCollectionViewDelegate?
    private let viewModel: GridCollectionViewModelProtocol
    
    // MARK: - UI
    private let collectionViewPadding = 8.0
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewCompositionalLayout { (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in
            let collectionViewPadding = Constant.spacing2
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
        setupObserver()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        
        addSubview(collectionView)
        collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    private func setupObserver() {
        viewModel.shouldReloadData
            .asDriver(onErrorJustReturn: ())
            .drive(with: self) { (self, _) in
                self.collectionView.reloadData()
            }
            .disposed(by: rx.disposeBag)
    }
}

// MARK: - UICollectionViewDataSource
extension GridCollectionView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfItems
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: GridCell = collectionView.dequeueReusableCell(for: indexPath)
        
        let cellViewModel = viewModel.gridCellViewModel(with: indexPath.item)
        cell.configure(viewModel: cellViewModel)
        
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension GridCollectionView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.gridCollectionView(self, didSelectItemAt: indexPath.item)
    }
}
