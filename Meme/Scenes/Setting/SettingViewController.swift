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
import MessageUI
import FirebaseCrashlytics
import SFSafeSymbols
import StoreKit
import DAOBottomSheet

final class SettingViewController: BaseViewController {
    // MARK: - Properties
    private let viewModel: SettingViewModel
    private var product: Product?
    
    // MARK: - UI
    private lazy var settingTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = .clear
        
        return tableView
    }()
    
    private var bottomSheet: DAOBottomSheet?
    
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
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    private func setupBinding() {
        viewModel.appearanceRelay
            .asDriver()
            .drive(with: self, onNext: { (self, _) in
                self.settingTableView.reloadData()
            })
            .disposed(by: rx.disposeBag)
        
        PurchaseManager.shared.isSubscribedRelay
            .asDriver()
            .drive(with: self, onNext: { (self, _) in
                self.settingTableView.reloadData()
            })
            .disposed(by: rx.disposeBag)
        
        PurchaseManager.shared.purchaseSuccessfulRelay
            .asSignal()
            .emit(with: self) { (self, _) in
                self.showPurchaseSuccessfulBanner()
            }
            .disposed(by: rx.disposeBag)
    }
    
    private func showPurchaseSuccessfulBanner() {
        ProgressHUD.banner("Purchase Successful".localized(), "Start enjoying an ad-free browsing experience".localized())
    }
    
    private func showPurchaseFailedBanner(message: String) {
        ProgressHUD.banner("Purchase Failed".localized(), message)
    }
    
    private func showRestorePurchaseFailedBanner(message: String) {
        ProgressHUD.banner("Restore Purchase Failed".localized(), message)
    }
    
    private func showSubscriptionBottomSheet() {
        Task {
            AnalyticsManager.shared.logSubscribeBottomSheetShow()
            
            self.product = try await PurchaseManager.shared.getProduct()
            
            bottomSheet = DAOBottomSheet(parentVC: self, title: product?.displayName, type: .flexible)
            bottomSheet?.delegate = self
            bottomSheet?.backgroundColor = UIColor(dynamicProvider: { traitCollection in
                return traitCollection.userInterfaceStyle == .dark ? .tertiarySystemGroupedBackground : .secondarySystemGroupedBackground
            })
            tabBarController?.tabBar.isHidden = true
            bottomSheet?.show()
        }
    }
    
    private func removeSubscriptionBottomSheet() {
        AnalyticsManager.shared.logSubscribeBottomSheetDismiss()
        bottomSheet?.dismiss()
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
        let isSubscribed = PurchaseManager.shared.isSubscribedRelay.value
        
        if let rowType = viewModel.getRowType(with: indexPath) {
            let sfSymobl: SFSymbol
            let accessoryType: UITableViewCell.AccessoryType
            let symbolConfig = UIImage.SymbolConfiguration(pointSize: 17)
            switch rowType {
            case .appearance:
                accessoryType = .disclosureIndicator
                sfSymobl = .sunMax
                
            case .language:
                accessoryType = .disclosureIndicator
                if #available(iOS 17.4, *) {
                    sfSymobl = .translate
                } else {
                    sfSymobl = .ellipsisBubble
                }
                
            case .removeAds:
                accessoryType = .disclosureIndicator
                sfSymobl = .cart
                
                if isSubscribed {
                    content.secondaryTextProperties.color = .accent
                } else {
                    content.secondaryTextProperties.color = .secondaryLabel
                }
                
            case .restorePurchases:
                accessoryType = .disclosureIndicator
                sfSymobl = .arrowCounterclockwise
                
            case .contactUs:
                accessoryType = .disclosureIndicator
                sfSymobl = .envelope
                
            case .transparencyPolicy:
                accessoryType = .disclosureIndicator
                sfSymobl = .eyes
                
            case .termsofUse:
                accessoryType = .disclosureIndicator
                sfSymobl = .docText
                
            case .version:
                accessoryType = .none
                sfSymobl = .flame
            }
            
            cell.accessoryType = accessoryType
            content.image = UIImage(systemSymbol: sfSymobl, withConfiguration: symbolConfig).withTintColor(.label, renderingMode: .alwaysOriginal)
        }
        
        
        cell.contentConfiguration = content
        cell.selectionStyle = .none
        cell.backgroundColor = UIColor(dynamicProvider: { traitCollection in
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
        return Constant.UI.spacing3
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
            let isSubscribed = PurchaseManager.shared.isSubscribedRelay.value
            guard !isSubscribed else {
                ProgressHUD.banner("Subscribed".localized(), "Already subscribed".localized())
                return
            }
            
            AnalyticsManager.shared.logSettingRemoveAdsClick()
            
            showSubscriptionBottomSheet()
            
        case .restorePurchases:
            let isSubscribed = PurchaseManager.shared.isSubscribedRelay.value
            guard !isSubscribed else {
                ProgressHUD.banner("Subscribed".localized(), "Already subscribed".localized())
                return
            }
            
            AnalyticsManager.shared.logSettingRestorePurchasesClick()
            
            ProgressHUD.animate("Loading".localized(), interaction: false)
            
            PurchaseManager.shared.restorePurchases(completion: { [weak self] error in
                guard let self = self else { return }
                ProgressHUD.dismiss()
                
                if let error = error {
                    self.showRestorePurchaseFailedBanner(message: error.localizedDescription)
                }
            })
            
        case .contactUs:
            AnalyticsManager.shared.logSettingContactUsClick()
            
            if MFMailComposeViewController.canSendMail() {
                let mail = MFMailComposeViewController()
                mail.mailComposeDelegate = self
                mail.setToRecipients([viewModel.contactEmail])
                mail.setSubject("\("Report".localized()): \("Memepire".localized()) App")
                
                present(mail, animated: true)
            } else {
                Crashlytics.crashlytics().record(error: NSError(domain: "Device unable to send email", code: 0, userInfo: nil))
                print("Device unable to send email")
            }
            
        case .transparencyPolicy:
            AnalyticsManager.shared.logTransparencyPolicyClick()
            
            if let url = viewModel.transparencyPolicyURL {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
            
        case .termsofUse:
            AnalyticsManager.shared.logTermsOfUseClick()
            
            if let url = viewModel.termsOfUseURL {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
            
        case .version:
            break
        }
    }
}

// MARK: - MFMailComposeViewControllerDelegate
extension SettingViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
}

