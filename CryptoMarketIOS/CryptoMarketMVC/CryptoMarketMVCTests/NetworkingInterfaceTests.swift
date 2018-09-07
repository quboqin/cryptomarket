//
//  HuobiEndPointsTests.swift
//  CryptoMarketMVCTests
//
//  Created by Qubo on 9/9/18.
//  Copyright © 2018 Qubo. All rights reserved.
//

import XCTest
@testable import CryptoMarketMVC

class HuobiEndPointsTests: XCTestCase {
    var huobitNetworkManager: HuobiNetworkManager!
    var cryptoCompareNetworkManager: CryptoCompareNetworkManager!
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        

        huobitNetworkManager = HuobiNetworkManager.shared
        cryptoCompareNetworkManager = CryptoCompareNetworkManager.shared
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        huobitNetworkManager = nil
    }
    
    func testHuobiEndPoints() {
        let expectation = self.expectation(description: "getDataFromEndPoint")
        
        _ = huobitNetworkManager.getDataFromEndPoint(.historyKline(symbol: "btcusdt", period: "5min", size: 150), type: KlineResponse.self) {
            (data, error) in
            if let kLineResponse = data as? KlineResponse {
                Log.i(kLineResponse.data)
                expectation.fulfill()
            }
        }
        
        waitForExpectations(timeout: 20, handler: nil)
    }
    
    func testCryptoCompareEndPoints() {
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
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
