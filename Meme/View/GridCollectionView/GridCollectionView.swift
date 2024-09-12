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
    private let viewModel: GridCollectionViewModel
    
    // MARK: - UI
    private let collectionViewPadding = 8.0
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(GridCollectionViewCell.self)
        collectionView.backgroundColor = .systemBackground
        
        return collectionView
    }()
    
    // MARK: - Init
    init(viewModel: GridCollectionViewModel) {
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
        let cell: GridCollectionViewCell = collectionView.dequeueReusableCell(for: indexPath)
        
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

// MARK: - UICollectionViewDelegateFlowLayout
extension GridCollectionView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: collectionViewPadding, left: collectionViewPadding, bottom: collectionViewPadding, right: collectionViewPadding)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return collectionViewPadding
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return collectionViewPadding
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let collectionViewWidth = collectionView.bounds.width
        let itemWidth = (collectionViewWidth - collectionViewPadding * 3) / 2
        return CGSize(width: itemWidth, height: 186)
    }
}
