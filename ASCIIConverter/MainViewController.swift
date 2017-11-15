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

    @IBOutlet weak var tableView: UITableView!
    
    var textFieldArray: [UITextField?] = [UITextField?](repeating: nil, count: 5)
    
    let labelArray = ["TEXT", "ASCII", "BIN", "OCT", "HEX"]
    
    let allowingCharacters:[String] = ["", "0123456789 ", "01 ", "01234567 ", "0123456789aAbBcCdDeEfF "]
    
    let placeHolderArray = ["TEXT", "ASCII CODE", "BINARY CODE", "OCTAL CODE", "HEXADECIMAL CODE"]
    
    let keyboardAppearance = [UIKeyboardAppearance.light, UIKeyboardAppearance.dark]
    
    let baseArray:[Int] = [0, 10, 2, 8, 16]
    
    var currentThemeIndex: Int = 0
    
    let mainBackgroundColors:[UIColor] = [UIColor.white, UIColor.black]
    
    let mainLabelColors: [UIColor] = [UIColor(red:0.14, green:0.84, blue:0.11, alpha:1.0), UIColor.orange]
    
    var showUpgradeAlert: Bool = false
    
    var textFieldTagIsEditing: Int = 0
    
    var freeVersion: Bool = false
    
    var bannerView: GADBannerView!
    
    var interstitial: GADInterstitial?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.dataSource = self
        tableView.delegate = self
        
        if (freeVersion) {
            bannerView = GADBannerView(adSize: kGADAdSizeBanner)
            
            bannerView.adUnitID = "ca-app-pub-7005013141953077/8210577141"
            bannerView.rootViewController = self
            bannerView.load(GADRequest())
            bannerView.delegate = self
            
            interstitial = createAndLoadInterstitial()
        }
        
        if let value = UserDefaults.standard.object(forKey: "ThemeIndex") as? Int {
            currentThemeIndex = value
        } else {
            UserDefaults.standard.set(0, forKey: "ThemeIndex")
        }
        
        loadColor()
        
        navigationController?.navigationBar.topItem?.title = NSLocalizedString("MainTitle", comment: "")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func OnRefreshAction(_ sender: Any) {
        for i in 0..<textFieldArray.count {
            textFieldArray[i]?.text = ""
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let nav = segue.destination as? UINavigationController, let homeVC = nav.topViewController as? HomeViewController {
            homeVC.delegate = self
        }
    }
}

extension MainViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return labelArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! MainTableViewCell
        cell.backgroundColor = mainBackgroundColors[currentThemeIndex]
        
        cell.label?.backgroundColor = mainLabelColors[currentThemeIndex]
        cell.label?.text = labelArray[indexPath.row]
        cell.label?.makeRound()
        
        cell.textField?.tag            = indexPath.row
        cell.textField?.delegate       = self
        cell.textField?.placeholder    = placeHolderArray[indexPath.row]
        textFieldArray[indexPath.row]  = cell.textField
        cell.textField?.keyboardAppearance = keyboardAppearance[currentThemeIndex]
        
        cell.textField?.makeRound(borderColor: mainLabelColors[currentThemeIndex])
        cell.textField?.addTarget(self, action: #selector(self.textFieldEditingChanged(_:)), for: .editingChanged)
        
        return cell
    }
}

