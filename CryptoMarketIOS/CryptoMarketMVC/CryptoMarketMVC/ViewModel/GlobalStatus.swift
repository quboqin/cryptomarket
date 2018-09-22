//
//  kLineSource.swift
//  CryptoMarketMVC
//
//  Created by Qubo on 9/11/18.
//  Copyright © 2018 Qubo. All rights reserved.
//

import Foundation
import RxSwift

class GlobalStatus {
    static let shared = GlobalStatus()
    
    var klineDataSource = Variable<DataSource>(DataSource.cryptoCompare)
    var baseImageUrl = Variable<String>("")
    
    private init() {
        
    }
}
