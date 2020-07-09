//
//  MessageDialogPresentable.swift
//  ASCIIConverter
//
//  Created by DaiTran on 7/8/20.
//  Copyright © 2020 DaiTranDev. All rights reserved.
//

import UIKit

protocol MessageDialogPresentable {
    func showMessageDialog(
        title: String,
        message: String,
        actionName: String?,
        action: (() -> Void)?
    )
    
    func showMessageDialog(
        title: String,
        message: String,
        positiveActionName: String,
        positiveAction: (() -> Void)?,
        negativeActionName: String,
        negativeAction: (() -> Void)?
    )
}

extension MessageDialogPresentable where Self: UIViewController {
    func showMessageDialog(
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
    
    func showMessageDialog(
        title: String,
        message: String,
        positiveActionName: String,
        positiveAction: (() -> Void)?,
        negativeActionName: String,
        negativeAction: (() -> Void)?) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        
        alert.addAction(
            UIAlertAction(
                title: positiveActionName,
                style: .default,
                handler: { _ in positiveAction?() }
            )
        )
        
        alert.addAction(
            UIAlertAction(
                title: negativeActionName,
                style: .cancel,
                handler: { _ in negativeAction?() }
            )
        )
        
        present(alert, animated: true)
    }
}
