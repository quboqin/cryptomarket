//
//  CoinMarketEndPointsTests.swift
//  CryptoMarketMVCTests
//
//  Created by Qubo on 9/9/18.
//  Copyright © 2018 Qubo. All rights reserved.
//

import XCTest
@testable import CryptoMarketMVC

class CoinMarketEndPointsTests: XCTestCase {
    var coinMarketNetworkManager: CoinMartetNetworkManager!
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        coinMarketNetworkManager = CoinMartetNetworkManager.shared
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        coinMarketNetworkManager = nil
    }
    
    func testListings() {
        let expectation = self.expectation(description: "getDataFromEndPoint")
        
        _ = coinMarketNetworkManager.getDataFromEndPoint(.listings, type: ListingsResponse.self) {
            (data, error) in
            if let listingsResponse = data as? ListingsResponse {
                Log.i(listingsResponse.data)
                expectation.fulfill()
            }
        }
        
        waitForExpectations(timeout: 8, handler: nil)
    }
    
    func testTickets() {
        let expectation = self.expectation(description: "getDataFromEndPoint")
        
        _ = coinMarketNetworkManager.getDataFromEndPoint(.ticker(start: 1, limit: 60, sort: "id", structure: "array", convert: "BTC"), type: TickersResponse.self) {
            (data, error) in
            if let tickersResponse = data as? TickersResponse {
                Log.i(tickersResponse.data)
                expectation.fulfill()
            }
        }
        
        waitForExpectations(timeout: 8, handler: nil)
    }
    
    func testGlobalData() {
        let expectation = self.expectation(description: "getDataFromEndPoint")
        
        _ = coinMarketNetworkManager.getDataFromEndPoint(.globalData(convert: "USD"), type: GlobalResponse.self) {
            (data, error) in
            if let globalResponse = data as? GlobalResponse {
                Log.i(globalResponse.data)
                expectation.fulfill()
            }
        }
        
        waitForExpectations(timeout: 8, handler: nil)
    }
}
