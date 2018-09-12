//
//  SettingsViewController.swift
//  CryptoMarketMVC
//
//  Created by Qubo on 8/25/18.
//  Copyright © 2018 Qubo. All rights reserved.
//

import UIKit

protocol SettingsViewControllerDelegate: class {
    func settingsViewController(_ viewController: SettingsViewController, didSelectTokenOnly isOnlyToken: Bool)
    func settingsViewController(_ viewController: SettingsViewController, didSaveMyFavorites isSaveMyFavorites: Bool)
    func settingsViewControllerDidCancel(_ viewController: SettingsViewController)
}

protocol SettingsViewControllerKLineDelegate: class {
    func settingsViewController(_ viewController: SettingsViewController, didSelectDataSource dataSource: DataSource)
}

class SettingsViewController: UITableViewController {
    @objc
    func closeButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    weak var delegate: SettingsViewControllerDelegate!
    weak var kLineDelegate: SettingsViewControllerKLineDelegate?
    
    @IBOutlet weak var dataSourceSegment: UISegmentedControl!
    var dataSource: DataSource!
    
    @IBOutlet weak var showCoinOnlySwitch: UISwitch!
    var showCoinOnly: Bool!

    @IBAction func selectDatasource(_ sender: UISegmentedControl) {
        let selectedSegmentIndex = sender.selectedSegmentIndex
        if selectedSegmentIndex == DataSource.cryptoCompare.hashValue {
            kLineDelegate?.settingsViewController(self, didSelectDataSource: DataSource.cryptoCompare)
        } else {
            kLineDelegate?.settingsViewController(self, didSelectDataSource: DataSource.houbi)
        }
    }
    
    @IBAction func showTokenOnly(_ sender: UISwitch) {
        delegate.settingsViewController(self, didSelectTokenOnly: sender.isOn)
    }
    
    @IBAction func clearMyFavorites(_ sender: UIButton) {
        Log.v("Clean my favorites")
    }
    
    @IBAction func saveMyFavorites(_ sender: UISwitch) {
        delegate.settingsViewController(self, didSaveMyFavorites: sender.isOn)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let closeButton = UIBarButtonItem(title: "Close", style: .plain, target: self, action: #selector(closeButtonPressed(_:)))
        self.navigationItem.leftBarButtonItem = closeButton

        dataSourceSegment.selectedSegmentIndex = dataSource.hashValue
        showCoinOnlySwitch.isOn = showCoinOnly
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
