//
//  SettingViewModel.swift
//  CryptoMarketMVC
//
//  Created by Qubo on 9/22/18.
//  Copyright © 2018 Qubo. All rights reserved.
//

import Foundation
import RxSwift

class SettingViewModel {
    // MARK: - Inputs
    let selectDataSource: AnyObserver<DataSource>
    let selectShowCoinOnly: AnyObserver<Bool>
    let removeMyFavorites: AnyObserver<Bool>
    let cancel: AnyObserver<Void>
    
    // MARK: - Status
    
    // MARK: - Outputs
    let didSelectDataSource : Observable<DataSource>
    let didSelectShowCoinOnly: Observable<Bool>
    let didRemoveMyFavorites: Observable<Bool>
    let didCancel: Observable<Void>
    
    init() {
        let _selectShowCoinOnly = BehaviorSubject<Bool>(value: false)
        self.selectShowCoinOnly = _selectShowCoinOnly.asObserver()
        self.didSelectShowCoinOnly = _selectShowCoinOnly.asObservable()
        
        let _removeMyFavorites = PublishSubject<Bool>()
        self.removeMyFavorites = _removeMyFavorites.asObserver()
        self.didRemoveMyFavorites = _removeMyFavorites.asObservable()
        
        let _cancel = PublishSubject<Void>()
        self.cancel = _cancel.asObserver()
        self.didCancel = _cancel.asObservable()
        
        let _selectDataSource = BehaviorSubject<DataSource>(value: DataSource.cryptoCompare)
        self.selectDataSource = _selectDataSource.asObserver()
        self.didSelectDataSource = _selectDataSource.asObservable()
    }
}
