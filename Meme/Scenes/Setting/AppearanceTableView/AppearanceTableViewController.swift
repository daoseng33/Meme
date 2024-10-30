//
//  AppearanceTableViewController.swift
//  Meme
//
//  Created by DAO on 2024/10/11.
//

import UIKit
import RxCocoa
import SFSafeSymbols
import RxDataSources

final class AppearanceTableViewController: UITableViewController {
    // MARK: - Properties
    private let viewModel: AppearanceTableViewModel
    
    // MARK: - Init
    init(viewModel: AppearanceTableViewModel) {
        self.viewModel = viewModel
        super.init(style: .insetGrouped)
        hidesBottomBarWhenPushed = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let index = AppearanceStyle.allCases.firstIndex(of: viewModel.appearanceRelay.value) ?? 0
        let indexPath = IndexPath(row: index, section: 0)
        tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        AnalyticsManager.shared.logScreenView(screenName: .appearance)
    }
    
    // MARK: - Setup
    private func setupUI() {
        navigationItem.title = "Appearance".localized()
        tableView.backgroundColor = .secondarySystemBackground
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.allowsSelection = true
        tableView.allowsMultipleSelection = false
    }
    
    private func setupTableView() {
        tableView.dataSource = nil
        tableView.delegate = nil
        
        tableView.rx.setDelegate(self)
            .disposed(by: rx.disposeBag)
        
        let dataSource = RxTableViewSectionedReloadDataSource<AppearanceSection> { dataSource, tableView, indexPath, item in
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            
            let appearanceType = AppearanceStyle.allCases[indexPath.row]
            cell.textLabel?.text = appearanceType.rawValue.localized()
            cell.selectionStyle = .none
            cell.backgroundColor = UIColor(dynamicProvider: { traitCollection in
                return traitCollection.userInterfaceStyle == .dark ? .tertiarySystemGroupedBackground : .secondarySystemGroupedBackground
            })

            if tableView.indexPathForSelectedRow == indexPath {
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }
            
            return cell
        }
        
        viewModel.dataSource = dataSource
        
        viewModel.sectionsRelay
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: rx.disposeBag)
        
        tableView.rx.itemSelected
            .subscribe(with: self) { (self, indexPath) in
                self.tableView.visibleCells.forEach { $0.accessoryType = .none }
                
                if let cell = self.tableView.cellForRow(at: indexPath) {
                    cell.accessoryType = .checkmark
                }
                
                let appearanceType = AppearanceStyle.allCases[indexPath.row]
                
                AnalyticsManager.shared.logAppearanceModeSelect(mode: appearanceType)
                
                switch appearanceType {
                    
                case .system:
                    AppearanceManager.shared.changeAppearance(.system)
                    
                case .light:
                    AppearanceManager.shared.changeAppearance(.light)
                    
                case .dark:
                    AppearanceManager.shared.changeAppearance(.dark)
                }
                
                self.viewModel.appearanceRelay.accept(appearanceType)
            }
            .disposed(by: rx.disposeBag)
    }
}
