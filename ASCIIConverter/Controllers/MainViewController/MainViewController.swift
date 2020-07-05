//
//  MainViewController.swift
//  ASCIIConverter
//
//  Created by Dai Tran on 11/5/17.
//  Copyright © 2017 DaiTranDev. All rights reserved.
//

import UIKit
import SideMenu
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
        
    private let keyboardAppearance = [UIKeyboardAppearance.light, UIKeyboardAppearance.dark]
            
    private let mainLabelColors: [UIColor] = [UIColor(red:0.14, green:0.84, blue:0.11, alpha:1.0), UIColor.orange]
    
    private var showUpgradeAlert: Bool = false
    
    private var bannerView: GADBannerView!
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        
        if isFreeVersion {
            bannerView = GADBannerView(adSize: kGADAdSizeBanner)
            let adUnitId = isDebug ? bannerAdsUnitIDTrial : bannerAdsUnitID
            bannerView.adUnitID = adUnitId
            bannerView.rootViewController = self
            bannerView.load(GADRequest())
            bannerView.delegate = self
            
            interstitial = createAndLoadInterstitial()
        }
        
        loadTheme()
        
        navigationController?.navigationBar.topItem?.title = NSLocalizedString("MainTitle", comment: "")
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "home"), style: .plain, target: self, action: #selector(onHomeAction))
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "refresh"), style: .plain, target: self, action: #selector(onRefreshAction))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if isFreeVersion {
            presentAlert(title: NSLocalizedString("Appname", comment: ""), message: NSLocalizedString("UpgradeMessage", comment: ""), isUpgradeMessage: true)
        }
    }
    
    @objc func onRefreshAction() {
        for i in 0..<viewModel.cellLayoutItems.count {
            viewModel.cellLayoutItems[i].content = ""
        }
        tableView.reloadData()
    }
    
    @objc func onHomeAction() {
        let menuViewController = MenuViewController()
        menuViewController.delegate = self
        let menuLeftNavigationController = UISideMenuNavigationController(rootViewController: menuViewController)
        
        SideMenuManager.default.menuLeftNavigationController?.navigationBar.backgroundColor = .green
        SideMenuManager.default.menuAddScreenEdgePanGesturesToPresent(toView: self.navigationController!.view)
        SideMenuManager.default.menuFadeStatusBar = false
        SideMenuManager.default.menuLeftNavigationController = menuLeftNavigationController
        present(SideMenuManager.default.menuLeftNavigationController!, animated: true, completion: nil)
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
    
    func presentAlert(title: String, message: String, isUpgradeMessage: Bool) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Done", comment: ""), style: .cancel, handler: {(action) in
            self.setNeedsStatusBarAppearanceUpdate()
        }))
        if (isUpgradeMessage) {
            alert.addAction(UIAlertAction(title: NSLocalizedString("Upgrade", comment: ""), style: .default, handler: { (action) in
                self.setNeedsStatusBarAppearanceUpdate()
                self.rateApp(appId: "id1308862883") { success in
                    print("RateApp \(success)")
                }
            }))
        }
        
        present(alert, animated: true, completion: nil)
    }
    
    func rateApp(appId: String, completion: @escaping ((_ success: Bool)->())) {
        guard let url = URL(string : "itms-apps://itunes.apple.com/app/" + appId) else {
            completion(false)
            return
        }
        
        URLHandler.open(url: url)
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
        self.presentAlert(title: message, message: "", isUpgradeMessage: false)
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
        reloadTableView()
    }
    
    func convertToAllBases(exceptedIndex: Int, numbers: [String]) {
        setAllBaseToEmpty(exceptedIndex: exceptedIndex)
        // Convert number array to all bases
        for num in numbers {
            if let num = Int(num) {
                for i in 1..<viewModel.cellLayoutItems.count {
                    if (i != exceptedIndex) {
                        viewModel.cellLayoutItems[i].content += String(num, radix: viewModel.cellLayoutItems[i].base).uppercased() + " "
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
                        presentAlert(title: NSLocalizedString("Attention", comment: ""), message: NSLocalizedString("AttentionMessage", comment: ""), isUpgradeMessage: false)
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

extension MainViewController: MenuViewControllerDelegate {
    func presentMailComposeViewController() {
        let mailComposeViewController = configuredMailComposeViewController()
        if MFMailComposeViewController.canSendMail() {
            self.present(mailComposeViewController, animated: true, completion: nil)
        }
    }
    
    func presentRatingAction() {
        let appId = isFreeVersion ? "id1286627577" : "id1308862883"
        rateApp(appId: appId) { success in
            print("RateApp \(success)")
        }
    }
    
    func presentShareAction() {
        let appId = isFreeVersion ? "id1286627577" : "id1308862883"
        let message: String = "https://itunes.apple.com/app/\(appId)"
        let vc = UIActivityViewController(activityItems: [message], applicationActivities: [])
        vc.popoverPresentationController?.sourceView = self.view
        present(vc, animated: true)
    }
}

extension MainViewController:  MFMailComposeViewControllerDelegate {
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self
        
        mailComposerVC.setToRecipients(["universappteam@gmail.com"])
        mailComposerVC.setSubject("[ASCII-Converter++ Feedback]")
        
        return mailComposerVC
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
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
