//
//  UIImage+Ext.swift
//  ASCIIConverter
//
//  Created by DaiTran on 7/5/20.
//  Copyright © 2020 DaiTranDev. All rights reserved.
//

import UIKit

extension UIImage {
    convenience init?(menuSection: MenuSection, theme: Theme) {
        let menuIconName = menuSection.rawValue + "-" + theme.rawValue
        self.init(named: menuIconName)
    }
}
