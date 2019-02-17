//
//  Extensions.swift
//  ASCIIConverter
//
//  Created by Dai Tran on 9/22/18.
//  Copyright © 2018 DaiTranDev. All rights reserved.
//

import UIKit
import SideMenu

extension UIView {
    func constraintTo(top: NSLayoutYAxisAnchor?, bottom: NSLayoutYAxisAnchor?, left: NSLayoutXAxisAnchor?, right: NSLayoutXAxisAnchor?, topConstant: CGFloat, bottomConstant: CGFloat, leftConstant: CGFloat, rightConstant: CGFloat) {
        
        if let top = top {
            topAnchor.constraint(equalTo: top, constant: topConstant).isActive = true
        }
        
        if let bottom = bottom {
            bottomAnchor.constraint(equalTo: bottom, constant: bottomConstant).isActive = true
        }
        
        if let left = left {
            leftAnchor.constraint(equalTo: left, constant: leftConstant).isActive = true
        }
        
        if let right = right {
            rightAnchor.constraint(equalTo: right, constant: rightConstant).isActive = true
        }
    }
}

extension UINavigationController {
    open override var childForStatusBarStyle: UIViewController? {
        return topViewController
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

extension UIColor {
    static let greenCoral = UIColor(red:0.14, green:0.84, blue:0.11, alpha:1.0)
}

extension UIImage {
    convenience init?(menuSection: MenuSection, theme: Theme) {
        let menuIconName = menuSection.rawValue + "-" + theme.rawValue
        self.init(named: menuIconName)
    }
}
