//
//  String+Ext.swift
//  ASCIIConverter
//
//  Created by DaiTran on 7/5/20.
//  Copyright © 2020 DaiTranDev. All rights reserved.
//

extension String {
    var asciiArray: [UInt32] {
        return unicodeScalars.filter{$0.isASCII}.map{$0.value}
    }
}
