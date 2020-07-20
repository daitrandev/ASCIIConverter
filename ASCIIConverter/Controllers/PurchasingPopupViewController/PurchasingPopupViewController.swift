//
//  PurchasingPopupViewController.swift
//  ASCIIConverter
//
//  Created by DaiTran on 7/5/20.
//  Copyright © 2020 DaiTranDev. All rights reserved.
//

import UIKit
import SwiftyStoreKit

protocol PurchasingPopupViewControllerDelegate: class {
    func removeAds()
}

class PurchasingPopupViewController: UIViewController {
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var donateLoadingButton: LoadingButton!
    @IBOutlet weak var restoreDonateButton: LoadingButton!
    @IBOutlet weak var dismissingDetectorView: UIView!
    @IBOutlet weak var cancelContainerView: UIView!
    
    private let viewModel: PurchasingPopupViewModelType
    
    weak var delegate: PurchasingPopupViewControllerDelegate?
    
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
        
        setDonateButton(isEnabled: true)
        setRestoreDonate(isEnabled: true)
        
        if #available(iOS 13, *) {
            donateLoadingButton.set(buttonColor: traitCollection.userInterfaceStyle.themeColor)
            restoreDonateButton.set(buttonColor: traitCollection.userInterfaceStyle.themeColor)
        } else {
            donateLoadingButton.set(buttonColor: .greenCoral)
            restoreDonateButton.set(buttonColor: .greenCoral)
        }
                
        cancelButton.addTarget(
            self,
            action: #selector(didTapCancel),
            for: .touchUpInside
        )
        
        dismissingDetectorView.addGestureRecognizer(
            UITapGestureRecognizer(
                target: self,
                action: #selector(didTapCancel)
            )
        )
    }
    
    @objc private func didTapCancel() {
        dismiss(animated: true)
    }
    
    @IBAction func didTapDonate() {
        setDonateButton(isEnabled: false)
        
        viewModel.purchaseAds()
    }
    
    @IBAction func didTapRestoreDonateAds() {
        setRestoreDonate(isEnabled: false)
        
        viewModel.restorePurchasing()
    }
}

extension PurchasingPopupViewController: PurchasingPopupViewModelDelegate {
    func setDonateButton(isEnabled: Bool) {
        donateLoadingButton.set(isEnabled: isEnabled)
    }
    
    func setRestoreDonate(isEnabled: Bool) {
        restoreDonateButton.set(isEnabled: isEnabled)
    }
    
    func removeAds() {
        delegate?.removeAds()
    }
    
    func dismiss(completion: (() -> Void)?) {
        dismiss(animated: true, completion: completion)
    }
}
