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
    var quotes: [String: Quote]
    var fullName: String
    var imageUrl: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case symbol
        case quotes
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
        quotes = try ticketContainer.decode([String: Quote].self, forKey: .quotes)
        fullName = try ticketContainer.decode(String.self, forKey: .fullName)
        imageUrl = try ticketContainer.decode(String.self, forKey: .imageUrl)
    }
}

struct SavedTickers: Codable {
    let baseImageUrl: String
    let data: [SavedTicker]
}
