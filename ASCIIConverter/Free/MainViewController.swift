//
//  MainViewController.swift
//  ASCIIConverter
//
//  Created by Dai Tran on 11/5/17.
//  Copyright © 2017 DaiTranDev. All rights reserved.
//

import UIKit
import GoogleMobileAds

class MainViewController: UIViewController {

    //@IBOutlet weak var tableView: UITableView!
    
    var tableView: UITableView = {
        let tableView = UITableView()
        tableView.allowsSelection = false
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.showsVerticalScrollIndicator = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    let cellId = "cellId"
    
    var cellModels = [CellModel(labelText: "TEXT", textFieldPlaceHolderText: "TEXT", textFieldText: "" , keyboardType: .asciiCapable, allowingCharacters: "", base: 0, tag: 0),
                      CellModel(labelText: "ASCII", textFieldPlaceHolderText: "ASCII CODE", textFieldText: "", keyboardType: .decimalPad, allowingCharacters: "0123456789 ", base: 10, tag: 1),
                      CellModel(labelText: "BIN", textFieldPlaceHolderText: "BINARY CODE", textFieldText: "", keyboardType: .decimalPad, allowingCharacters: "01 ", base: 2, tag: 2),
                      CellModel(labelText: "OCT", textFieldPlaceHolderText: "OCTAL CODE", textFieldText: "", keyboardType: .decimalPad, allowingCharacters: "01234567 ", base: 8, tag: 3),
                      CellModel(labelText: "HEX", textFieldPlaceHolderText: "HEXADECIMAL CODE", textFieldText: "", keyboardType: .asciiCapable, allowingCharacters: "0123456789aAbBcCdDeEfF ", base: 16, tag: 4)]
    
    let keyboardAppearance = [UIKeyboardAppearance.light, UIKeyboardAppearance.dark]
    
    var isLightTheme: Bool = UserDefaults.standard.bool(forKey: isLightThemeKey)
    
//    let mainBackgroundColors:[UIColor] = [UIColor.white, UIColor.black]
    
    let mainLabelColors: [UIColor] = [UIColor(red:0.14, green:0.84, blue:0.11, alpha:1.0), UIColor.orange]
    
    var showUpgradeAlert: Bool = false
    
//    var textFieldTagIsEditing: Int = 0
    
//    var freeVersion: Bool = false
    
    var bannerView: GADBannerView!
    
    var interstitial: GADInterstitial?
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return isLightTheme ? .default : .lightContent
    }
    
    fileprivate func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        view.addSubview(tableView)
        _ = tableView.constraintTo(top: view.topAnchor, bottom: view.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, topConstant: 0, bottomConstant: 0, leftConstant: 0, rightConstant: 0)
        tableView.register(MainTableViewCell.self, forCellReuseIdentifier: cellId)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        
        bannerView = GADBannerView(adSize: kGADAdSizeBanner)
        
        bannerView.adUnitID = "ca-app-pub-7005013141953077/8210577141"
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
        bannerView.delegate = self
        
        interstitial = createAndLoadInterstitial()
        
        if let value = UserDefaults.standard.object(forKey: isLightThemeKey) as? Bool {
            isLightTheme = value
        } else {
            UserDefaults.standard.set(true, forKey: isLightThemeKey)
        }
        
        loadTheme()
        
        navigationController?.navigationBar.topItem?.title = NSLocalizedString("MainTitle", comment: "")
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "home"), style: .plain, target: self, action: #selector(onHomeAction))
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "refresh"), style: .plain, target: self, action: #selector(onRefreshAction))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presentAlert(title: NSLocalizedString("Appname", comment: ""), message: NSLocalizedString("UpgradeMessage", comment: ""), isUpgradeMessage: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func onRefreshAction() {
        for i in 0..<cellModels.count {
            cellModels[i].textFieldText = ""
            (tableView.visibleCells[i] as? MainTableViewCell)?.cellModel = cellModels[i]
        }
    }
    
    @objc func onHomeAction() {
        let homeViewController = HomeViewController()
        let nav = UINavigationController(rootViewController: homeViewController)
        homeViewController.delegate = self
        present(nav, animated: true)
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
        guard #available(iOS 10, *) else {
            completion(UIApplication.shared.openURL(url))
            return
        }
        UIApplication.shared.open(url, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: completion)
    }
}

extension MainViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! MainTableViewCell
        cell.cellModel = cellModels[indexPath.row]
        cell.isLightTheme = isLightTheme
        cell.delegate = self     
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }
}

