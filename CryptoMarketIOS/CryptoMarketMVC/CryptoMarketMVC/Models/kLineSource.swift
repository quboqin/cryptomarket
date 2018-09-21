//
//  kLineSource.swift
//  CryptoMarketMVC
//
//  Created by Qubo on 9/11/18.
//  Copyright © 2018 Qubo. All rights reserved.
//

import Foundation
import RxSwift

class KLineSource {
    static let shared = KLineSource()
    
    var dataSource = Variable<DataSource>(DataSource.cryptoCompare)
    
    private init() {
        
    }
}
