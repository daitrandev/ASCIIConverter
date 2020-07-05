//
//  UITextField+Ext.swift
//  ASCIIConverter
//
//  Created by DaiTran on 7/5/20.
//  Copyright © 2020 DaiTranDev. All rights reserved.
//

extension UITextField {
    func makeRound(borderColor: UIColor) {
        self.clipsToBounds = true
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 5
        self.layer.borderWidth = 2
        self.layer.borderColor = borderColor.cgColor
    }
}
