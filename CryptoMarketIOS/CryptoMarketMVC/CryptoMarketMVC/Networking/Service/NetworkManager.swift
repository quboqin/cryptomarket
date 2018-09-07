//
//  NetworkManager.swift
//  CoinMarketCapCloneOnIOS
//
//  Created by Qubo on 6/23/18.
//  Copyright © 2018 Qubo. All rights reserved.
//

import Foundation

// MARK: NetworkEnvironment
struct NetworkEnvironment {
    enum _NetworkEnvironment {
        case qa
        case product
        case staging
    }
    
    static let environment: _NetworkEnvironment = .product
    
    private init() {
    }
}

// MARK: NetworkManager
enum NetworkResponse: String, Error {
    case success
    case authentictionError = "You need to be authenticated first."
    case badRequest = "Bad request"
    case outdated = "The url you requested is outdate."
    case failed = "Network request failed."
    
    case noData = "Response returned with no data to decode."
    case unableTODecode = "We could not decode the response."
}

typealias NetworkManagerCompletion = (_ data: Any?,
    _ error: NetworkResponse?)->()

class NetworkManager<EndPoint: EndPointType> {
    typealias taskId = String
    var tasks = [taskId: URLSessionTask]()
    
    var router: Router<EndPoint>
    init(_ router: Router<EndPoint>) {
        self.router = router
    }
    
    fileprivate func handleNetworkResponse(_ response: HTTPURLResponse) -> NetworkResponse {
        switch response.statusCode {
        case 200...299:
            return .success
        case 401...500:
            return .authentictionError
        case 501...599:
            return .badRequest
        case 600:
            return .outdated
        default:
            return .failed
        }
    }
    
    func getDataFromEndPoint<T: Decodable>(_ endPoint: EndPoint,
                                                 type: T.Type,
                             networkManagerCompletion: @escaping NetworkManagerCompletion) -> taskId {
        let task = router.request(endPoint) { (data, response, error) in
            DispatchQueue.main.async {
                if error != nil {
                    networkManagerCompletion(nil, NetworkResponse.failed)
                }
                if let response = response as? HTTPURLResponse {
                    let result = self.handleNetworkResponse(response)
                    switch result {
                    case .success:
                        guard let responseData = data else {
                            networkManagerCompletion(nil, NetworkResponse.noData)
                            return
                        }
                        do {
                            let apiResponse = try JSONDecoder().decode(type.self, from: responseData)
                            networkManagerCompletion(apiResponse, nil)
                        } catch {
                            networkManagerCompletion(nil, NetworkResponse.unableTODecode)
                        }
                    default:
                        networkManagerCompletion(nil, result)
                    }
                }
            }
        }
        let taskId = NSUUID().uuidString
        tasks = [taskId: task]
        return taskId
    }
    
    func cancelRequestWithUniqueKey(_ taskId: taskId) {
        tasks[taskId]?.cancel()
        tasks.removeValue(forKey: taskId)
    }
    
    func cancelAllRequests() {
        for (_, task) in tasks {
            task.cancel()
        }
    }
}

class CoinMartetNetworkManager: NetworkManager<CoinMarketAPI> {
    static let shared = CoinMartetNetworkManager()
    
    private init() {
        super.init(Router<CoinMarketAPI>())
    }
}

class CryptoCompareNetworkManager: NetworkManager<CryptoCompareAPI> {
    static let shared = CryptoCompareNetworkManager()
    
    private init() {
        super.init(Router<CryptoCompareAPI>())
    }
}

class HuobiNetworkManager: NetworkManager<HuobiAPI> {
    static let shared = HuobiNetworkManager()
    
    private init() {
        super.init(Router<HuobiAPI>())
    }
}
