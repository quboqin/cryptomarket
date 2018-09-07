//
//  EndPointType.swift
//  CoinMarketCapCloneOnIOS
//
//  Created by Qubo on 6/23/18.
//  Copyright © 2018 Qubo. All rights reserved.
//

import Foundation

public typealias Parameters = [String: Any]
public typealias HTTPHeaders = [String: String]

public enum HTTPMethod: String {
    case get    = "GET"
    case post   = "POST"
}

public enum HTTPTask {
    case request
    case requestParameters(bodyParameters: Parameters?, urlParameters: Parameters?)
    case requestParametersWithSignature(bodyParameters: Parameters?, urlParameters: Parameters?, accessKey: String, secretKey: String)
    case requestParametersAndHeaders(bodyParameters: Parameters?, urlParameters: Parameters?, additionHeaders: HTTPHeaders?)
}

protocol EndPointType {
    var baseURL: URL { get }
    var path: String { get }
    var httpMethod: HTTPMethod { get }
    var task: HTTPTask { get }
    var headers: HTTPHeaders? { get }
}
