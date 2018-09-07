//
//  CoinMarketEndPoint.swift
//  CoinMarketCapCloneOnIOS
//
//  Created by Qubo on 6/23/18.
//  Copyright © 2018 Qubo. All rights reserved.
//

import Foundation

public enum CoinMarketAPI {
    case listings
    case ticker(start: Int?, limit: Int?, sort: String?, structure: String?, convert: String?)
    case tickerId(id: Int, structure: String?, convert: String?)
    case globalData(convert: String?)
}

extension CoinMarketAPI: EndPointType {
    var environmentBaseURL: String {
        switch NetworkEnvironment.environment {
        case .product:
            return "https://api.coinmarketcap.com/v2/"
        case .staging:
            return "https://api.coinmarketcap.com/v2/"
        case .qa:
            return "https://api.coinmarketcap.com/v2/"
        }
    }
    
    var baseURL: URL {
        guard let url = URL(string: environmentBaseURL) else { fatalError("baseURL coud not be configured.") }
        return url
    }
    
    var path: String {
        switch self {
        case .listings:
            return "listings"
        case .ticker(_, _, _, _, _):
            return "ticker"
        case .tickerId(let id, _, _):
            return "ticker/\(id)"
        case .globalData(_):
            return "global"
        }
    }
    
    var httpMethod: HTTPMethod {
        return .get
    }
    
    var task: HTTPTask {
        switch self {
        case .ticker(let start, let limit, let sort, let structure, let convert):
            return .requestParameters(bodyParameters: nil, urlParameters: ["start": start!,
                                                                           "limit": limit!,
                                                                            "sort": sort!,
                                                                        "structure": structure!,
                                                                        "convert": convert!])
        case .tickerId(_, let structure, let convert):
            return .requestParameters(bodyParameters: nil, urlParameters: ["structure": structure!,
                                                                           "convert": convert!])
        case .globalData(let convert):
            return .requestParameters(bodyParameters: nil, urlParameters: ["convert": convert!])
            
        default:
            return .request
        }
    }
    
    var headers: HTTPHeaders? {
        return nil
    }
}
