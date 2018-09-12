//
//  PersistentModel.swift
//  CryptoMarketMVC
//
//  Created by Qubo on 9/11/18.
//  Copyright © 2018 Qubo. All rights reserved.
//

import Foundation

struct SavedTicker: Codable {
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
    var fullName: String
    var imageUrl: String
    
    enum CodingKeys: String, CodingKey {
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
        case fullName
        case imageUrl
    }
}

extension SavedTicker {
    init(from decoder: Decoder) throws {
        let ticketContainer = try decoder.container(keyedBy: CodingKeys.self)
        
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
        fullName = try ticketContainer.decode(String.self, forKey: .fullName)
        imageUrl = try ticketContainer.decode(String.self, forKey: .imageUrl)
    }
}

struct SavedTickers: Codable {
    let baseImageUrl: String
    let data: [SavedTicker]
}
