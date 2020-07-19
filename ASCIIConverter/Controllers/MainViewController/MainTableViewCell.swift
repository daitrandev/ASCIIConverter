//
//  MainTableViewCell.swift
//  ASCIIConverter
//
//  Created by Dai Tran on 11/5/17.
//  Copyright © 2017 DaiTranDev. All rights reserved.
//

import UIKit

protocol MainTableViewCellDelegate: class {
    func update(layoutItem: MainViewModel.CellLayoutItem)
    func presentCopiedAlert(message: String)
}

class MainTableViewCell: UITableViewCell {
    private let label: UILabel = {
        let label = UILabel()
        label.adjustsFontSizeToFitWidth = true
        label.font = UIFont(name: "Roboto-Medium", size: 18)!
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
        textField.textColor = .black
        textField.delegate = self
        textField.returnKeyType = .done
        textField.keyboardType = .asciiCapable
        textField.font = UIFont(name: "Roboto-Regular", size: 18)!
        textField.addTarget(self, action: #selector(textFieldEditingChanged), for: .editingChanged)
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private lazy var copyButton: UIButton = {
        let button = UIButton(type: UIButton.ButtonType.custom)
        button.addTarget(self, action: #selector(didTapCopy), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private var item: MainViewModel.CellLayoutItem? {
        didSet {
            guard let item = item else { return }
            label.text = item.base.name
            textField.text = item.content
            textField.attributedPlaceholder = NSAttributedString(
                string: item.base.fullName,
                attributes: [
                    .foregroundColor: UIColor.gray,
                    .font: UIFont(name: "Roboto-Regular", size: 18) as Any
                ]
            )
        }
    }
    
    weak var delegate: MainTableViewCellDelegate?
    
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
    
    @objc private func didTapCopy() {
        if textField.text != "" {
            UIPasteboard.general.string = textField.text!
            delegate?.presentCopiedAlert(message: "Copied".localized)
            return
        }
        
        delegate?.presentCopiedAlert(message: "Nothing to copy".localized)
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
        if (string == "" || item?.base == .normalText) {
            return true
        }
        
        if (string == " " && textField.text?.last == " ") {
            return false
        }
        
        guard let allowingCharacters = item?.base.allowingCharacters else {
            return true
        }
        
        for char in string {
            if (!allowingCharacters.contains(char)) {
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
        item?.content = textField.text!
        if item?.base == .hexaCode {
            item?.content = textField.text!.uppercased()
        }
        
        if let item = item {
            delegate?.update(layoutItem: item)
        }
    }
}