extension MainViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if (string == "" || textField.tag == 0) {
            return true
        }
        
        if (string == " " && textField.text?.last == " ") {
            return false
        }
        
        for char in string {
            if (!allowingCharacters[textField.tag].contains(char)) {
                return false
            }
        }
        
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        textFieldTagIsEditing = textField.tag
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func SetAllTextField0(exceptedIndex: Int) {
        for i in 0..<textFieldArray.count {
            if (i != exceptedIndex) {
                textFieldArray[i]?.text = ""
            }
        }
    }
    
    @objc func textFieldEditingChanged(_ sender: UITextField) {
        
        var numbers:[String] = []
        
        SetAllTextField0(exceptedIndex: sender.tag)

        // Convert sender.text to number array
        if (sender.tag == 0) {
            for char in sender.text! {
                if let asciiValue = char.asciiValue {
                    numbers.append(String(asciiValue))
                } else {
                    SetAllTextField0(exceptedIndex: sender.tag)
                    return
                }
            }
        } else {
            numbers = sender.text!.components(separatedBy: " ")
            
            if (sender.tag != 1) {
                for i in 0..<numbers.count {
                    let num = numbers[i].uppercased()
                    if let base10 = Int(num, radix: baseArray[sender.tag]) {
                        numbers[i] = String(base10)
                    }
                }
            }
        }
        
        // Convert number array to all bases
        for num in numbers {
            if let num = Int(num) {
                for i in 1..<textFieldArray.count {
                    if (i != sender.tag) {
                        textFieldArray[i]!.text! += String(num, radix: baseArray[i]) + " "
                    }
                }
            } else {
                continue
            }
        }
        
        textFieldArray[4]?.text = textFieldArray[4]?.text?.uppercased()
        
        // Convert base10 to TEXT
        if (sender.tag != 0) {
            numbers = textFieldArray[1]!.text!.components(separatedBy: " ")
            
            for num in numbers {
                if let num = Int(num) {
                    if (num > 31 && num < 128) {
                        textFieldArray[0]!.text! += String(describing: num.char)
                    } else {
                        if (num > 127 && !showUpgradeAlert) {
                            presentAlert(titile: NSLocalizedString("Attention", comment: ""), message: NSLocalizedString("AttentionMessage", comment: ""), isUpgradeMessage: false)
                            showUpgradeAlert = true
                        }
                        return
                    }
                } else {
                    continue
                }
            }
            showUpgradeAlert = false
        }
    }
    
    func presentAlert(titile: String, message: String, isUpgradeMessage: Bool) {
        let alert = UIAlertController(title: titile, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Done", comment: ""), style: .cancel, handler: nil))
        if (isUpgradeMessage) {
            alert.addAction(UIAlertAction(title: NSLocalizedString("Upgrade", comment: ""), style: .default, handler: { (action) in
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
        UIApplication.shared.open(url, options: [:], completionHandler: completion)
    }
}

extension MainViewController: HomeViewControllerDelegate {
    func loadColor() {
        currentThemeIndex = UserDefaults.standard.integer(forKey: "ThemeIndex")
        
        self.tableView.backgroundColor = mainBackgroundColors[currentThemeIndex]
        
        navigationController?.navigationBar.barTintColor = mainBackgroundColors[currentThemeIndex]
        
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: mainBackgroundColors[1 - currentThemeIndex]]
        
        navigationController?.navigationBar.tintColor = mainLabelColors[currentThemeIndex]

        view.backgroundColor = mainBackgroundColors[currentThemeIndex]
        
        if (currentThemeIndex == 0) {
            UIApplication.shared.statusBarStyle = .default
        } else {
            UIApplication.shared.statusBarStyle = .lightContent
        }
        
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
    
    func interstitial(_ ad: GADInterstitial, didFailToReceiveAdWithError error: GADRequestError) {
        presentAlert(titile: NSLocalizedString("Appname", comment: ""), message: NSLocalizedString("UpgradeMessage", comment: ""), isUpgradeMessage: true)
    }
    
    func interstitialDidFail(toPresentScreen ad: GADInterstitial) {
        presentAlert(titile: NSLocalizedString("Appname", comment: ""), message: NSLocalizedString("UpgradeMessage", comment: ""), isUpgradeMessage: true)
    }
    
    func interstitialDidReceiveAd(_ ad: GADInterstitial) {
        ad.present(fromRootViewController: self)
    }
    
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        presentAlert(titile: NSLocalizedString("Appname", comment: ""), message: NSLocalizedString("UpgradeMessage", comment: ""), isUpgradeMessage: true)
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