extension MainViewController: MainTableViewCellDelegate {
    func presentCopiedAlert(message: String) {
        self.presentAlert(title: message, message: "", isUpgradeMessage: false)
    }
    
    func updateCellModel(tag: Int, textFieldText: String) {
        cellModels[tag].textFieldText = textFieldText
    }
    
    func setAllTextField0(exceptedIndex: Int) {
        for i in 0..<cellModels.count {
            if (i != exceptedIndex) {
                cellModels[i].textFieldText = ""
                (tableView.visibleCells[i] as? MainTableViewCell)?.cellModel = cellModels[i]
            }
        }
    }
    
    func convertToAllBases(exceptedIndex: Int, numbers: [String]) {
        setAllTextField0(exceptedIndex: exceptedIndex)
        // Convert number array to all bases
        for num in numbers {
            if let num = Int(num) {
                for i in 1..<cellModels.count {
                    if (i != exceptedIndex) {
                        cellModels[i].textFieldText += String(num, radix: cellModels[i].base).uppercased() + " "
                        (tableView.visibleCells[i] as? MainTableViewCell)?.cellModel = cellModels[i]
                    }
                }
            }
        }
    }
    
    func convertASCIICodeToText() {
        let numbers: [String] = cellModels[1].textFieldText.components(separatedBy: " ")
        
        for num in numbers {
            if let num = Int(num) {
                if (num > 31 && num < 128) {
                    cellModels[0].textFieldText += String(describing: num.char)
                } else {
                    if (num > 127 && !showUpgradeAlert) {
                        presentAlert(title: NSLocalizedString("Attention", comment: ""), message: NSLocalizedString("AttentionMessage", comment: ""), isUpgradeMessage: false)
                        showUpgradeAlert = true
                    }
                    return
                }
            }
        }
        (tableView.visibleCells[0] as? MainTableViewCell)?.cellModel = cellModels[0]
        showUpgradeAlert = false
    }
    
    func convertTextToASCIICode(from textField: UITextField) -> [String]? {
        var stringNumbers: [String] = []
        cellModels[1].textFieldText = ""
        for char in textField.text! {
            if let asciiValue = char.asciiValue {
                let stringNumber = String(asciiValue)
                stringNumbers.append(stringNumber)
                cellModels[1].textFieldText += stringNumber + " "
            } else {
                setAllTextField0(exceptedIndex: textField.tag)
                return nil
            }
        }
        (tableView.visibleCells[1] as? MainTableViewCell)?.cellModel = cellModels[1]
        return stringNumbers
    }
}

extension MainViewController: HomeViewControllerDelegate {
    func loadThemeAndUpdateFormat() {
        isLightTheme = UserDefaults.standard.bool(forKey: isLightThemeKey)
        loadTheme()
        for i in 0..<tableView.visibleCells.count {
            (tableView.visibleCells[i] as? MainTableViewCell)?.isLightTheme = isLightTheme
        }
    }
    
    func presentUpgradeAlert() {
        presentAlert(title: NSLocalizedString("Appname", comment: ""), message: NSLocalizedString("UpgradeMessage", comment: ""), isUpgradeMessage: true)
    }
    
    func loadTheme() {
        isLightTheme = UserDefaults.standard.bool(forKey: isLightThemeKey)
        
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: isLightTheme ? UIColor.black : UIColor.white]
        
        navigationController?.navigationBar.barTintColor = isLightTheme ? .white : .black
        navigationController?.navigationBar.tintColor = isLightTheme ? .greenCoral : .orange

        view.backgroundColor = isLightTheme ? .white : .black
        
        setNeedsStatusBarAppearanceUpdate()
        
        tableView.reloadData()
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
        interstitial = GADInterstitial(adUnitID: "ca-app-pub-7005013141953077/5926785468")
        
        guard let interstitial = interstitial else {
            return nil
        }
        
        let request = GADRequest()
        // Remove the following line before you upload the app
        request.testDevices = [ kGADSimulatorID ]
        interstitial.load(request)
        interstitial.delegate = self
        
        return interstitial
    }
    
    func interstitialDidReceiveAd(_ ad: GADInterstitial) {
        ad.present(fromRootViewController: self)
    }
}

extension String {
    var asciiArray: [UInt32] {
        return unicodeScalars.filter{$0.isASCII}.map{$0.value}
    }
}
extension Character {
    var asciiValue: UInt32? {
        return String(self).unicodeScalars.filter{$0.isASCII}.first?.value
    }
}

extension Int {
    var char : Character {
        return Character(UnicodeScalar(self)!)
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
