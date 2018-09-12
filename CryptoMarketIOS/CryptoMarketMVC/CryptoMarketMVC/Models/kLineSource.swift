//
//  kLineSource.swift
//  CryptoMarketMVC
//
//  Created by Qubo on 9/11/18.
//  Copyright © 2018 Qubo. All rights reserved.
//

import Foundation

class KLineSource {
    static let shared = KLineSource()
    
    var dataSource = DataSource.cryptoCompare
    
    private init() {
        
    }
}
