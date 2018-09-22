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
    let selectRemoveMyFavorites: AnyObserver<Void>
    let cancel: AnyObserver<Void>
    
    // MARK: - Status
    
    // MARK: - Outputs
    let didSelectDataSource : Observable<DataSource>
    let didSelectShowCoinOnly: Observable<Bool>
    let didSelectRemoveMyFavorites: Observable<Void>
    let didCancel: Observable<Void>
    
    
    init() {
        let _selectShowCoinOnly = PublishSubject<Bool>()
        self.selectShowCoinOnly = _selectShowCoinOnly.asObserver()
        self.didSelectShowCoinOnly = _selectShowCoinOnly.asObservable()
        
        let _selectRemoveMyFavorites = PublishSubject<Void>()
        self.selectRemoveMyFavorites = _selectRemoveMyFavorites.asObserver()
        self.didSelectRemoveMyFavorites = _selectRemoveMyFavorites.asObservable()
        
        let _cancel = PublishSubject<Void>()
        self.cancel = _cancel.asObserver()
        self.didCancel = _cancel.asObservable()
        
        let _selectDataSource = PublishSubject<DataSource>()
        self.selectDataSource = _selectDataSource.asObserver()
        self.didSelectDataSource = _selectDataSource.asObservable()
    }
}
