//
//  PurchaseManager.swift
//  Meme
//
//  Created by DAO on 2024/10/18.
//

import Foundation
import StoreKit
import RxRelay
import FirebaseCrashlytics

final class PurchaseManager {
    // MARK: - Properties
    static let shared = PurchaseManager()
    private var transactionListenerTask: Task<Void, Error>?
    
    private let monthlySubscriptionId = "com.meme.subscription.month"
    
    let isSubscribedRelay = BehaviorRelay<Bool>(value: false)
    let purchaseSuccessfulRelay = PublishRelay<Void>()
    
    // MARK: - Init
    private init() {
        startListeningForTransactions()
    }
    
    // MARK: - Purchase Related
    func purchase(completion: ((Error?) -> Void)?) {
        Task {
            do {
                let products = try await Product.products(for: [monthlySubscriptionId])
                guard let product = products.first else {
                    print("No product found for identifier: \(monthlySubscriptionId)")
                    completion?(nil)
                    return
                }
                
                // 檢查是否已經購買
                guard await !isPurchased() else {
                    print("Product already purchased")
                    completion?(nil)
                    return
                }
                
                let result = try await product.purchase()
                AnalyticsManager.shared.logPurchaseStatusEvent(purchaseResult: result)
                
                switch result {
                case .success(let verificationResult):
                    switch verificationResult {
                    case .verified(let transaction):
                        await handleVerifiedTransaction(transaction)
                        completion?(nil)
                    case .unverified(_, let error):
                        Crashlytics.crashlytics().record(error: error)
                        print("Unverified transaction: \(error)")
                        completion?(error)
                    }
                case .userCancelled:
                    print("User cancelled the purchase")
                    completion?(nil)
                case .pending:
                    print("Purchase is pending")
                    completion?(nil)
                @unknown default:
                    print("Unknown purchase result")
                    completion?(nil)
                }
            } catch {
                Crashlytics.crashlytics().record(error: error)
                print("Failed to purchase product: \(error)")
                completion?(error)
            }
        }
    }
    
    func restorePurchases(completion: ((Error?) -> Void)? = nil) {
        Task {
            do {
                try await AppStore.sync()
                await checkPurchaseStatus()
                completion?(nil)
            } catch {
                Crashlytics.crashlytics().record(error: error)
                print("Failed to restore purchases: \(error)")
                completion?(error)
            }
        }
    }
    
    func startListeningForTransactions() {
        transactionListenerTask?.cancel()
        transactionListenerTask = listenForTransactions()
    }
    
    private func listenForTransactions() -> Task<Void, Error> {
        return Task.detached {
            for await result in Transaction.updates {
                do {
                    let transaction = try self.checkVerified(result)
                    await self.handleTransaction(transaction)
                    await transaction.finish()
                } catch {
                    print("Transaction failed: \(error)")
                }
            }
        }
    }
    
    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified(_, let error):
            throw error
        case .verified(let safe):
            return safe
        }
    }
    
    private func handleTransaction(_ transaction: Transaction) async {
        if transaction.productID == monthlySubscriptionId {
                if transaction.revocationDate == nil && transaction.expirationDate ?? Date.distantFuture > Date() {
                    await updateSubscriptionStatus(active: true)
                } else {
                    await updateSubscriptionStatus(active: false)
                }
            } else {
                print("Unhandled product ID: \(transaction.productID)")
            }
    }
    
    private func handleVerifiedTransaction(_ transaction: Transaction) async {
        await handleTransaction(transaction)
        print("Purchase successful for product: \(transaction.productID)")
        purchaseSuccessfulRelay.accept(())
    }
    
    private func isPurchased() async -> Bool {
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result {
                if transaction.productID == monthlySubscriptionId {
                    return true
                }
            }
        }
        return false
    }
    
    private func updateSubscriptionStatus(active: Bool) async {
        print("Subscription status updated: \(active)")
        isSubscribedRelay.accept(active)
        _ = KeychainManager.shared.saveBool(active, forKey: .isSubscribed)
    }
    
    private func checkPurchaseStatus() async {
        let isPurchased = await isPurchased()
        await updateSubscriptionStatus(active: isPurchased)
    }
}

