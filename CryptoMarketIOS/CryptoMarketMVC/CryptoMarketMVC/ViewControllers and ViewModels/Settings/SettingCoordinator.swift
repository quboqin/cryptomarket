//
//  SettingCoordinator.swift
//  CryptoMarketMVC
//
//  Created by Qubo on 9/25/18.
//  Copyright © 2018 Qubo. All rights reserved.
//

import UIKit
import RxSwift

enum SettingCoordinationResult {
    case kLineDataSource(DataSource)
    case showCoinOnly(Bool)
    case removeMyFavorites(Bool)
    case cancel
}

class SettingCoordinator: BaseCoordinator<SettingCoordinationResult> {
    private let rootViewController: UIViewController
    private let rootViewModel: PriceViewModel
    
    init(rootViewController: UIViewController, rootViewModel: PriceViewModel) {
        self.rootViewController = rootViewController
        self.rootViewModel = rootViewModel
    }
    
    override func start() -> Observable<SettingCoordinationResult> {
        let viewController = SettingsViewController.initFromStoryboard(name: "Main")
        let navigationController = SettingsNavigationController(rootViewController: viewController)
        navigationController.transitioningDelegate = self.rootViewController as? UIViewControllerTransitioningDelegate
        navigationController.modalPresentationStyle = UIModalPresentationStyle.overFullScreen
        
        let viewModel = SettingViewModel()
        viewController.viewModel = viewModel
        
        viewModel.selectShowCoinOnly.onNext(rootViewModel.showCoinOnly.value)
        viewModel.selectDataSource.onNext(GlobalStatus.shared.klineDataSource.value)
        
        let cancel = viewModel.didCancel.map { _ in CoordinationResult.cancel }
        let dataSource = viewModel.didSelectDataSource.map { CoordinationResult.kLineDataSource($0) }
        let showCoinOnly = viewModel.didSelectShowCoinOnly.map { CoordinationResult.showCoinOnly($0) }
        let removeMyFavorites = viewModel.didRemoveMyFavorites.map { CoordinationResult.removeMyFavorites($0) }

        rootViewController.present(navigationController, animated: true)
        
        return Observable.merge(cancel, dataSource, showCoinOnly, removeMyFavorites)
            .do(onNext: {
                switch $0 {
                case .cancel:
                    viewController.dismiss(animated: true)
                default:
                    return
                }
            })
    }
}
