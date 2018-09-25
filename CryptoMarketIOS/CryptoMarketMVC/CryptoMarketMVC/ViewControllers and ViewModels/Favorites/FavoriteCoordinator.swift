//
//  FavoriteCoordinator.swift
//  CryptoMarketMVC
//
//  Created by Qubo on 9/25/18.
//  Copyright © 2018 Qubo. All rights reserved.
//

import UIKit
import RxSwift

class FavoriteCoordinator: BaseCoordinator<Void> {
    private let window: UIWindow
    private let rootViewController: UITabBarController
    
    init(window: UIWindow) {
        self.window = window
        self.rootViewController = window.rootViewController as! UITabBarController
    }
    
    override func start() -> Observable<Void> {
        let viewModel = FavoriteViewModel()
        let navigationViewController = rootViewController.viewControllers![1] as! UINavigationController
        let viewController = navigationViewController.viewControllers[0] as! FavoritesViewController
        
        viewController.viewModel = viewModel
        
        return Observable.never()
    }
}
