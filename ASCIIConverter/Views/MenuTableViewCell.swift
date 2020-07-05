//
//  MenuTableViewCell.swift
//  ASCIIConverter
//
//  Created by Macbook on 1/27/19.
//  Copyright © 2019 DaiTranDev. All rights reserved.
//

import UIKit

class MenuTableViewCell: UITableViewCell {
    private var item: MenuModel? {
        didSet {
            guard let item = item else { return }
            let theme: Theme = UserDefaults.standard.bool(forKey: isLightThemeKey) ? .light : .dark
            iconImageView.image = UIImage(menuSection: item.menuSection, theme: theme)
            titleLabel.text = NSLocalizedString(item.title, comment: "")
        }
    }
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private var titleLabel: UILabel = {
        let label = UILabel()
        label.adjustsFontSizeToFitWidth = true
        label.font = UIFont.systemFont(ofSize: 14)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var isLightTheme: Bool? {
        didSet {
            guard let isLightTheme = isLightTheme else { return }
            titleLabel.textColor = isLightTheme ? .black : .white
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        addSubview(iconImageView)
        addSubview(titleLabel)
        
        iconImageView.constraintTo(
            top: contentView.topAnchor, bottom: nil,
            left: contentView.leftAnchor, right: nil,
            topConstant: 8, bottomConstant: 0, leftConstant: 8, rightConstant: 0
        )
        iconImageView.widthAnchor.constraint(equalToConstant: frame.height / 2).isActive = true
        iconImageView.heightAnchor.constraint(equalTo: iconImageView.widthAnchor).isActive = true
        
        titleLabel.constraintTo(
            top: iconImageView.topAnchor, bottom: iconImageView.bottomAnchor,
            left: iconImageView.rightAnchor, right: rightAnchor,
            topConstant: 0, bottomConstant: 0, leftConstant: 8, rightConstant: 0
        )
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with item: MenuModel) {
        self.item = item
    }
}
