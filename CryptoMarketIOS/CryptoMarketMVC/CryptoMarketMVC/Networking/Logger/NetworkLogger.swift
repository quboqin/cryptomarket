//
//  NetworkLogger.swift
//  CoinMarketCapCloneOnIOS
//
//  Created by Qubo on 7/5/18.
//  Copyright © 2018 Qubo. All rights reserved.
//

import Foundation

class NetworkLogger {
    static func log(request: URLRequest) {
        
        Log.i("\n - - - - - - - - - - OUTGOING - - - - - - - - - - \n")
        defer { Log.i("\n - - - - - - - - - -  END - - - - - - - - - - \n") }
        
        let urlAsString = request.url?.absoluteString ?? ""
        let urlComponents = NSURLComponents(string: urlAsString)
        
        let method = request.httpMethod != nil ? "\(request.httpMethod ?? "")" : ""
        let path = "\(urlComponents?.path ?? "")"
        let query = "\(urlComponents?.query ?? "")"
        let host = "\(urlComponents?.host ?? "")"
        
        var logOutput = """
        \(urlAsString) \n\n
        \(method) \(path)?\(query) HTTP/1.1 \n
        HOST: \(host)\n
        """
        for (key,value) in request.allHTTPHeaderFields ?? [:] {
            logOutput += "\(key): \(value) \n"
        }
        if let body = request.httpBody {
            logOutput += "\n \(NSString(data: body, encoding: String.Encoding.utf8.rawValue) ?? "")"
        }
        
        Log.i(logOutput)
    }
    
    static func log(response: URLResponse) {}
}
