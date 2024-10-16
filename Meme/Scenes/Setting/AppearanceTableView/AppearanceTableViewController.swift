//
//  AppearanceTableViewController.swift
//  Meme
//
//  Created by DAO on 2024/10/11.
//

import UIKit
import RxCocoa
import SFSafeSymbols

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
        tableView.backgroundColor = .secondarySystemBackground
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.allowsSelection = true
        tableView.allowsMultipleSelection = false
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return AppearanceStyle.allCases.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let appearanceType = AppearanceStyle.allCases[indexPath.row]
        cell.textLabel?.text = appearanceType.rawValue.localized()
        cell.selectionStyle = .none
        cell.backgroundColor = .secondarySystemGroupedBackground

        if tableView.indexPathForSelectedRow == indexPath {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.visibleCells.forEach { $0.accessoryType = .none }
        
        if let cell = tableView.cellForRow(at: indexPath) {
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
        
        viewModel.appearanceRelay.accept(appearanceType)
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return .leastNormalMagnitude
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .clear
        
        return view
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return .leastNormalMagnitude
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .clear
        
        return view
    }
}
