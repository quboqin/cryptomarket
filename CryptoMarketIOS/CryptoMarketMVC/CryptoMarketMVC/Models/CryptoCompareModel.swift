//
//  CryptoCompare.swift
//  BitcoinMarketMVC
//
//  Created by Qubo on 8/3/18.
//  Copyright © 2018 Qubo. All rights reserved.
//

import Foundation

//MARK: CoinList
struct Coin {
    var id: String
    var url: String
    var imageUrl: String
    var name: String
    var symbol: String
    var coinName: String
    var fullName: String
    var algorithm: String
    var proofType: String
    var fullyPremined: String
    var totalCoinSupply: String
    var builtOn: String
    var smartContractAddress: String
    var preMinedValue: String
    var totalCoinsFreeFloat: String
    var sortOrder: String
    var sponsored: Bool
}

extension Coin: Decodable {
    private enum CoinCodingKeys: String, CodingKey {
      case id = "Id"
      case url = "Url"
      case imageUrl = "ImageUrl"
      case name = "Name"
      case symbol = "Symbol"
      case coinName = "CoinName"
      case fullName = "FullName"
      case algorithm = "Algorithm"
      case proofType = "ProofType"
      case fullyPremined = "FullyPremined"
      case totalCoinSupply = "TotalCoinSupply"
      case builtOn = "BuiltOn"
      case smartContractAddress = "SmartContractAddress"
      case preMinedValue = "PreMinedValue"
      case totalCoinsFreeFloat = "TotalCoinsFreeFloat"
      case sortOrder = "SortOrder"
      case sponsored = "Sponsored"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CoinCodingKeys.self)

        id = try container.decode(String.self, forKey: .id)
        url = try container.decode(String.self, forKey: .url)
        imageUrl = (try? container.decode(String.self, forKey: .imageUrl)) ?? ""
        name = try container.decode(String.self, forKey: .name)
        symbol = try container.decode(String.self, forKey: .symbol)
        coinName = try container.decode(String.self, forKey: .coinName)
        fullName = try container.decode(String.self, forKey: .fullName)
        algorithm = try container.decode(String.self, forKey: .algorithm)
        proofType = try container.decode(String.self, forKey: .proofType)
        fullyPremined = try container.decode(String.self, forKey: .fullyPremined)
        totalCoinSupply = try container.decode(String.self, forKey: .totalCoinSupply)
        builtOn = try container.decode(String.self, forKey: .builtOn)
        smartContractAddress = try container.decode(String.self, forKey: .smartContractAddress)
        preMinedValue = try container.decode(String.self, forKey: .preMinedValue)
        totalCoinsFreeFloat = try container.decode(String.self, forKey: .totalCoinsFreeFloat)
        sortOrder = try container.decode(String.self, forKey: .sortOrder)
        sponsored = try container.decode(Bool.self, forKey: .sponsored)
    }
}

struct CoinListResponse {
    var response: String
    var message: String
    var baseImageUrl: String
    var baseLinkUrl: String
    var data: [String: Coin]
}

extension CoinListResponse: Decodable {
    private enum CoinListResponseCodingKeys: String, CodingKey {
        case response = "Response"
        case message = "Message"
        case baseImageUrl = "BaseImageUrl"
        case baseLinkUrl = "BaseLinkUrl"
        case data = "Data"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CoinListResponseCodingKeys.self)

        response = try container.decode(String.self, forKey: .response)
        message = try container.decode(String.self, forKey: .message)
        baseImageUrl = try container.decode(String.self, forKey: .baseImageUrl)
        baseLinkUrl = try container.decode(String.self, forKey: .baseLinkUrl)
        data = try container.decode([String: Coin].self, forKey: .data)
    }
}

//MARK: HistoHour
struct OHLCV {
    var time: Int
    var open: Double
    var close: Double
    var low: Double
    var high: Double
    var volumefrom: Double
    var volumeto: Double
}

extension OHLCV: Decodable {
  private enum OHLCVCodingKeys: String, CodingKey {
    case time
    case open
    case close
    case low
    case high
    case volumefrom
    case volumeto
  }

  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: OHLCVCodingKeys.self)

    time = try container.decode(Int.self, forKey: .time)
    open = try container.decode(Double.self, forKey: .open)
    close = try container.decode(Double.self, forKey: .close)
    low = try container.decode(Double.self, forKey: .low)
    high = try container.decode(Double.self, forKey: .high)
    volumefrom = try container.decode(Double.self, forKey: .volumefrom)
    volumeto = try container.decode(Double.self, forKey: .volumeto)
  }
}

struct HistoHourResponse {
    var response: String
    var type: UInt
    var aggregated: Bool
    var data: [OHLCV]
    var timeTo: Int
    var timeFrom: Int
}

extension HistoHourResponse: Decodable {
  private enum HistoHourResponseCodingKeys: String, CodingKey {
    case response = "Response"
    case type = "Type"
    case aggregated = "Aggregated"
    case data = "Data"
    case timeTo = "TimeTo"
    case timeFrom = "TimeFrom"
  }

  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: HistoHourResponseCodingKeys.self)

    response = try container.decode(String.self, forKey:.response)
    type = try container.decode(UInt.self, forKey:.type)
    aggregated = try container.decode(Bool.self, forKey:.aggregated)
    data = try container.decode([OHLCV].self, forKey:.data)
    timeTo = try container.decode(Int.self, forKey:.timeTo)
    timeFrom = try container.decode(Int.self, forKey:.timeFrom)
  }
}
