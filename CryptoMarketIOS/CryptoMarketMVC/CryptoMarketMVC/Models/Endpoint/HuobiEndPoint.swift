//
//  HuobiEndPoint.swift
//  CoinMarketCapCloneOnIOS
//
//  Created by Qubo on 6/24/18.
//  Copyright © 2018 Qubo. All rights reserved.
//

import Foundation

public enum HuobiAPI {
    case historyKline(symbol: String?, period: String?, size: Int?)
    case marketDepth(symbol: String?, type: String?)
    case marketTickers
}

extension HuobiAPI: EndPointType {
    var accessKey: String {
        get {
            return "76f88d90-5a0cdcb9-13aba139-108a6"
        }
    }
    
    var secretKey: String {
        get {
            return "61f7c1cb-51cda2a9-05779d97-4cba2"
        }
    }
    
    var environmentBaseURL: String {
        switch NetworkEnvironment.environment {
        case .product:
            return "https://api.huobi.pro/market"
        case .staging:
            return "https://api.huobi.pro/market"
        case .qa:
            return "https://api.huobi.pro/market"
        }
    }
    
    var baseURL: URL {
        guard let url = URL(string: environmentBaseURL) else { fatalError("baseURL coud not be configured.") }
        return url
    }
    
    var path: String {
        switch self {
        case .historyKline:
            return "/history/kline"
        case .marketDepth:
            return "/depth"
        case .marketTickers:
            return "/tickers"
        }
    }
    
    var httpMethod: HTTPMethod {
        return .get
    }
    
    var task: HTTPTask {
        switch self {
        case .historyKline(let symbol, let period, let size):
            return .requestParametersWithSignature(bodyParameters: nil, urlParameters: ["symbol": symbol!,
                                                                                        "period": period!,
                                                                                        "size": size!] , accessKey: accessKey, secretKey: secretKey)
        case .marketDepth(let symbol, let type):
            return .requestParametersWithSignature(bodyParameters: nil, urlParameters: ["symbol": symbol!,
                                                                                        "type": type!], accessKey: accessKey, secretKey: secretKey)
        case .marketTickers:
            return .requestParametersWithSignature(bodyParameters: nil, urlParameters: nil, accessKey: accessKey, secretKey: secretKey)
        }
    }
    
    var headers: HTTPHeaders? {
        return nil
    }
}
