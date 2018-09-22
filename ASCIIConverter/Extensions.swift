//
//  Extensions.swift
//  ASCIIConverter
//
//  Created by Dai Tran on 9/22/18.
//  Copyright © 2018 DaiTranDev. All rights reserved.
//

import UIKit

extension UINavigationController {
    open override var childForStatusBarStyle: UIViewController? {
        return visibleViewController
    }
}

extension UITextField {
    func makeRound(borderColor: UIColor) {
        self.clipsToBounds = true
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 5
        self.layer.borderWidth = 2
        self.layer.borderColor = borderColor.cgColor
    }
}

extension UILabel {
    func makeRound() {
        self.clipsToBounds = true
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 5
    }
}
