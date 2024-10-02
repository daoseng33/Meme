//
//  HistoryViewController.swift
//  Meme
//
//  Created by DAO on 2024/9/6.
//

import UIKit

final class HistoryViewController: BaseViewController {
    // MARK: - Properties
    private let viewModel: HistoryViewModelProtocol
    
    // MARK: - Setup
    init(viewModel: HistoryViewModelProtocol) {
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
    }
    
    // MARK: - Setup
    private func setupUI() {
        navigationItem.title = "History".localized()
    }
}
