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
    @IBOutlet weak var baseLabel: UILabel!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var copyButton: UIButton!

    private var item: MainViewModel.CellLayoutItem? {
        didSet {
            guard let item = item else { return }
            baseLabel.text = item.base.name
            textField.text = item.content
            textField.attributedPlaceholder = NSAttributedString(
                string: item.base.fullName,
                attributes: [
                    .foregroundColor: UIColor.lightGray,
                    .font: UIFont(name: "Roboto-Regular", size: 18) as Any
                ]
            )
        }
    }
    
    weak var delegate: MainTableViewCellDelegate?
    
    private func loadTheme() {
        if #available(iOS 13, *) {
            textField.layer.borderColor = traitCollection.userInterfaceStyle.themeColor.cgColor
            textField.keyboardAppearance = traitCollection.userInterfaceStyle == .dark ? .dark: .default
            baseLabel.backgroundColor = traitCollection.userInterfaceStyle.themeColor
            
            let copyButtonImage = traitCollection.userInterfaceStyle == .dark ?
                UIImage(named: "copy-orange") : UIImage(named: "copy-green")
            copyButton.setImage(copyButtonImage, for: .normal)
            return
        }
        
        textField.layer.borderColor = UIColor.greenCoral.cgColor
        textField.keyboardAppearance = .default
        baseLabel.backgroundColor = .greenCoral
        
        let copyButtonImage = UIImage(named: "copy-green")
        copyButton.setImage(copyButtonImage, for: .normal)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        textField.layer.borderWidth = 0.5
        textField.delegate = self
        textField.addTarget(
            self,
            action: #selector(textFieldEditingChanged),
            for: .editingChanged
        )
        loadTheme()
    }
    
    func configure(with item: MainViewModel.CellLayoutItem) {
        self.item = item
    }
    
    @IBAction func didTapCopy() {
        if textField.text!.isEmpty {
            UIPasteboard.general.string = textField.text!
            delegate?.presentCopiedAlert(message: "Copied".localized)
            return
        }
        
        delegate?.presentCopiedAlert(message: "Nothing to copy".localized)
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
