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
    var delegate: MainViewModelDelegate? { get set }
    func update(layoutItem: MainViewModel.CellLayoutItem)
}

class MainViewModel: MainViewModelType {
    struct CellLayoutItem {
        let base: Base
        var content: String
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
                content: ""
            ),
            CellLayoutItem(
                base: .asciiCode,
                content: ""
            ),
            CellLayoutItem(
                base: .binaryCode,
                content: ""
            ),
            CellLayoutItem(
                base: .octalCode,
                content: ""
            ),
            CellLayoutItem(
                base: .hexaCode,
                content: ""
            )
        ]
    }
    
    func update(layoutItem: CellLayoutItem) {
        for index in 0..<cellLayoutItems.count {
            if cellLayoutItems[index].base == layoutItem.base {
                cellLayoutItems[index] = layoutItem
                break
            }
        }
                
        let asciiCodes: [String]
                        
        // Convert normalText to ASCII Code
        if layoutItem.base == .normalText {
            asciiCodes = convertTextToASCIICode(from: layoutItem.content) ?? []
        } else {
            var numbers = layoutItem.content.components(separatedBy: " ")
            for index in 0..<numbers.count {
                let number = numbers[index].uppercased()
                guard let asciiCode = Int(number, radix: layoutItem.base.rawValue) else {
                    clearAllContent(exceptedBase: layoutItem.base)
                    return
                }
                numbers[index] = String(asciiCode)
            }
            asciiCodes = numbers
        }
        
        clearAllContent(exceptedBase: layoutItem.base)
        
        updateASCIICodeToAllBases(exceptedBase: layoutItem.base, asciiCodes: asciiCodes)
        
        convertASCIICodeToText()
    }
    
    private func clearAllContent(exceptedBase: Base) {
        var cellLayoutItems = self.cellLayoutItems
        for index in 0..<cellLayoutItems.count {
            if cellLayoutItems[index].base != exceptedBase {
                cellLayoutItems[index].content = ""
            }
        }
        self.cellLayoutItems = cellLayoutItems
    }
    
    private func convertTextToASCIICode(from input: String) -> [String]? {
        var stringNumbers: [String] = []
        
        for char in input {
            guard let asciiValue = char.asciiValue else {
                return nil
            }
            let stringNumber = String(asciiValue)
            stringNumbers.append(stringNumber)
        }
        return stringNumbers
    }
    
    private func convertASCIICodeToText() {
        guard
            let asciiLayoutItem = cellLayoutItems.first(where: { $0.base == .asciiCode }),
            var normalTextLayoutItem = cellLayoutItems.first(where: { $0.base == .normalText }) else {
            return
        }
        
        normalTextLayoutItem.content = ""
        let numbers = asciiLayoutItem.content.components(separatedBy: " ").filter { !$0.isEmpty }
    
        for number in numbers {
            guard let number = Int(number), number > 31, number < 128 else {
                normalTextLayoutItem.content = ""
                break
            }
            normalTextLayoutItem.content += String(describing: number.char)
        }
        
        for index in 0..<cellLayoutItems.count {
            if cellLayoutItems[index].base == .normalText {
                cellLayoutItems[index] = normalTextLayoutItem
                break
            }
        }
    }
    
    private func updateASCIICodeToAllBases(exceptedBase: Base, asciiCodes: [String]) {
        // Convert number array to all bases
        var cellLayoutItems = self.cellLayoutItems
        for number in asciiCodes {
            guard let number = Int(number) else {
                break
            }
            
            for index in 1..<cellLayoutItems.count {
                let layoutItem = cellLayoutItems[index]
                if layoutItem.base != exceptedBase {
                    let outputNumberStr = String(number, radix: layoutItem.base.rawValue)
                    cellLayoutItems[index].content += outputNumberStr.uppercased() + " "
                }
            }
        }
        
        self.cellLayoutItems = cellLayoutItems
    }
}
