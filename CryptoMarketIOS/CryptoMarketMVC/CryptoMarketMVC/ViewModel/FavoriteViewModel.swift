//
//  FavoriteViewModel.swift
//  CryptoMarketMVC
//
//  Created by Qubo on 9/22/18.
//  Copyright © 2018 Qubo. All rights reserved.
//

import Foundation
import RxSwift
import RxDataSources

class FavoriteViewModel: CurrencyListViewModel {
    // MARK: - Inputs
    let setSortOrder: AnyObserver<SortOrder>
    let addTicker: AnyObserver<Ticker>
    let removeTicker: AnyObserver<IndexPath>
    let deleteFavoriteList: AnyObserver<Void>
    
    // MARK: - Status
    let tickers = Variable<[Ticker]>([])
    
    // MARK: - Outputs
    let newTicker = PublishSubject<Ticker>()
    let removeIndex = PublishSubject<IndexPath>()
    let sections: Observable<[SectionModel<String, Ticker>]>
    let deleteFavoriteListAndFile: Observable<Void>
    
    override init() {
        self.addTicker = newTicker.asObserver()
        self.removeTicker = removeIndex.asObserver()
        
        let _currentSortOrder = BehaviorSubject<SortOrder>(value: SortOrder.none)
        self.setSortOrder = _currentSortOrder.asObserver()
        
        sections = Observable.combineLatest(tickers.asObservable(), _currentSortOrder) {
            (tickers_, sort) -> [Ticker] in
            return CurrencyListViewModel.sortedBykey(tickers: tickers_, key: sort)
        }
        .map {
            return [SectionModel(model: "Name", items: $0)]
        }
        
        let _deleteFavoriteList = PublishSubject<Void>()
        self.deleteFavoriteList = _deleteFavoriteList.asObserver()
        self.deleteFavoriteListAndFile = _deleteFavoriteList.asObservable()
    }
}
