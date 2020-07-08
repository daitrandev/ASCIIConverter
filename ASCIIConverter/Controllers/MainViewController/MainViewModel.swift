//
//  MainViewModel.swift
//  ASCIIConverter
//
//  Created by DaiTran on 7/1/20.
//  Copyright © 2020 DaiTranDev. All rights reserved.
//

import SwiftyStoreKit

protocol MainViewModelDelegate: class {
    func reloadTableView()
}

protocol MainViewModelType: class {
    var cellLayoutItems: [MainViewModel.CellLayoutItem] { get set }
}

class MainViewModel: MainViewModelType {
    struct CellLayoutItem {
        let baseName: String
        let placeHolder: String
        var content: String
        let allowingCharacters: String
        let base: Int
        let tag: Int
    }
    
    var cellLayoutItems: [CellLayoutItem] {
        didSet {
            delegate?.reloadTableView()
        }
    }
    
    weak var delegate: MainViewModelDelegate?
    
    init() {
        cellLayoutItems = [
            CellLayoutItem(
                baseName: "TEXT",
                placeHolder: "TEXT",
                content: "",
                allowingCharacters: "",
                base: 0,
                tag: 0
            ),
            CellLayoutItem(
                baseName: "ASCII",
                placeHolder: "ASCII CODE",
                content: "",
                allowingCharacters: "0123456789 ",
                base: 10,
                tag: 1
            ),
            CellLayoutItem(
                baseName: "BIN",
                placeHolder: "BINARY CODE",
                content: "",
                allowingCharacters: "01 ",
                base: 2,
                tag: 2
            ),
            CellLayoutItem(
                baseName: "OCT",
                placeHolder: "OCTAL CODE",
                content: "",
                allowingCharacters: "01234567 ",
                base: 8,
                tag: 3
            ),
            CellLayoutItem(
                baseName: "HEX",
                placeHolder: "HEXADECIMAL CODE",
                content: "",
                allowingCharacters: "0123456789aAbBcCdDeEfF ",
                base: 16,
                tag: 4
            )
        ]
    }
}
