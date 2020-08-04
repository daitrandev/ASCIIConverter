//
//  PurchasingPopupViewModel.swift
//  ASCIIConverter
//
//  Created by DaiTran on 7/8/20.
//  Copyright © 2020 DaiTranDev. All rights reserved.
//

import SwiftyStoreKit
import KeychainSwift

protocol PurchasingPopupViewModelDelegate: class, MessageDialogPresentable, HUDPresentable {
    func dismiss(completion: (() -> Void)?)
    func setDonateButton(isEnabled: Bool)
    func setRestoreDonate(isEnabled: Bool)
    func removeAds()
}

protocol PurchasingPopupViewModelType: class {
    func purchaseAds()
    func restorePurchasing()
    var delegate: PurchasingPopupViewModelDelegate? { get set }
}

class PurchasingPopupViewModel: PurchasingPopupViewModelType {
    weak var delegate: PurchasingPopupViewModelDelegate?
    
    func purchaseAds() {
        delegate?.showLoading()
        SwiftyStoreKit.purchaseProduct("com.daitrandev.ASCIIConverter.removeads") { result in
            self.delegate?.hideLoading()
            switch result {
            case .success(let purchase):
                print("Purchase Success: \(purchase.productId)")
                
                GlobalKeychain.set(value: true, for: KeychainKey.isPurchased)
                
                self.delegate?.dismiss {
                    self.delegate?.removeAds()
                }
                
            case .error(let error):
                switch error.code {
                case .unknown: print("Unknown error. Please contact support")
                case .clientInvalid: print("Not allowed to make the payment")
                case .paymentCancelled: break
                case .paymentInvalid: print("The purchase identifier was invalid")
                case .paymentNotAllowed: print("The device is not allowed to make the payment")
                case .storeProductNotAvailable: print("The product is not available in the current storefront")
                case .cloudServicePermissionDenied: print("Access to cloud service information is not allowed")
                case .cloudServiceNetworkConnectionFailed: print("Could not connect to the network")
                case .cloudServiceRevoked: print("User has revoked permission to use this cloud service")
                default:
                    print(error.localizedDescription)
                }
            }
            
            self.delegate?.setDonateButton(isEnabled: true)
        }
    }
    
    func restorePurchasing() {
        SwiftyStoreKit.restorePurchases(atomically: true) { [weak self] results in
            if results.restoreFailedPurchases.count > 0 {
                self?.delegate?.showMessageDialog(
                    title: "Failed",
                    message: "Restore Failed",
                    actionName: "Cancel",
                    action: {
                        self?.delegate?.setRestoreDonate(isEnabled: true)
                    }
                )
            }
            else if results.restoredPurchases.count > 0 {
                GlobalKeychain.set(value: true, for: KeychainKey.isPurchased)
                self?.delegate?.showMessageDialog(
                    title: "Success",
                    message: "Restore Successfully",
                    actionName: "Cancel",
                    action: {
                        self?.delegate?.dismiss {
                            self?.delegate?.removeAds()
                        }
                    }
                )
            }
            else {
                self?.delegate?.showMessageDialog(
                    title: "Failed",
                    message: "Nothing to Restore",
                    actionName: "Cancel",
                    action: {
                        self?.delegate?.setRestoreDonate(isEnabled: true)
                    }
                )
            }
        }
    }
}
