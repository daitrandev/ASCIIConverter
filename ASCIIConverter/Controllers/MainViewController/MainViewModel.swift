//
//  MainViewModel.swift
//  ASCIIConverter
//
//  Created by DaiTran on 7/1/20.
//  Copyright © 2020 DaiTranDev. All rights reserved.
//

import SwiftyStoreKit

protocol MainViewModelDelegate: class, MessageDialogPresentable {
    func reloadTableView()
}

protocol MainViewModelType: class {
    var cellLayoutItems: [MainViewModel.CellLayoutItem] { get set }
}

class MainViewModel: MainViewModelType {
    struct CellLayoutItem {
        let base: Base
        var content: String
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
                base: .normalText,
                content: "",
                tag: 0
            ),
            CellLayoutItem(
                base: .asciiCode,
                content: "",
                tag: 1
            ),
            CellLayoutItem(
                base: .binaryCode,
                content: "",
                tag: 2
            ),
            CellLayoutItem(
                base: .octalCode,
                content: "",
                tag: 3
            ),
            CellLayoutItem(
                base: .hexaCode,
                content: "",
                tag: 4
            )
        ]
    }
}
