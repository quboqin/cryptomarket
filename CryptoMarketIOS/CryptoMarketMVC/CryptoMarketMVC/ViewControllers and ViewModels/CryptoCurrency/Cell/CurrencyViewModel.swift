//
//  CurrencyViewModel.swift
//  CryptoMarketMVC
//
//  Created by Qubo on 9/24/18.
//  Copyright © 2018 Qubo. All rights reserved.
//

import Foundation
import RxSwift

class CurrencyViewModel {
    var id: UInt
    var name: String
    var fullName: String
    var imageUrl: String
    var symbol: String
    var price: Double?
    var change: Double?
    var volume24h: Double?
    var url: String
    var isToken: Bool
    var quotes: [String: Quote]
    
    init(currency: Ticker) {
        self.id = currency.id
        self.name = currency.name
        self.fullName = currency.fullName
        self.imageUrl = currency.imageUrl
        self.symbol = currency.symbol
        self.price = currency.quotes["USD"]?.price
        self.change = currency.quotes["USD"]?.percentChange24h
        self.volume24h = currency.quotes["USD"]?.volume24h
        self.url = GlobalStatus.shared.baseImageUrl.value + currency.url
        self.isToken = currency.isToken
        self.quotes = currency.quotes
    }
}
