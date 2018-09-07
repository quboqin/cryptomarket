//
//  CoinMarketModel.swift
//  CoinMarketCapCloneOnIOS
//
//  Created by Qubo on 6/23/18.
//  Copyright © 2018 Qubo. All rights reserved.
//

import Foundation

//MARK: Listings
struct Item {
    let id: UInt
    let name: String
    let symbol: String
    let websiteSlug: String
}

extension Item: Decodable {
    private enum ItemCodingKeys: String, CodingKey {
        case id
        case name
        case symbol
        case websiteSlug = "website_slug"
    }
    
    init(from decoder: Decoder) throws {
        let itemContainer = try decoder.container(keyedBy: ItemCodingKeys.self)
        
        id = try itemContainer.decode(UInt.self, forKey: .id)
        name = try itemContainer.decode(String.self, forKey: .name)
        symbol = try itemContainer.decode(String.self, forKey: .symbol)
        websiteSlug = try itemContainer.decode(String.self, forKey: .websiteSlug)
    }
}

struct ListingsResponse {
    let data: [Item]
}

extension ListingsResponse: Decodable {
    private enum ListingsResponseCodingKeys: String, CodingKey {
        case data
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ListingsResponseCodingKeys.self)
        
        data = try container.decode([Item].self, forKey: .data)
    }
}

//MARK: Ticker
struct Quote {
    var price: Double
    var volume24h: Double
    var marketCap: Double
    var percentChange1h: Double
    var percentChange24h: Double
    var percentChange7d: Double
}

extension Quote: Decodable {
    private enum QUOTECodingKeys: String, CodingKey {
        case price
        case volume24h = "volume_24h"
        case marketCap = "market_cap"
        case percentChange1h = "percent_change_1h"
        case percentChange24h = "percent_change_24h"
        case percentChange7d = "percent_change_7d"
    }
    
    init(from decoder: Decoder) throws {
        let QUOTEContainer = try decoder.container(keyedBy: QUOTECodingKeys.self)
        
        price = try QUOTEContainer.decode(Double.self, forKey: .price)
        volume24h = (try? QUOTEContainer.decode(Double.self, forKey: .volume24h)) ?? 0
        marketCap = (try? QUOTEContainer.decode(Double.self, forKey: .marketCap)) ?? 0
        percentChange1h = (try? QUOTEContainer.decode(Double.self, forKey: .percentChange1h)) ?? 0
        percentChange24h = (try? QUOTEContainer.decode(Double.self, forKey: .percentChange24h)) ?? 0
        percentChange7d = (try? QUOTEContainer.decode(Double.self, forKey: .percentChange7d)) ?? 0
    }
}

struct Ticker {
    var id: UInt
    var name: String
    var symbol: String
    var websiteSlug: String
    var rank: UInt
    var circulatingSupply: Double
    var totalSupply: Double
    var maxSupply: Double
    var quotes: [String: Quote]
    var lastUpdated: UInt64

    var isToken: Bool
    var fullName: String
    var url: String
    var imageUrl: String
}

extension Ticker: Decodable {
    private enum TicketCodingKeys: String, CodingKey {
        case id
        case name
        case symbol
        case websiteSlug = "website_slug"
        case rank
        case circulatingSupply = "circulating_supply"
        case totalSupply = "total_supply"
        case maxSupply = "max_supply"
        case quotes
        case lastUpdated = "last_updated"
    }
    
    init(from decoder: Decoder) throws {
        let ticketContainer = try decoder.container(keyedBy: TicketCodingKeys.self)
        
        id = try ticketContainer.decode(UInt.self, forKey: .id)
        name = try ticketContainer.decode(String.self, forKey: .name)
        symbol = try ticketContainer.decode(String.self, forKey: .symbol)
        websiteSlug = try ticketContainer.decode(String.self, forKey: .websiteSlug)
        rank = try ticketContainer.decode(UInt.self, forKey: .rank)
        circulatingSupply = (try? ticketContainer.decode(Double.self, forKey: .circulatingSupply)) ?? 0.0
        totalSupply = (try? ticketContainer.decode(Double.self, forKey: .totalSupply)) ?? 0.0
        maxSupply = (try? ticketContainer.decode(Double.self, forKey: .maxSupply)) ?? 0.0
        quotes = try ticketContainer.decode([String: Quote].self, forKey: .quotes)
        lastUpdated = try ticketContainer.decode(UInt64.self, forKey: .lastUpdated)
        
        isToken = false
        fullName = ""
        url = ""
        imageUrl = ""
    }
}

struct TickersResponse {
    let data: [Ticker]
}

extension TickersResponse: Decodable {
    private enum TickersResponseCodingKeys: String, CodingKey {
        case data
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: TickersResponseCodingKeys.self)
        
        data = try container.decode([Ticker].self, forKey: .data)
    }
}

//MARK: Global Data
struct GlobalQuote {
    let totalMarketCap: Double
    let totalVolume24H: Double
}

extension GlobalQuote: Decodable {
    private enum GlobalQuoteKeys:String, CodingKey {
        case totalMarketCap = "total_market_cap"
        case totalVolume24H = "total_volume_24h"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: GlobalQuoteKeys.self)
        
        totalMarketCap = try container.decode(Double.self, forKey: .totalMarketCap)
        totalVolume24H = try container.decode(Double.self, forKey: .totalVolume24H)
    }
}

struct Global {
    let activeCryptoCurrencies: Int
    let activeMarkets: Int
    let bitcoinPercentageOfMarketCap: Double
    let quotes: [String: GlobalQuote]
    let lastUpdated: Int
}

extension Global: Decodable {
    private enum GlobalCodingKeys: String, CodingKey {
        case activeCryptoCurrencies = "active_cryptocurrencies"
        case activeMarkets = "active_markets"
        case bitcoinPercentageOfMarketCap = "bitcoin_percentage_of_market_cap"
        case quotes
        case lastUpdated = "last_updated"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: GlobalCodingKeys.self)
        
        activeCryptoCurrencies = try container.decode(Int.self, forKey: .activeCryptoCurrencies)
        activeMarkets = try container.decode(Int.self, forKey: .activeMarkets)
        bitcoinPercentageOfMarketCap = try container.decode(Double.self, forKey: .bitcoinPercentageOfMarketCap)
        quotes = try container.decode([String: GlobalQuote].self, forKey: .quotes)
        lastUpdated = try container.decode(Int.self, forKey: .lastUpdated)
    }
}

struct GlobalResponse {
    let data: Global
}

extension GlobalResponse: Decodable {
    private enum GlobalResponseCodingKeys: String, CodingKey {
        case data
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: GlobalResponseCodingKeys.self)

        data = try container.decode(Global.self, forKey: .data)
    }
}
