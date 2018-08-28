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
    func settingsViewController(_ viewController: SettingsViewController, didSelectDataSource dataSource: DataSource)
    func settingsViewControllerDidCancel(_ viewController: SettingsViewController)
}

class SettingsViewController: UITableViewController {
    @objc
    func closeButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    weak var delegate: SettingsViewControllerDelegate!

    @IBAction func selectDatasource(_ sender: UISegmentedControl) {
        let selectedSegmentIndex = sender.selectedSegmentIndex
        if selectedSegmentIndex == DataSource.cryptoCompare.hashValue {
            delegate.settingsViewController(self, didSelectDataSource: DataSource.cryptoCompare)
        } else {
            delegate.settingsViewController(self, didSelectDataSource: DataSource.houbi)
        }
    }
    
    @IBAction func showTokenOnly(_ sender: UISwitch) {
        delegate.settingsViewController(self, didSelectTokenOnly: sender.isOn)
    }
    
    @IBAction func clearMyFavorites(_ sender: UIButton) {
        print("Clean my favorites @Settings")
    }
    
    @IBAction func saveMyFavorites(_ sender: UISwitch) {
        delegate.settingsViewController(self, didSaveMyFavorites: sender.isOn)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let closeButton = UIBarButtonItem(title: "Close", style: .plain, target: self, action: #selector(closeButtonPressed(_:)))
        self.navigationItem.leftBarButtonItem = closeButton

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
