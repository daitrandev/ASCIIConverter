//
//  CellModel.swift
//  ASCIIConverter
//
//  Created by Dai Tran on 10/27/18.
//  Copyright © 2018 DaiTranDev. All rights reserved.
//
import UIKit
import Foundation

struct CellModel {
    var labelText: String
    var textFieldPlaceHolderText: String
    var textFieldText: String
    var keyboardType: UIKeyboardType
    var allowingCharacters: String
    var base: Int
    var tag: Int
}
