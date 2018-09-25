//
//  AppCoordinator.swift
//  CryptoMarketMVC
//
//  Created by Qubo on 9/25/18.
//  Copyright © 2018 Qubo. All rights reserved.
//

import UIKit
import RxSwift

class AppCoordinator: BaseCoordinator<Void> {
    private let window: UIWindow
    
    init(window: UIWindow) {
        self.window = window
    }
    
    override func start() -> Observable<Void> {
        let rootViewController = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController() as! UITabBarController
        window.rootViewController = rootViewController
        
        let favoriteCoordinator = FavoriteCoordinator(window: window)
        let _ = coordinate(to: favoriteCoordinator)
        
        let priceCoordinator = PriceCoordinator(window: window)
        return coordinate(to: priceCoordinator)
    }
}
