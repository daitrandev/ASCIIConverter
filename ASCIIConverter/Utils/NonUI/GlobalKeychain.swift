//
//  GlobalKeychain.swift
//  ASCIIConverter
//
//  Created by DaiTran on 7/19/20.
//  Copyright © 2020 DaiTranDev. All rights reserved.
//

import KeychainSwift

class GlobalKeychain {
    private static let keychain: KeychainSwift = {
        let keychain = KeychainSwift()
        return keychain
    }()
    
    static func getBool(for key: String) -> Bool? {
        keychain.getBool(key)
    }
    
    static func set(value: Bool, for key: String) {
        keychain.set(value, forKey: key)
    }
    
    static func clear(for key: String) {
        keychain.delete(key)
    }
}
