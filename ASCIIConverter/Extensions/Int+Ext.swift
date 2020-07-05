//
//  Int+Ext.swift
//  ASCIIConverter
//
//  Created by DaiTran on 7/5/20.
//  Copyright © 2020 DaiTranDev. All rights reserved.
//

extension Int {
    var char : Character {
        return Character(UnicodeScalar(self)!)
    }
}
