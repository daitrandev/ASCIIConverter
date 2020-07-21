//
//  Base.swift
//  ASCIIConverter
//
//  Created by DaiTran on 7/9/20.
//  Copyright © 2020 DaiTranDev. All rights reserved.
//

enum Base: Int {
    case normalText = 0
    case binaryCode = 2
    case octalCode = 8
    case asciiCode = 10
    case hexaCode = 16
    
    var name: String {
        switch self {
        case .normalText:
            return "TEXT"
            
        case .asciiCode:
            return "ASCII"
            
        case .binaryCode:
            return "BINARY"
            
        case .octalCode:
            return "OCT"
            
        case .hexaCode:
            return "HEX"
        }
    }
    
    var fullName: String {
        switch self {
        case .normalText:
            return "TEXT"
            
        case .asciiCode:
            return "ASCII CODE"
            
        case .binaryCode:
            return "BINARY CODE"
            
        case .octalCode:
            return "OCTAL CODE"
            
        case .hexaCode:
            return "HEXADECIMAL CODE"
        }
    }
    
    var allowingCharacters: String? {
        switch self {
        case .normalText:
            return nil
            
        case .asciiCode:
            return "0123456789 "
            
        case .binaryCode:
            return "01 "
            
        case .octalCode:
            return "01234567 "
            
        case .hexaCode:
            return "0123456789aAbBcCdDeEfF "
        }
    }
}
