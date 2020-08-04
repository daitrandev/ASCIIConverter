//
//  HUDPresentable.swift
//  ASCIIConverter
//
//  Created by DaiTran on 8/4/20.
//  Copyright © 2020 DaiTranDev. All rights reserved.
//

import UIKit
import MBProgressHUD

protocol HUDPresentable {
    func showLoading()
    func hideLoading()
}

public enum HUD {
    private static var hud: MBProgressHUD?
    
    public static func show() {
        DispatchQueue.main.async {
            hud?.hide(animated: false)
            
            let window = UIApplication.shared.delegate!.window!
            hud = MBProgressHUD.showAdded(to: window!, animated: true)
        }
    }
    
    public static func hide() {
        DispatchQueue.main.async {
            hud?.hide(animated: true)
        }
    }
}

extension HUDPresentable where Self: UIViewController {
    func showLoading() {
        HUD.show()
    }
    
    func hideLoading() {
        HUD.hide()
    }
}
