//
//  MessageDialogPresentable.swift
//  ASCIIConverter
//
//  Created by DaiTran on 7/8/20.
//  Copyright © 2020 DaiTranDev. All rights reserved.
//

import UIKit

protocol MessageDialogPresentable {
    func showMessage(
        title: String,
        message: String,
        actionName: String?,
        action: (() -> Void)?
    )
}

extension MessageDialogPresentable where Self: UIViewController {
    func showMessage(
        title: String,
        message: String,
        actionName: String?,
        action: (() -> Void)?) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        
        if let actionName = actionName {
            alert.addAction(
                UIAlertAction(
                    title: actionName,
                    style: .default,
                    handler: { _ in action?() }
                )
            )
        }
        
        present(alert, animated: true)
    }
}
