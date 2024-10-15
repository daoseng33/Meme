//
//  GIFsViewController.swift
//  Meme
//
//  Created by DAO on 2024/9/22.
//

import UIKit
import SnapKit
import RxCocoa
import RxSwift
import SKPhotoBrowser
import ProgressHUD

final class GIFsViewController: BaseViewController {
    // MARK: - Properties
    private let viewModel: GIFsViewModelProtocol
    private lazy var gridCollectionView: GridCollectionView = {
        let collectionView = GridCollectionView(viewModel: viewModel.gridCollectionViewModel)
        collectionView.delegate = self
        
        return collectionView
    }()
    private let keywordTextField = KeywordTextField()
    private let generateGifsButton: RoundedRectangleButton = {
        let button = RoundedRectangleButton()
        button.title = "Generate GIFs".localized()
        button.titleColor = .white
        button.buttonBackgroundColor = .accent
        
        return button
    }()
    
    // MARK: - Init
    init(viewModel: GIFsViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    @MainActor required init?(coder: NSCoder) {
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
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        AnalyticsManager.shared.logScreenView(screenName: .gifs)
    }
    
    // MARK: - Setup
    private func setupUI() {
        navigationItem.title = "GIFs".localized()
        
        view.addSubview(gridCollectionView)
        gridCollectionView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.left.right.equalToSuperview()
        }
        
        let stackView: UIStackView = {
            let stackView = UIStackView(arrangedSubviews: [keywordTextField, generateGifsButton])
            stackView.axis = .vertical
            stackView.spacing = Constant.spacing2
            
            return stackView
        }()
        
        view.addSubview(stackView)
        stackView.snp.makeConstraints {
            $0.top.equalTo(gridCollectionView.snp.bottom).offset(Constant.spacing1)
            $0.left.right.bottom.equalTo(view.safeAreaLayoutGuide).inset(Constant.spacing2)
        }
        
        generateGifsButton.snp.makeConstraints {
            $0.height.equalTo(50)
        }
        
        keywordTextField.snp.makeConstraints {
            $0.height.equalTo(35)
        }
    }
    
    private func setupBinding() {
        viewModel.keywordRelay
            .bind(to: keywordTextField.textBinder)
            .disposed(by: rx.disposeBag)
        
        keywordTextField.textBinder
            .bind(to: viewModel.keywordRelay)
            .disposed(by: rx.disposeBag)
        
        viewModel.loadingStateDriver
            .drive(with: self, onNext: { (self, state) in
                switch state {
                case .initial, .loading:
                    self.keywordTextField.isUserInteractionEnabled = false
                    self.generateGifsButton.isEnabled = false
                    ProgressHUD.animate("Loading".localized(), interaction: false)
                    
                case .success:
                    self.keywordTextField.isUserInteractionEnabled = true
                    self.generateGifsButton.isEnabled = true
                    ProgressHUD.dismiss()
                    
                case .failure(error: let error):
                    self.keywordTextField.isUserInteractionEnabled = true
                    self.generateGifsButton.isEnabled = true
                    ProgressHUD.dismiss()
                    GlobalErrorHandleManager.shared.popErrorAlert(error: error, presentVC: self) { [weak self] in
                        guard let self = self else { return }
                        self.viewModel.fetchData()
                    }
                }
            })
            .disposed(by: rx.disposeBag)
    }
    
    private func setupActions() {
        generateGifsButton.tapEvent
            .withUnretained(self)
            .subscribe(onNext: { (self, _) in
                self.viewModel.fetchData()
            })
            .disposed(by: rx.disposeBag)
        
        viewModel.gridCollectionViewModel.shareButtonTappedRelay
            .asSignal()
            .emit(with: self) { (self, imageType) in
                switch imageType {
                case .static:
                    break
                    
                case .gif(let url):
                    AnalyticsManager.shared.logShareEvent(contentType: .gif, itemID: url.absoluteString)
                    
                    Utility.showShareSheet(items: [url], parentVC: self) {
                        InAppReviewManager.shared.requestReview()
                    }
                }
            }
            .disposed(by: rx.disposeBag)
    }
}

// MARK: - GridCollectionViewDelegate
extension GIFsViewController: GridCollectionViewDelegate {
    func gridCollectionView(_ gridCollectionView: GridCollectionView, didSelectItemAt index: Int) {
        viewModel.saveSelectedImageData(with: index)
        let imageType = viewModel.getImageType(with: index)
        
        let images: [SKPhoto]
        switch imageType {
        case .gif(let url):
            images = [SKPhoto.photoWithImageURL(url.absoluteString)]
            
        case .static(let image):
            images = [SKPhoto.photoWithImage(image)]
        }
        
        let browser = SKPhotoBrowser(photos: images)
        present(browser, animated: true)
    }
}