// MARK: - DAOBottomSheetDelegate
extension SettingViewController: DAOBottomSheetDelegate {
    func bottomSheetWillDismiss(bottomSheet: DAOBottomSheetViewController) {
        tabBarController?.tabBar.isHidden = false
    }
    
    func setupDAOBottomSheetContentUI(bottomSheet: DAOBottomSheetViewController) -> UIView? {
        guard let product = product else {
            Crashlytics.crashlytics().record(error: NSError(domain: "Product is nil", code: 0, userInfo: nil))
            
            let label: UILabel = {
                let label = UILabel()
                label.text = "Unable to retrieve product information. Please contact us.".localized()
                label.textColor = .label
                label.textAlignment = .center
                label.numberOfLines = 0
                
                return label
            }()
            
            return label
        }
        
        let view = UIView()
        
        let imageView: UIImageView = {
            let imageView = UIImageView(image: Asset.memePatrickIHave3Dollars.image)
            imageView.contentMode = .scaleAspectFit
            
            return imageView
        }()
        
        let descriptionTextView: UITextView = {
            let textView = UITextView()
            textView.font = .systemFont(ofSize: 16, weight: .medium)
            textView.isScrollEnabled = false
            textView.isEditable = false
            textView.textColor = .label
            textView.textAlignment = .center
            textView.backgroundColor = .clear
            
            return textView
        }()
        
        view.addSubview(imageView)
        imageView.snp.makeConstraints {
            $0.left.right.equalToSuperview().inset(Constant.UI.spacing3)
            $0.height.equalTo(150)
            $0.top.equalToSuperview().offset(Constant.UI.spacing2)
        }
        
        view.addSubview(descriptionTextView)
        descriptionTextView.snp.makeConstraints {
            $0.top.equalTo(imageView.snp.bottom).offset(Constant.UI.spacing3)
            $0.left.right.equalTo(imageView)
            $0.bottom.equalToSuperview()
        }
        
        let displayPrice = product.displayPrice
        let subscribePeroid = String(format: "Subscribe for %@/month".localized(), displayPrice)
        
        descriptionTextView.text =
        """
        \(product.description)
        
        \(subscribePeroid)
        """
        
        return view
    }
    
    func setupFooterContentView(with bottomSheet: DAOBottomSheetViewController) -> UIView? {
        let subscribeButton = RoundedRectangleButton(title: "Subscribe Now".localized(), titleColor: .white, backgroundColor: .accent)
        
        subscribeButton.tapEvent
            .subscribe(with: self) { (self, _) in
                AnalyticsManager.shared.logSubscribeButtonClick()
                
                ProgressHUD.animate("Loading".localized(), interaction: false)
                
                PurchaseManager.shared.purchase { [weak self] error in
                    guard let self = self else { return }
                    
                    DispatchQueue.main.async {
                        ProgressHUD.dismiss()
                        
                        if let error = error {
                            self.showPurchaseFailedBanner(message: error.localizedDescription)
                        }
                        
                        self.removeSubscriptionBottomSheet()
                    }
                }
            }
            .disposed(by: subscribeButton.rx.disposeBag)
        
        return subscribeButton
    }
}
