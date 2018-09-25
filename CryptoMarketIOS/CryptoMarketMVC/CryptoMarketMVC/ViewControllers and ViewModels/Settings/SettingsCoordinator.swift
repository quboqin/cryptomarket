//
//  SettingsCoordinator.swift
//  CryptoMarketMVC
//
//  Created by Qubo on 9/25/18.
//  Copyright © 2018 Qubo. All rights reserved.
//

import UIKit
import RxSwift

class SettingCoordinator: BaseCoordinator<Void> {
    private let rootViewController: UIViewController
    
    init(rootViewController: UIViewController) {
        self.rootViewController = rootViewController
    }
    
    override func start() -> Observable<Void> {
        let viewController = SettingsViewController.initFromStoryboard(name: "Main")
        let navigationController = UINavigationController(rootViewController: viewController)
        
        let viewModel = SettingViewModel()
        viewController.viewModel = viewModel

        rootViewController.present(navigationController, animated: true)
        
        return Observable.never()
    }
}
