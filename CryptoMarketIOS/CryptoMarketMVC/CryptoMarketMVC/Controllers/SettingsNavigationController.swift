//
//  SettingsNavigationController.swift
//  CryptoMarketMVC
//
//  Created by Qubo on 8/27/18.
//  Copyright © 2018 Qubo. All rights reserved.
//

import UIKit

class SettingsNavigationController: UINavigationController {
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // On iOS 11 add rounded corners
        if #available(iOS 11, *) {
            view.clipsToBounds = true
            view.layer.cornerRadius = 16.0
            view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]

            view.layer.shadowOffset = .zero
            view.layer.shadowColor = UIColor.black.cgColor
            view.layer.shadowRadius = 16.0
            view.layer.shadowOpacity = 0.5
        }
    }
}
