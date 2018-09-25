//
//  PriceViewModel.swift
//  CryptoMarketMVC
//
//  Created by Qubo on 9/21/18.
//  Copyright © 2018 Qubo. All rights reserved.
//

import Foundation
import RxSwift
import RxDataSources

class PriceViewModel: CryptoCurrencyListViewModel {
    // MARK: - Inputs
    let reload: AnyObserver<Void>
    let setSearchKeyword: AnyObserver<String>
    let setCoinSortOrder: AnyObserver<SortOrder>
    let setTokenSortOrder: AnyObserver<SortOrder>
    let clickSettings: AnyObserver<Void>
    
    // MARK: - Status
    let showCoinOnly: Variable<Bool>
    
    // MARK: - Outputs
    let totalVolume24H: Observable<String>
    let baseImageUrl: Observable<String>
    let sections: Observable<[SectionModel<String, CurrencyViewModel>]>
    let showSettings: Observable<Void>
    
    override init() {
        let _reload = PublishSubject<Void>()
        self.reload = _reload.asObserver()
        
        totalVolume24H = _reload
            .flatMap { () -> Observable<GlobalResponse> in
                return CoinMarketNetworkManager.shared.getDataFromEndPointRx(.globalData(convert: "USD"), type: GlobalResponse.self)
            }
            .map { (globalResponse) -> GlobalViewModel in
                return GlobalViewModel(totalMarketCap: globalResponse.data.quotes["USD"]?.totalMarketCap ?? 0, totalVolume24H: globalResponse.data.quotes["USD"]?.totalVolume24H ?? 0)
            }
            .map { (data) -> String in
                return "$" + String(format: "%.1f", data.totalMarketCap)
            }

        let cryptoCompareNetwork = _reload
            .flatMap { () -> Observable<CoinListResponse> in
                return CryptoCompareNetworkManager.shared.getDataFromEndPointRx(.coinlist, type: CoinListResponse.self)
            }
        
        baseImageUrl = cryptoCompareNetwork
            .map({ (coinListResponse) -> String in
                return coinListResponse.baseImageUrl
            })
        
        let cryptoCompareCoins = cryptoCompareNetwork
            .map { (coinListResponse) -> [String : Coin] in
                return coinListResponse.data
            }
            .map {
                return [Coin]($0.values)
            }
        
        let coinMarketTickers = _reload
            .flatMap { () -> Observable<TickersResponse> in
                return CoinMarketNetworkManager.shared.getDataFromEndPointRx(.ticker(start: 1, limit: 60, sort: "id", structure: "array", convert: "BTC"), type: TickersResponse.self)
            }
            .map { (tickersResponse) -> [Ticker] in
                return tickersResponse.data
            }
        
        let mergedTickers = Observable.combineLatest(coinMarketTickers.asObservable(), cryptoCompareCoins.asObservable()) { tickers, coins in
            return tickers.map({ (ticker) -> Ticker in
                var _ticker = ticker
                if let coin = coins.first(where: {$0.symbol == ticker.symbol}) {
                    _ticker.fullName = coin.fullName
                    _ticker.imageUrl = coin.imageUrl
                    _ticker.url = coin.url
                    if coin.builtOn != "N/A" {
                        _ticker.isToken = true
                    } else {
                        _ticker.isToken = false
                    }
                } else {
                    _ticker.fullName = ticker.symbol
                }
                return _ticker
            })
        }
        
        let _currentSearchKeyword = BehaviorSubject<String>(value: "")
        self.setSearchKeyword = _currentSearchKeyword.asObserver()
        
        let filterTickers = Observable.combineLatest(mergedTickers.asObservable(), _currentSearchKeyword) {
            (tickers, search) -> [Ticker] in
            let lowcasedSearch = search.lowercased()
            return tickers.filter {
                if lowcasedSearch == "" {
                    return true
                }
                return $0.fullName.lowercased().range(of: lowcasedSearch) != nil
            }
        }
        
        let coins = filterTickers.map { (tickers) -> [Ticker] in
            return tickers.filter({ (ticker) -> Bool in
                return !ticker.isToken
            })
        }
        .map {
            $0.map({ (ticker) -> CurrencyViewModel in
                return CurrencyViewModel(currency: ticker)
            })
        }
        
        let _currentCoinSortOrder = BehaviorSubject<SortOrder>(value: SortOrder.none)
        self.setCoinSortOrder = _currentCoinSortOrder.asObserver()
        
        let sortedCoins = Observable.combineLatest(coins.asObservable(), _currentCoinSortOrder) {
            (tickers, sort) -> [CurrencyViewModel] in
            return CryptoCurrencyListViewModel.sortedBykey(tickers: tickers, key: sort)
        }
        
        let tokens = filterTickers.map { (tickers_) -> [Ticker] in
            return tickers_.filter({ (ticker) -> Bool in
                return ticker.isToken
            })
        }
        
        showCoinOnly = Variable<Bool>(false)
        
        let _tokens = Observable.combineLatest(tokens.asObservable(), showCoinOnly.asObservable()) {
            (tickers_, showCoinOnly) -> [Ticker] in
            return tickers_.filter({ (ticker) -> Bool in
                return !showCoinOnly && ticker.isToken
            })
        }
        .map {
            $0.map({ (ticker) -> CurrencyViewModel in
                return CurrencyViewModel(currency: ticker)
            })
        }
        
        let _currentTokenSortOrder = BehaviorSubject<SortOrder>(value: SortOrder.none)
        self.setTokenSortOrder = _currentTokenSortOrder.asObserver()
        
        let sortedTokens = Observable.combineLatest(_tokens.asObservable(), _currentTokenSortOrder) {
            (tickers_, sort) -> [CurrencyViewModel] in
            return CryptoCurrencyListViewModel.sortedBykey(tickers: tickers_, key: sort)
        }
        
        sections = Observable.combineLatest(sortedCoins, sortedTokens) {
            return ($0, $1)
        }
        .map {
            var sections = [SectionModel<String, CurrencyViewModel>]()
            if $0.count != 0 {
                sections.append(SectionModel(model: "Coin", items: $0))
            }
            if $1.count != 0 {
                sections.append(SectionModel(model: "Token", items: $1))
            }
            
            return sections
        }
        
        let _clickSettings = PublishSubject<Void>()
        self.clickSettings = _clickSettings.asObserver()
        self.showSettings = _clickSettings.asObservable()
        
        super.init()
    }
}
