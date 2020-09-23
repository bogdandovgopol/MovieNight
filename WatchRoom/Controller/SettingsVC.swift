//
//  SettingsVC.swift
//  WatchRoom
//
//  Created by Bogdan on 23/9/20.
//

import UIKit
import StoreKit
import FirebaseCrashlytics

enum ProductId {
    static let tip1 = "dev.dovgopol.MovieNight.tip1"
    static let tip2 = "dev.dovgopol.MovieNight.tip4"
}

class SettingsVC: UIViewController {
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var tip1Btn: UIButton!
    @IBOutlet weak var tip2Btn: UIButton!
    @IBOutlet weak var leaveReviewBtn: UIButton!
    @IBOutlet weak var signOutBtn: UIButton!
    
    var isButtonLoading = false
    var products = [SKProduct]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
        fetchProducts()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        isUserSignedIn { [weak self](type) in
            guard let self = self else { return }
            guard let _ = type else {
                DispatchQueue.main.async {
                    self.presentSignInVC()
                    self.tabBarController?.selectedIndex = 0
                }
                return
            }
        }
    }
    
    private func fetchProducts() {
        let request = SKProductsRequest(productIdentifiers: [ProductId.tip1, ProductId.tip2])
        request.delegate = self
        request.start()
    }
    
    private func createPayment(product: SKProduct) {
        if SKPaymentQueue.canMakePayments() {
            let payment = SKPayment(product: product)
            SKPaymentQueue.default().add(self)
            SKPaymentQueue.default().add(payment)
        }
    }
    
    @IBAction func onTip1Pressed(_ sender: Any) {
        guard products.count > 0 else { return }
        createPayment(product: products.first!)
    }
    
    @IBAction func onTip2Pressed(_ sender: Any) {
        guard products.count > 0 else { return }
        createPayment(product: products.last!)
    }
    
    @IBAction func onRestorePressed(_ sender: Any) {
        if SKPaymentQueue.canMakePayments() {
            SKPaymentQueue.default().restoreCompletedTransactions()
            SKPaymentQueue.default().add(self)
        }
    }
    
    @IBAction func onLeaveReviewPressed(_ sender: Any) {
        rateApp()
    }
    
    private func rateApp() {
        if let url = URL(string: "itms-apps://itunes.apple.com/app/" + "1520364631?action=write-review") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    @IBAction func onSignOutPressed(_ sender: Any) {
        guard isButtonLoading == false else { return }
        
        isButtonLoading = true
        UserService.shared.signOut { [weak self](error) in
            guard let self = self else { return }
            DispatchQueue.main.async {
                if let error = error {
                    Crashlytics.crashlytics().record(error: error)
                    self.presentSimpleAlert(withTitle: "Something went wrong", message: error.rawValue)
                }
                self.tabBarController?.selectedIndex = 0
                self.isButtonLoading = false
            }
        }
    }
    
    func updateUI() {
        signOutBtn.layer.cornerRadius = 7
        leaveReviewBtn.layer.cornerRadius = 7
        leaveReviewBtn.layer.borderWidth = 1
        leaveReviewBtn.layer.borderColor = UIColor(named: "SecondaryColor")?.cgColor
    }
    
}

extension SettingsVC: SKProductsRequestDelegate, SKPaymentTransactionObserver {
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        for product in response.products {
            products.append(product)
        }
        guard products.count > 0 else { return }
        
        DispatchQueue.main.async {
            self.tip1Btn.setTitle(self.products.first?.localizedPrice, for: .normal)
            self.tip2Btn.setTitle(self.products.last?.localizedPrice, for: .normal)
        }
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchasing: break
            case .purchased:
                finishTransaction(transaction: transaction)
                UserDefaults.standard.set(true, forKey: Keys.AdsRemoved)
                finishTransaction(transaction: transaction)
            case .restored:
                UserDefaults.standard.set(true, forKey: Keys.AdsRemoved)
                finishTransaction(transaction: transaction)
            case .failed, .deferred:
                finishTransaction(transaction: transaction)
            @unknown default:
                finishTransaction(transaction: transaction)
            }
        }
    }
    
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        if UserDefaults.standard.bool(forKey: Keys.AdsRemoved) {
            self.presentSimpleAlert(withTitle: "Restore purchase", message: "You successfuly restored your purchase.")
        } else {
            self.presentSimpleAlert(withTitle: "Restore purchase", message: "Nothing to restore")
        }
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        debugPrint(error.localizedDescription)
    }
    
    private func finishTransaction(transaction: SKPaymentTransaction) {
        SKPaymentQueue.default().finishTransaction(transaction)
        SKPaymentQueue.default().remove(self)
    }
}
