//
//  GeneralContentViewController.swift
//  Meme
//
//  Created by DAO on 2024/10/5.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import SKPhotoBrowser

class GeneralContentViewController: BaseViewController {
    // MARK: - Properties
    private let viewModel: GeneralContentViewModelProtocol
    private var tabBarDidSelectDisposable: Disposable?
    private let filterViewHeight: CGFloat = 35
    private let naviItemTitle: String
    private let tabBarType: MemeTabBarItem
    
    // MARK: - UI
    private lazy var filterContainerView: FilterContainerView = {
        let filterContainerView = FilterContainerView(viewModel: viewModel.filterContainerViewModel)
        
        return filterContainerView
    }()
    
    private lazy var contentTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.register(GeneralContentCell.self)
        tableView.backgroundColor = .secondarySystemBackground
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 215
        tableView.separatorStyle = .none
        tableView.dataSource = self
        tableView.delegate = self
        tableView.sectionFooterHeight = 0
        tableView.contentInset = UIEdgeInsets(top: filterViewHeight, left: 0, bottom: 0, right: 0)
        
        return tableView
    }()
    
    // MARK: - Setup
    init(viewModel: GeneralContentViewModelProtocol, title: String, tabBarType: MemeTabBarItem) {
        self.viewModel = viewModel
        self.naviItemTitle = title
        self.tabBarType = tabBarType
        
        super.init(nibName: nil, bundle: nil)
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupBindings()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.getLocalDatas()
        setupTabBarDidSelect()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarDidSelectDisposable?.dispose()
        tabBarDidSelectDisposable = nil
    }
    
    // MARK: - Setup
    private func setupUI() {
        navigationItem.title = naviItemTitle
        
        view.addSubview(filterContainerView)
        filterContainerView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.left.right.equalToSuperview().inset(Constant.spacing3)
            $0.height.equalTo(filterViewHeight)
        }
        
        view.addSubview(contentTableView)
        contentTableView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            $0.left.right.equalToSuperview()
        }
        
        view.bringSubviewToFront(filterContainerView)
    }
    
    private func setupBindings() {
        viewModel.reloadDataSignal
            .emit(with: self) { (self, _) in
                self.contentTableView.reloadData()
            }
            .disposed(by: rx.disposeBag)
    }
    
    private func setupTabBarDidSelect() {
        tabBarDidSelectDisposable = tabBarController?.rx.didSelect
            .withUnretained(self)
            .filter { (self, _) in
                self.tabBarController?.selectedIndex == self.tabBarType.rawValue
            }
            .filter { (self, _) in
                self.contentTableView.numberOfRows(inSection: 0) > 0
            }
            .subscribe(onNext: { (self, _) in
                let indexPath = IndexPath(row: 0, section: 0)
                self.contentTableView.scrollToRow(at: indexPath, at: .top, animated: true)
            })
    }
}

// MARK: - UITableViewDataSource
extension GeneralContentViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        viewModel.getNumberOfSections()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.getRowsCount(with: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: GeneralContentCell = tableView.dequeueReusableCell(for: indexPath)
        
        let cellViewModel = viewModel.getCellViewModel(at: indexPath)
        cellViewModel.imageTappedRelay
            .asSignal()
            .emit(with: self) { (self, url) in
                let images = [SKPhoto.photoWithImageURL(url.absoluteString)]
                let browser = SKPhotoBrowser(photos: images)
                
                self.present(browser, animated: true)
            }
            .disposed(by: cell.rx.disposeBag)
        
        cellViewModel.shareButtonTappedRelay
            .asSignal()
            .emit(with: self) { (self, cellType) in
                switch cellType {
                case .meme(let meme):
                    guard let url = meme.url else { return }
                    Utility.showShareSheet(items: [url, meme.description], parentVC: self)
                    
                case .joke(let joke):
                    Utility.showShareSheet(items: [joke], parentVC: self)
                    
                case .gif(let url):
                    Utility.showShareSheet(items: [url], parentVC: self)
                }
            }
            .disposed(by: cell.rx.disposeBag)
            
        let isLast = indexPath.row == viewModel.getRowsCount(with: indexPath.section) - 1
        cell.configure(with: cellViewModel, isLast: isLast)
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension GeneralContentViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let cell = cell as? GeneralContentCell else { return }
        cell.pauseViedoPlayer()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        32
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let title = viewModel.getSectionTitle(at: section)
        let view = TextTableViewHeaderView(text: title)
        
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        Constant.spacing3
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .clear
        
        return view
    }
}

// MARK: - UIScrollViewDelegate
extension GeneralContentViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView == contentTableView else { return }
        
        let offsetY = scrollView.contentOffset.y
        
        let dynamicOffset: CGFloat = min(max(-(filterViewHeight + offsetY), -filterViewHeight), .leastNormalMagnitude)
        
        filterContainerView.snp.updateConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(dynamicOffset)
        }
        
        view.setNeedsLayout()
    }
}
