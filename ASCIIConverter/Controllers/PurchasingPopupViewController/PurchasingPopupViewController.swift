//
//  PurchasingPopupViewController.swift
//  ASCIIConverter
//
//  Created by DaiTran on 7/5/20.
//  Copyright © 2020 DaiTranDev. All rights reserved.
//

import UIKit
import SwiftyStoreKit

class PurchasingPopupViewController: UIViewController {
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var killAdsButton: UIButton!
    @IBOutlet weak var restoreKillingAdsButton: UIButton!
    @IBOutlet weak var cancelContainerView: UIView!
    
    private let viewModel: PurchasingPopupViewModelType
    
    init() {
        viewModel = PurchasingPopupViewModel()
        super.init(nibName: String(describing: type(of: self)), bundle: Bundle.main)
        modalPresentationStyle = .overCurrentContext
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.delegate = self
        
        cancelButton.addTarget(
            self,
            action: #selector(didTapCancel),
            for: .touchUpInside
        )
        
        view.addGestureRecognizer(
            UITapGestureRecognizer(
                target: self,
                action: #selector(didTapCancel)
            )
        )
        
        cancelContainerView.roundedTopCorners()
    }
    
    @objc private func didTapCancel() {
        dismiss(animated: true)
    }
    
    @IBAction func didTapKillAds() {
        viewModel.purchaseAds()
    }
    
    @IBAction func didTapRestoreKillingAds() {
        viewModel.restorePurchasing()
    }
}

extension PurchasingPopupViewController: PurchasingPopupViewModelDelegate {
    func dismiss(isPurchased: Bool) {
        dismiss(animated: true)
    }
}
