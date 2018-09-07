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
    var huobiNetworkManager: HuobiNetworkManager!
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        huobiNetworkManager = HuobiNetworkManager.shared
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        huobiNetworkManager = nil
    }
    
    func testHistoryKline() {
        let expectation = self.expectation(description: "getDataFromEndPoint")
        
        _ = huobiNetworkManager.getDataFromEndPoint(.historyKline(symbol: "btcusdt", period: "5min", size: 150), type: KlineResponse.self) {
            (data, error) in
            if let kLineResponse = data as? KlineResponse {
                Log.i(kLineResponse.data)
                expectation.fulfill()
            }
        }
        
        waitForExpectations(timeout: 8, handler: nil)
    }
    
    func testMarketDepth() {
        let expectation = self.expectation(description: "getDataFromEndPoint")
        
        _ = huobiNetworkManager.getDataFromEndPoint(.marketDepth(symbol: "btcusdt", type: "step1"), type: MarketDepthResponse.self) {
            (data, error) in
            if let marketDepthResponse = data as? MarketDepthResponse {
                Log.i(marketDepthResponse.tick)
                expectation.fulfill()
            }
        }
        
        waitForExpectations(timeout: 8, handler: nil)
    }
    
    func testMarketTickers() {
        let expectation = self.expectation(description: "getDataFromEndPoint")
        
        _ = huobiNetworkManager.getDataFromEndPoint(.marketTickers, type: MarketTickersResponse.self) {
            (data, error) in
            if let marketTickersResponse = data as? MarketTickersResponse {
                Log.i(marketTickersResponse.data)
                expectation.fulfill()
            }
        }
        
        waitForExpectations(timeout: 8, handler: nil)
    }
    
}
