//
//  CryptoCompareEndPoint.swift
//  BitcoinMarketMVC
//
//  Created by Qubo Qin on 8/14/18.
//  Copyright © 2018 Qubo. All rights reserved.
//

import Foundation

public enum CryptoCompareAPI {
    case histohour(fsym: String?, tsym: String?, limit: Int?)
    case coinlist
}

extension CryptoCompareAPI: EndPointType {
    var environmentBaseURL: String {
        switch NetworkEnvironment.environment {
        case .product:
            return "https://min-api.cryptocompare.com/data/"
        case .staging:
            return "https://min-api.cryptocompare.com/data/"
        case .qa:
            return "https://min-api.cryptocompare.com/data/"
        }
    }
    
    var baseURL: URL {
        guard let url = URL(string: environmentBaseURL) else { fatalError("baseURL coud not be configured.") }
        return url
    }
    
    var path: String {
        switch self {
        case .histohour(_, _, _):
            return "histohour"
        case .coinlist:
            return "all/coinlist"

        }
    }
    
    var httpMethod: HTTPMethod {
        return .get
    }
    
    var task: HTTPTask {
        switch self {
        case .histohour(let fsym, let tsym, let limit):
            return .requestParameters(bodyParameters: nil, urlParameters: ["fsym": fsym!,
                                                        "tsym": tsym!,
                                                       "limit": limit!])
        case .coinlist:
            return .requestParameters(bodyParameters: nil, urlParameters: nil)
        }
    }
    
    var headers: HTTPHeaders? {
        return nil
    }
}

