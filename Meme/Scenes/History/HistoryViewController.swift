//
//  HistoryViewController.swift
//  Meme
//
//  Created by DAO on 2024/9/6.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import SKPhotoBrowser

final class HistoryViewController: BaseViewController {
    // MARK: - Properties
    private let viewModel: GeneralContentViewModelProtocol
    private var tabBarDidSelectDisposable: Disposable?
    private let filterViewHeight: CGFloat = 35
    
    // MARK: - UI
    private let refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = .systemGray
        
        return refreshControl
    }()
    
    private lazy var filterContainerView: FilterContainerView = {
        let filterContainerView = FilterContainerView(viewModel: viewModel.filterContainerViewModel)
        
        return filterContainerView
    }()
    
    private lazy var historyTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.register(GeneralContentCell.self)
        tableView.backgroundColor = .secondarySystemBackground
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 215
        tableView.separatorStyle = .none
        tableView.dataSource = self
        tableView.delegate = self
        tableView.sectionFooterHeight = 0
        tableView.refreshControl = refreshControl
        tableView.contentInset = UIEdgeInsets(top: filterViewHeight, left: 0, bottom: 0, right: 0)
        
        return tableView
    }()
    
    // MARK: - Setup
    init(viewModel: GeneralContentViewModelProtocol) {
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
        navigationItem.title = "History".localized()
        
        view.addSubview(filterContainerView)
        filterContainerView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.left.right.equalToSuperview().inset(Constant.spacing3)
            $0.height.equalTo(filterViewHeight)
        }
        
        view.addSubview(historyTableView)
        historyTableView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            $0.left.right.equalToSuperview()
        }
        
        view.bringSubviewToFront(filterContainerView)
    }
    
    private func setupBindings() {
        viewModel.reloadDataSignal
            .emit(with: self) { (self, _) in
                self.historyTableView.reloadData()
                self.refreshControl.endRefreshing()
            }
            .disposed(by: rx.disposeBag)
        
        refreshControl.rx.controlEvent(.primaryActionTriggered)
            .withUnretained(self)
            .subscribe(onNext: { (self, _) in
                self.viewModel.getLocalDatas()
            })
            .disposed(by: rx.disposeBag)
    }
    
    private func setupTabBarDidSelect() {
        tabBarDidSelectDisposable = tabBarController?.rx.didSelect
            .withUnretained(self)
            .filter { (self, _) in
                self.tabBarController?.selectedIndex == MemeTabBarItem.history.rawValue
            }
            .filter { (self, _) in
                self.historyTableView.numberOfRows(inSection: 0) > 0
            }
            .subscribe(onNext: { (self, _) in
                let indexPath = IndexPath(row: 0, section: 0)
                self.historyTableView.scrollToRow(at: indexPath, at: .top, animated: true)
            })
    }
}

// MARK: - UITableViewDataSource
extension HistoryViewController: UITableViewDataSource {
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
                case .meme(let url, let description, _):
                    Utility.showShareSheet(items: [url, description], parentVC: self)
                    
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
extension HistoryViewController: UITableViewDelegate {
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
extension HistoryViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView == historyTableView else { return }
        
        let offsetY = scrollView.contentOffset.y
        
        let dynamicOffset: CGFloat = min(max(-(filterViewHeight + offsetY), -filterViewHeight), .leastNormalMagnitude)
        
        filterContainerView.snp.updateConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(dynamicOffset)
        }
        
        view.setNeedsLayout()
    }
}
