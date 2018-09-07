//
//  HuobiModel.swift
//  CoinMarketCapCloneOnIOS
//
//  Created by Qubo on 6/24/18.
//  Copyright © 2018 Qubo. All rights reserved.
//

import Foundation

//MARK: KLine
struct KlineItem {
    var id: Int
    var amount: Double?
    var count: Int?
    var open: Double?
    var close: Double?
    var low: Double?
    var high: Double?
    var vol: Double?
}

extension KlineItem: Decodable {
    private enum KlineItemCodingKeys: String, CodingKey {
        case id
        case amount
        case count
        case open
        case close
        case low
        case high
        case vol
    }
    
    init(from decoder: Decoder) throws {
        let KLineItemContainer = try decoder.container(keyedBy: KlineItemCodingKeys.self)
        
        id = try KLineItemContainer.decode(Int.self, forKey: .id)
        amount = try? KLineItemContainer.decode(Double.self, forKey: .amount)
        count = try? KLineItemContainer.decode(Int.self, forKey: .count)
        open = try? KLineItemContainer.decode(Double.self, forKey: .open)
        close = try? KLineItemContainer.decode(Double.self, forKey: .close)
        low = try? KLineItemContainer.decode(Double.self, forKey: .low)
        high = try? KLineItemContainer.decode(Double.self, forKey: .high)
        vol = try? KLineItemContainer.decode(Double.self, forKey: .vol)
    }
}

struct KlineResponse {
    var status: String
    var ch: String
    var ts: Int
    var data: [KlineItem]
}

extension KlineResponse: Decodable {
    private enum KlineResponseCodingKeys: String, CodingKey {
        case status
        case ch
        case ts
        case data
    }
    
    init(from decoder: Decoder) throws {
        let KLineResponseContainer = try decoder.container(keyedBy: KlineResponseCodingKeys.self)
        
        status = try KLineResponseContainer.decode(String.self, forKey: .status)
        ch = try KLineResponseContainer.decode(String.self, forKey: .ch)
        ts = try KLineResponseContainer.decode(Int.self, forKey: .ts)
        data = try KLineResponseContainer.decode([KlineItem].self, forKey: .data)
    }
}

//MARK: MarketDepth
struct Tick {
//    var id: Int
    var ts: Int
    var bids: [[Double]]
    var asks: [[Double]]
}

extension Tick: Decodable {
    private enum TickCodingKeys: String, CodingKey {
//        case id
        case ts
        case bids
        case asks
    }
    
    init(from decoder: Decoder) throws {
        let tickContainer = try decoder.container(keyedBy: TickCodingKeys.self)
        
//        id = try tickContainer.decode(Int.self, forKey: .id)
        ts = try tickContainer.decode(Int.self, forKey: .ts)
        bids = try tickContainer.decode([[Double]].self, forKey: .bids)
        asks = try tickContainer.decode([[Double]].self, forKey: .asks)
    }
}

struct MarketDepthResponse {
    var status: String
    var ch: String
    var ts: Int
    var tick: Tick
}

extension MarketDepthResponse: Decodable {
    private enum MarketDepthResponseCodingKeys: String, CodingKey {
        case status
        case ch
        case ts
        case tick
    }
    
    init(from decoder: Decoder) throws {
        let marketDepthResponseContainer = try decoder.container(keyedBy: MarketDepthResponseCodingKeys.self)
        
        status = try marketDepthResponseContainer.decode(String.self, forKey: .status)
        ch = try marketDepthResponseContainer.decode(String.self, forKey: .ch)
        ts = try marketDepthResponseContainer.decode(Int.self, forKey: .ts)
        tick = try marketDepthResponseContainer.decode(Tick.self, forKey: .tick)
    }
}

//MARK: MarketTickers
struct TickerItem {
    var amount: Double
    var count: Int
    var open: Double
    var close: Double
    var low: Double
    var high: Double
    var vol: Double
    var symbol: String
}

extension TickerItem: Decodable {
    private enum TickerItemCodingKeys: String, CodingKey {
        case amount
        case count
        case open
        case close
        case low
        case high
        case vol
        case symbol
    }
    
    init(from decoder: Decoder) throws {
        let TickerItemContainer = try decoder.container(keyedBy: TickerItemCodingKeys.self)
        
        amount = try TickerItemContainer.decode(Double.self, forKey: .amount)
        count = try TickerItemContainer.decode(Int.self, forKey: .count)
        open = try TickerItemContainer.decode(Double.self, forKey: .open)
        close = try TickerItemContainer.decode(Double.self, forKey: .close)
        low = try TickerItemContainer.decode(Double.self, forKey: .low)
        high = try TickerItemContainer.decode(Double.self, forKey: .high)
        vol = try TickerItemContainer.decode(Double.self, forKey: .vol)
        symbol = try TickerItemContainer.decode(String.self, forKey: .symbol)
    }
}

struct MarketTickersResponse {
    var status: String
//    var ch: String
    var ts: Int
    var data: [TickerItem]
}

extension MarketTickersResponse: Decodable {
    private enum MarketTickersResponseCodingKeys: String, CodingKey {
        case status
//        case ch
        case ts
        case data
    }
    
    init(from decoder: Decoder) throws {
        let marketDepthResponseContainer = try decoder.container(keyedBy: MarketTickersResponseCodingKeys.self)
        
        status = try marketDepthResponseContainer.decode(String.self, forKey: .status)
//        ch = try marketDepthResponseContainer.decode(String.self, forKey: .ch)
        ts = try marketDepthResponseContainer.decode(Int.self, forKey: .ts)
        data = try marketDepthResponseContainer.decode([TickerItem].self, forKey: .data)
    }
}

