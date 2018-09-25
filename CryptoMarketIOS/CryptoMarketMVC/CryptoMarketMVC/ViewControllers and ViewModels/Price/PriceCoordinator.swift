//
//  PriceCoordinator.swift
//  CryptoMarketMVC
//
//  Created by Qubo on 9/25/18.
//  Copyright © 2018 Qubo. All rights reserved.
//

import UIKit
import RxSwift

class PriceCoordinator: BaseCoordinator<Void> {
    private let window: UIWindow
    private let rootViewController: UITabBarController
    
    init(window: UIWindow) {
        self.window = window
        self.rootViewController = window.rootViewController as! UITabBarController
    }

    override func start() -> Observable<Void> {
        let navigationViewController = rootViewController.viewControllers![0] as! UINavigationController
        let viewController = navigationViewController.viewControllers[0] as! PricesViewController
        
        let viewModel = PriceViewModel()
        viewController.viewModel = viewModel
        
        let showSettings = viewModel.showSettings.debug()
            .flatMap { [weak self] _ -> Observable<SettingCoordinationResult> in
                guard let `self` = self else { return .empty() }
                return self.showSettings(on: viewController, with: viewModel)
            }
            
        showSettings
            .filter({
                if case .showCoinOnly = $0 {
                    return true
                }
                return false
            })
            .map {
                if case .showCoinOnly(let value) = $0 {
                    return value
                }
                return false
            }
            .bind(to: viewModel.showCoinOnly)
            .disposed(by: disposeBag)
            
        showSettings
            .filter({
                if case .kLineDataSource = $0 {
                    return true
                }
                return false
            })
            .map {
                if case .kLineDataSource(let value) = $0 {
                    return value
                }
                return DataSource.cryptoCompare
            }
            .bind(to: GlobalStatus.shared.klineDataSource)
            .disposed(by: disposeBag)
        
        if let favoriteViewController = viewController.favoritesViewController {
            showSettings
                .filter({
                    if case .removeMyFavorites = $0 {
                        return true
                    }
                    return false
                })
                .map {
                    if case .removeMyFavorites(let value) = $0 {
                        return value
                    }
                    return false
                }
                .bind(to: favoriteViewController.viewModel.deleteFavoriteList)
                .disposed(by: disposeBag)
        }
        
        window.makeKeyAndVisible()
        
        return Observable.never()
    }
    
    private func showSettings(on rootViewController: UIViewController, with rootViewModel: PriceViewModel) -> Observable<SettingCoordinationResult> {
        let settingsCoordinator = SettingCoordinator(rootViewController: rootViewController, rootViewModel: rootViewModel)
        return coordinate(to: settingsCoordinator)
    }
}
