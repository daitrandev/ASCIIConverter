//
//  UITraitCollection+Ext.swift
//  ASCIIConverter
//
//  Created by DaiTran on 7/4/20.
//  Copyright © 2020 DaiTranDev. All rights reserved.
//

import UIKit

@available(iOS 12.0, *)
extension UIUserInterfaceStyle {
    var themeColor: UIColor {
        switch self {
        case .light, .unspecified:
            return .greenCoral
            
        case .dark:
            return .orange
            
        @unknown default:
            return .greenCoral
        }
    }
}
