//
//  CryptoCompareEndPointsTests.swift
//  CryptoMarketMVCTests
//
//  Created by Qubo on 9/9/18.
//  Copyright © 2018 Qubo. All rights reserved.
//

import XCTest
@testable import CryptoMarketMVC

class CryptoCompareEndPointsTests: XCTestCase {
    var cryptoCompareNetworkManager: CryptoCompareNetworkManager!
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        cryptoCompareNetworkManager = CryptoCompareNetworkManager.shared
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        cryptoCompareNetworkManager = nil
    }
    
    func testCoinList() {
        let expectation = self.expectation(description: "getDataFromEndPoint")
        
        _ = cryptoCompareNetworkManager.getDataFromEndPoint(.coinlist, type: CoinListResponse.self) {
            (data, error) in
            if let coinListResponse = data as? CoinListResponse {
                Log.i(coinListResponse)
                expectation.fulfill()
            }
        }
        
        waitForExpectations(timeout: 20, handler: nil)
    }
    
    func testHistoHours() {
        let expectation = self.expectation(description: "getDataFromEndPoint")
        
        _ = cryptoCompareNetworkManager.getDataFromEndPoint(.histohour(fsym: "BTC", tsym: "USD", limit: 11), type: HistoHourResponse.self) {
            (data, error) in
            if let histoHourResponse = data as? HistoHourResponse {
                Log.i(histoHourResponse)
                expectation.fulfill()
            }
        }
        
        waitForExpectations(timeout: 8, handler: nil)
    }
}
