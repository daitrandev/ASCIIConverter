//
//  MainViewController.swift
//  ASCIIConverter
//
//  Created by Dai Tran on 11/5/17.
//  Copyright © 2017 DaiTranDev. All rights reserved.
//

import UIKit
import MessageUI
import GoogleMobileAds

class MainViewController: UIViewController {
    private var tableView: UITableView = {
        let tableView = UITableView()
        tableView.allowsSelection = false
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.showsVerticalScrollIndicator = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private let cellId = "cellId"
                
    private var showUpgradeAlert: Bool = false
    
    private var bannerView: GADBannerView?
    
    private var interstitial: GADInterstitial?
    
    private let isFreeVersion = Bundle.main.infoDictionary?["isFreeVersion"] as? Bool ?? true
    
    private let viewModel: MainViewModelType
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        viewModel = MainViewModel()
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        
        view.addSubview(tableView)
        
        tableView.constraintTo(
            top: view.topAnchor, bottom: view.bottomAnchor,
            left: view.leftAnchor, right: view.rightAnchor
        )
        tableView.register(MainTableViewCell.self, forCellReuseIdentifier: cellId)
    }
    
    private func setupAdsViews() {
        if isFreeVersion {
            bannerView = GADBannerView(adSize: kGADAdSizeBanner)
            let adUnitId = isDebug ? bannerAdsUnitIDTrial : bannerAdsUnitID
            bannerView?.adUnitID = adUnitId
            bannerView?.rootViewController = self
            bannerView?.load(GADRequest())
            bannerView?.delegate = self
            
            interstitial = createAndLoadInterstitial()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        setupAdsViews()
        
        loadTheme()
        
        navigationController?.navigationBar.topItem?.title =
            "MainTitle".localized
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(named: "refresh"),
            style: .plain,
            target: self,
            action: #selector(onRefreshAction)
        )
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(named: "unlock"),
            style: .plain,
            target: self,
            action: #selector(didTapUnlock)
        )
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if isFreeVersion {
            showMessageDialog(
                title: "Appname".localized,
                message: "UpgradeMessage".localized,
                positiveActionName: "Upgrade",
                positiveAction: nil,
                negativeActionName: "Cancel",
                negativeAction: nil
            )
        }
    }
    
    @objc func onRefreshAction() {
        for index in 0..<viewModel.cellLayoutItems.count {
            viewModel.cellLayoutItems[index].content = ""
        }
        reloadTableView()
    }
    
    func loadTheme() {
        if #available(iOS 13, *) {
            view.backgroundColor = .systemBackground
            navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.label]
            navigationController?.navigationBar.barTintColor = .systemBackground
            navigationController?.navigationBar.tintColor =
                traitCollection.userInterfaceStyle.themeColor
        } else {
            view.backgroundColor = .white
            navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.black]
            navigationController?.navigationBar.barTintColor = .white
            navigationController?.navigationBar.tintColor = .greenCoral
        }
        
        setNeedsStatusBarAppearanceUpdate()
        tableView.reloadData()
    }
    
    @objc private func didTapUnlock() {
        let vc = PurchasingPopupViewController()
        present(vc, animated: true)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        loadTheme()
    }
}

extension MainViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.cellLayoutItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! MainTableViewCell
        cell.configure(with: viewModel.cellLayoutItems[indexPath.row])
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }
}

extension MainViewController: MainViewModelDelegate {
    func reloadTableView() {
        guard let visibleCells = tableView.visibleCells as? [MainTableViewCell] else { return }
        
        for cell in visibleCells {
            guard let indexPath = tableView.indexPath(for: cell) else {
                return
            }
            let item = viewModel.cellLayoutItems[indexPath.row]
            cell.configure(with: item)
        }
    }
}

extension MainViewController: MainTableViewCellDelegate {
    func presentCopiedAlert(message: String) {
        showMessageDialog(title: "Success", message: message, actionName: "Done", action: nil)
    }
    
    func updateCellModel(tag: Int, textFieldText: String) {
        viewModel.cellLayoutItems[tag].content = textFieldText
    }
    
    func setAllBaseToEmpty(exceptedIndex: Int) {
        for index in 0..<viewModel.cellLayoutItems.count {
            if (index != exceptedIndex) {
                viewModel.cellLayoutItems[index].content = ""
            }
        }
    }
    
    func convertToAllBases(exceptedIndex: Int, numbers: [String]) {
        setAllBaseToEmpty(exceptedIndex: exceptedIndex)
        // Convert number array to all bases
        for num in numbers {
            if let num = Int(num) {
                for i in 1..<viewModel.cellLayoutItems.count {
                    if (i != exceptedIndex) {
                        let convertedNumberStr = String(num, radix: viewModel.cellLayoutItems[i].base.rawValue)
                        viewModel.cellLayoutItems[i].content += convertedNumberStr.uppercased() + " "
                    }
                }
            }
        }
        reloadTableView()
    }
    
    func convertASCIICodeToText() {
        let numbers: [String] = viewModel.cellLayoutItems[1].content.components(separatedBy: " ")
        
        for num in numbers {
            if let num = Int(num) {
                if (num > 31 && num < 128) {
                    viewModel.cellLayoutItems[0].content += String(describing: num.char)
                } else {
                    if (num > 127 && !showUpgradeAlert) {
                        showMessageDialog(
                            title: "Attention".localized,
                            message: "AttentionMessage".localized,
                            actionName: "Cancel",
                            action: nil
                        )
                        showUpgradeAlert = true
                    }
                    return
                }
            }
        }
        reloadTableView()
        showUpgradeAlert = false
    }
    
    func convertTextToASCIICode(from textField: UITextField) -> [String]? {
        var stringNumbers: [String] = []
        viewModel.cellLayoutItems[1].content = ""
        for char in textField.text! {
            if let asciiValue = char.asciiValue {
                let stringNumber = String(asciiValue)
                stringNumbers.append(stringNumber)
                viewModel.cellLayoutItems[1].content += stringNumber + " "
            } else {
                setAllBaseToEmpty(exceptedIndex: textField.tag)
                return nil
            }
        }
        reloadTableView()
        return stringNumbers
    }
}

extension MainViewController : GADBannerViewDelegate {
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        print("Banner loaded successfully")
        
        // Reposition the banner ad to create a slide down effect
        let translateTransform = CGAffineTransform(translationX: 0, y: -bannerView.bounds.size.height)
        bannerView.transform = translateTransform
        
        UIView.animate(withDuration: 0.5) {
            self.tableView.tableHeaderView?.frame = bannerView.frame
            bannerView.transform = CGAffineTransform.identity
            self.tableView.tableHeaderView = bannerView
        }
    }
    
    func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
        print("Fail to receive ads")
        print(error)
    }
}

extension MainViewController : GADInterstitialDelegate {
    private func createAndLoadInterstitial() -> GADInterstitial? {
        let adUnitId: String = isDebug ? interstialAdsUnitIDTrial : interstialAdsUnitID
        interstitial = GADInterstitial(adUnitID: adUnitId)
        
        guard let interstitial = interstitial else {
            return nil
        }
        
        let request = GADRequest()
        // Remove the following line before you upload the app
        interstitial.load(request)
        interstitial.delegate = self
        
        return interstitial
    }
    
    func interstitialDidReceiveAd(_ ad: GADInterstitial) {
        ad.present(fromRootViewController: self)
    }
}
