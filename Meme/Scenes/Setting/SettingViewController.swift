//
//  SettingViewController.swift
//  Meme
//
//  Created by DAO on 2024/9/6.
//

import UIKit
import SnapKit
import ProgressHUD
import RxCocoa

final class SettingViewController: BaseViewController {
    // MARK: - Properties
    private let viewModel: SettingViewModel
    
    // MARK: - UI
    private lazy var settingTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = .clear
        
        return tableView
    }()
    
    // MARK: - Init
    init(viewModel: SettingViewModel) {
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
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        AnalyticsManager.shared.logScreenView(screenName: .settings)
    }
    
    // MARK: - Setup
    private func setupUI() {
        navigationItem.title = "Setting".localized()
        
        view.addSubview(settingTableView)
        settingTableView.snp.makeConstraints {
            $0.top.bottom.equalTo(view.safeAreaLayoutGuide)
            $0.left.right.equalToSuperview()
        }
    }
    
    private func setupBinding() {
        viewModel.appearanceRelay
            .asDriver()
            .drive(with: self, onNext: { (self, _) in
                self.settingTableView.reloadData()
            })
            .disposed(by: rx.disposeBag)
    }
}

// MARK: - UITableViewDataSource
extension SettingViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        viewModel.getNumberOfSections()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.getNumberOfRows(in: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let rowTitle = viewModel.getRowTitle(with: indexPath)
        let secondaryTitle = viewModel.getRowSecondaryTitle(with: indexPath)
        
        var content = cell.defaultContentConfiguration()
        content.text = rowTitle
        content.secondaryText = secondaryTitle
        content.secondaryTextProperties.color = .secondaryLabel
        
        cell.contentConfiguration = content
        cell.selectionStyle = .none
        cell.contentView.backgroundColor = UIColor(dynamicProvider: { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ? .tertiarySystemGroupedBackground : .secondarySystemGroupedBackground
        })
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension SettingViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 32
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionTitle = viewModel.getSectionTitle(with: section)
        let view = TextTableViewHeaderView(text: sectionTitle)
        
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return Constant.spacing3
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .clear
        
        return view
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let rowType = viewModel.getRowType(with: indexPath) else { return }
        
        switch rowType {
        case .appearance:
            AnalyticsManager.shared.logSettingAppearanceClick()
            
            let appearanceViewController = AppearanceTableViewController(viewModel: viewModel.appearanceTableViewModel)
            navigationController?.pushViewController(appearanceViewController, animated: true)
            
        case .language:
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                return
            }
            
            AnalyticsManager.shared.logSettingLanguageClick()
            
            UIApplication.shared.open(settingsUrl, options: [:], completionHandler: nil)
            
        case .removeAds:
            AnalyticsManager.shared.logSettingRemoveAdsClick()
            
        case .restorePurchases:
            AnalyticsManager.shared.logSettingRestorePurchasesClick()
            
        case .contactUs:
            AnalyticsManager.shared.logSettingContactUsClick()
            
        case .version:
            break
        }
    }
}
