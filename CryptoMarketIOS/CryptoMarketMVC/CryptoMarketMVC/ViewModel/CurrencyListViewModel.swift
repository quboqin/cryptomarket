//
//  CurrencyListViewModel.swift
//  CryptoMarketMVC
//
//  Created by Qubo on 9/21/18.
//  Copyright © 2018 Qubo. All rights reserved.
//

import Foundation
import RxSwift

class CurrencyListViewModel {
    // MARK: - Inputs
    let selectCurrency: AnyObserver<CurrencyViewModel>
    
    // MARK: - Status
    
    // MARK: - Outputs
    let showCurrency: Observable<String>
    
    init() {
        let _selectCurrency = PublishSubject<CurrencyViewModel>()
        self.selectCurrency = _selectCurrency.asObserver()
        self.showCurrency = _selectCurrency.asObservable()
            .map { $0.url }
    }
    
    class func sortedBykey(tickers: [CurrencyViewModel], key: SortOrder) -> [CurrencyViewModel] {
        if case SortOrder.ascend(_, let _key) = key {
            switch _key {
            case .name:
                return tickers.sorted(by: {
                    $0.fullName < $1.fullName
                })
            case .price:
                return tickers.sorted(by: {
                    $0.quotes["USD"]!.price < $1.quotes["USD"]!.price
                })
            case .change:
                return tickers.sorted(by: {
                    $0.quotes["USD"]!.percentChange24h < $1.quotes["USD"]!.percentChange24h
                })
            }
        }
        if case SortOrder.descend(_, let _key) = key {
            switch _key {
            case .name:
                return tickers.sorted(by: {
                    $0.fullName > $1.fullName
                })
            case .price:
                return tickers.sorted(by: {
                    $0.quotes["USD"]!.price > $1.quotes["USD"]!.price
                })
            case .change:
                return tickers.sorted(by: {
                    $0.quotes["USD"]!.percentChange24h > $1.quotes["USD"]!.percentChange24h
                })
            }
        }
        return tickers
    }
}
