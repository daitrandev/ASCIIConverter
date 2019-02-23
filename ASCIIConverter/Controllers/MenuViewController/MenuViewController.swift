//
//  MainViewController.swift
//  ASCIIConverter
//
//  Created by Macbook on 1/27/19.
//  Copyright © 2019 DaiTranDev. All rights reserved.
//

import UIKit

protocol MenuViewControllerDelegate {
    func presentMailComposeViewController()
    func presentRatingAction()
    func presentShareAction()
    func changeTheme()
}

class MenuViewController: UIViewController {
    
    let cellId = "cellId"
    
    let menuModels = [
        MenuModel(title: "Theme", menuSection: .theme),
        MenuModel(title: "Feedback", menuSection: .feedback),
        MenuModel(title: "Rate", menuSection: .rate),
        MenuModel(title: "Share", menuSection: .share)
    ]
    
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorStyle = .none
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(MenuTableViewCell.self, forCellReuseIdentifier: cellId)
        tableView.dataSource = self
        tableView.delegate = self
        return tableView
    }()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return isLightTheme ? .default : .lightContent
    }
    
    var delegate: MenuViewControllerDelegate?
    
    var isLightTheme = UserDefaults.standard.bool(forKey: isLightThemeKey)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.topItem?.title = NSLocalizedString("Menu", comment: "")
        
        view.addSubview(tableView)
        tableView.constraintTo(top: view.topAnchor, bottom: view.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, topConstant: 0, bottomConstant: 0, leftConstant: 0, rightConstant: 0)
        
        loadTheme()
    }
    
    func loadTheme() {
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: isLightTheme ? UIColor.black : UIColor.white]
        
        navigationController?.navigationBar.barTintColor = isLightTheme ? .white : .black
        navigationController?.navigationBar.tintColor = isLightTheme ? .greenCoral : .orange
        
        tableView.backgroundColor = isLightTheme ? .white : .black

        setNeedsStatusBarAppearanceUpdate()

        tableView.reloadData()
        
    }
}

extension MenuViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! MenuTableViewCell
        cell.cellModel = menuModels[indexPath.row]
        cell.isLightTheme = isLightTheme
        return cell
    }
}

extension MenuViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 45
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.dismiss(animated: true) {
            let menuSection = self.menuModels[indexPath.row].menuSection
            switch menuSection {
            case .theme:
                self.delegate?.changeTheme()
            case .feedback:
                self.delegate?.presentMailComposeViewController()
            case .rate:
                self.delegate?.presentRatingAction()
            case .share:
                self.delegate?.presentShareAction()
            }
        }
    }
}
