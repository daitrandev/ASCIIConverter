//
//  MainTableViewCell.swift
//  ASCIIConverter
//
//  Created by Dai Tran on 11/5/17.
//  Copyright © 2017 DaiTranDev. All rights reserved.
//

import UIKit

protocol MainTableViewCellDelegate: class {
    func setAllBaseToEmpty(exceptedIndex: Int)
    func convertToAllBases(exceptedIndex: Int, numbers: [String])
    func convertASCIICodeToText()
    func convertTextToASCIICode(from textField: UITextField) -> [String]?
    func updateCellModel(tag: Int, textFieldText: String)
    func presentCopiedAlert(message: String)
}

class MainTableViewCell: UITableViewCell {
    private let label: UILabel = {
        let label = UILabel()
        label.text = "ASCII"
        label.adjustsFontSizeToFitWidth = true
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textAlignment = .center
        label.layer.cornerRadius = 5
        label.layer.masksToBounds = true
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var textField: UITextField = {
        let textField = UITextField()
        textField.layer.borderWidth = 2
        textField.layer.cornerRadius = 5
        textField.textAlignment = .center
        textField.layer.masksToBounds = true
        textField.backgroundColor = .white
        textField.delegate = self
        textField.returnKeyType = .done
        textField.keyboardType = .asciiCapable
        textField.addTarget(self, action: #selector(textFieldEditingChanged), for: .editingChanged)
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private lazy var copyButton: UIButton = {
        let button = UIButton(type: UIButton.ButtonType.custom)
        button.addTarget(self, action: #selector(onCopyAction), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private var item: MainViewModel.CellLayoutItem? {
        didSet {
            guard let item = item else { return }
            label.text = item.baseName
            textField.text = item.content
            textField.tag = item.tag
            textField.attributedPlaceholder = NSAttributedString(
                string: item.placeHolder,
                attributes: [.foregroundColor: UIColor.gray]
            )
        }
    }
    
    weak var delegate: MainTableViewCellDelegate?
    
    private let isFreeVersion = Bundle.main.infoDictionary?["isFreeVersion"] as? Bool
    
    private func setupLayout() {
        backgroundColor = .clear
        
        addSubview(label)
        addSubview(textField)
        
        label.constraintTo(
            top: topAnchor, bottom: bottomAnchor,
            left: contentView.leftAnchor, right: nil,
            topConstant: 8, bottomConstant: -8, leftConstant: 8, rightConstant: -8
        )
        label.widthAnchor.constraint(equalToConstant: 80).isActive = true
        
        guard let isFreeVersion = isFreeVersion else { return }
        if isFreeVersion {
            textField.constraintTo(
                top: topAnchor, bottom: bottomAnchor,
                left: label.rightAnchor, right: contentView.rightAnchor,
                topConstant: 8, bottomConstant: -8, leftConstant: 8, rightConstant: -8
            )
            return
        }
        
        addSubview(copyButton)
        textField.constraintTo(top: topAnchor, bottom: bottomAnchor, left: label.rightAnchor, right: copyButton.leftAnchor, topConstant: 8, bottomConstant: -8, leftConstant: 8, rightConstant: -8)
        
        copyButton.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -8).isActive = true
        copyButton.centerYAnchor.constraint(equalTo: textField.centerYAnchor).isActive = true
        copyButton.widthAnchor.constraint(equalTo: copyButton.heightAnchor).isActive = true
        copyButton.heightAnchor.constraint(equalToConstant: 22).isActive = true
    }
    
    private func loadTheme() {
        if #available(iOS 13, *) {
            textField.layer.borderColor = traitCollection.userInterfaceStyle.themeColor.cgColor
            textField.keyboardAppearance = traitCollection.userInterfaceStyle == .dark ? .dark: .default
            label.backgroundColor = traitCollection.userInterfaceStyle.themeColor
            
            let copyButtonImage = traitCollection.userInterfaceStyle == .dark ?
                UIImage(named: "copy-orange") : UIImage(named: "copy-green")
            copyButton.setImage(copyButtonImage, for: .normal)
            return
        }
        
        textField.layer.borderColor = UIColor.greenCoral.cgColor
        textField.keyboardAppearance = .default
        label.backgroundColor = .white
        
        let copyButtonImage = UIImage(named: "copy-green")
        copyButton.setImage(copyButtonImage, for: .normal)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLayout()
        loadTheme()
    }
    
    func configure(with item: MainViewModel.CellLayoutItem) {
        self.item = item
    }
    
    @objc func onCopyAction() {
        if textField.text != "" {
            UIPasteboard.general.string = textField.text!
            delegate?.presentCopiedAlert(message: NSLocalizedString("Copied", comment: ""))
            return
        }
        
        delegate?.presentCopiedAlert(message: NSLocalizedString("Nothing to copy", comment: ""))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        loadTheme()
    }
}

extension MainTableViewCell: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let item = item else { return false }
        if (string == "" || item.tag == 0) {
            return true
        }
        
        if (string == " " && textField.text?.last == " ") {
            return false
        }
        
        for char in string {
            if (!item.allowingCharacters.contains(char)) {
                return false
            }
        }
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @objc func textFieldEditingChanged() {
        if textField.tag == 4 {
            textField.text = textField.text?.uppercased()
        }

        delegate?.updateCellModel(tag: textField.tag, textFieldText: textField.text!)
        
        guard let item = item else { return }
        var numbers:[String]?
        
        delegate?.setAllBaseToEmpty(exceptedIndex: textField.tag)
        
        // Convert sender.text to number array
        if textField.tag == 0 {
            numbers = delegate?.convertTextToASCIICode(from: textField)
        } else {
            // Convert to base 10
            numbers = textField.text?.components(separatedBy: " ")
            if var base10Nums = numbers, textField.tag != 1 {
                for i in 0..<base10Nums.count {
                    let num = base10Nums[i].uppercased()
                    if let base10 = Int(num, radix: item.base) {
                        base10Nums[i] = String(base10)
                    } else if num != "" {
                        delegate?.setAllBaseToEmpty(exceptedIndex: textField.tag)
                        return
                    }
                }
                numbers = base10Nums
            }
        }
        
        if numbers == nil {
            return
        }
        
        // Convert number array to all bases
        delegate?.convertToAllBases(exceptedIndex: textField.tag, numbers: numbers!)

        // Convert base10 to TEXT
        if textField.tag != 0 {
            delegate?.convertASCIICodeToText()
        }
    }
}
