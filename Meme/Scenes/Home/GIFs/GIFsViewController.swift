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
import Kingfisher
import Combine

final class GIFsViewController: BaseViewController {
    // MARK: - Properties
    private let viewModel: GIFsViewModelProtocol
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - UI
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
        super.init()
    }
    
    @MainActor required init?(coder: NSCoder) {
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
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        AnalyticsManager.shared.logScreenView(screenName: .gifs)
    }
    
    // MARK: - Setup
    private func setup() {
        viewModel.adFullPageHandler.loadFullPageAd()
    }
    
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
            stackView.spacing = Constant.UI.spacing2
            
            return stackView
        }()
        
        view.addSubview(stackView)
        stackView.snp.makeConstraints {
            $0.top.equalTo(gridCollectionView.snp.bottom).offset(Constant.UI.spacing1)
            $0.left.right.bottom.equalTo(view.safeAreaLayoutGuide).inset(Constant.UI.spacing2)
        }
        
        generateGifsButton.snp.makeConstraints {
            $0.height.equalTo(50)
        }
        
        keywordTextField.snp.makeConstraints {
            $0.height.equalTo(35)
        }
    }
    
    private func setupBinding() {
        viewModel.keywordSubject
            .receive(on: RunLoop.main)
            .sink { [weak self] value in
                self?.keywordTextField.text = value
            }
            .store(in: &cancellables)
        
        keywordTextField.textBinder
            .compactMap { $0 }
            .sink { [weak self] value in
                self?.viewModel.keywordSubject.send(value)
            }
            .store(in: &cancellables)
        
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
                    self.viewModel.inAppReviewHandler.requestReview()
                    
                case .failure(error: let error):
                    self.keywordTextField.isUserInteractionEnabled = true
                    self.generateGifsButton.isEnabled = true
                    ProgressHUD.failed()
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
                AnalyticsManager.shared.logGenerateContentClickEvent(type: .gif, keyword: self.viewModel.keywordSubject.value)
                
                if self.viewModel.adFullPageHandler.shouldDisplayAd {
                    self.viewModel.adFullPageHandler.presentFullPageAd(parentVC: self)
                } else {
                    self.viewModel.fetchData()
                }
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
                    self.viewModel.inAppReviewHandler.increasePositiveEngageCount()
                    
                    Utility.showShareSheet(items: [url], parentVC: self) {
                        self.viewModel.inAppReviewHandler.requestReview()
                    }
                }
            }
            .disposed(by: rx.disposeBag)
        
        viewModel.adFullPageHandler.dismissAdObservable
            .withUnretained(self)
            .subscribe(onNext: { (self, _) in
                self.viewModel.fetchData()
            })
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
        
        AnalyticsManager.shared.logPhotoBrowserClick()
    }
}
