//
//  NetworkingManager+Extension.swift
//  CryptoMarketMVC
//
//  Created by Qubo on 9/13/18.
//  Copyright © 2018 Qubo. All rights reserved.
//

import Foundation
import RxSwift

extension CryptoCompareNetworkManager {
    func getCoinlistRx() -> Observable<CoinListResponse> {
        return Observable<CoinListResponse>.create({ observer in
            let taskKey = self.getDataFromEndPoint(.coinlist, type: CoinListResponse.self) {
                (data, error) in
                if error != nil {
                    observer.onError(error!)
                    return
                }
                
                if let coinListResponse = data as? CoinListResponse {
                    observer.onNext(coinListResponse)
                }
            }
            
            return Disposables.create {
                self.cancelRequestWithUniqueKey(taskKey)
            }
        })
    }
}

extension CoinMarketNetworkManager {
    func getTickerListing() -> Observable<TickersResponse> {
        return Observable<TickersResponse>.create({ observer in
            let taskKey = self.getDataFromEndPoint(.ticker(start: 1, limit: 60, sort: "id", structure: "array", convert: "BTC"), type: TickersResponse.self) {
                (data, error) in
                if error != nil {
                    observer.onError(error!)
                    return
                }
                
                if let tickersResponse = data as? TickersResponse {
                    observer.onNext(tickersResponse)
                }
            }
            
            return Disposables.create {
                self.cancelRequestWithUniqueKey(taskKey)
            }
        })
    }
}
