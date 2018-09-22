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
    
    // MARK: - Status
    
    // MARK: - Outputs
    
    class func sortedBykey(tickers: [Ticker], key: SortOrder) -> [Ticker] {
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
