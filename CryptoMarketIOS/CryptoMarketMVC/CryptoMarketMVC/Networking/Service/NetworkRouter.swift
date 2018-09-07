//
//  NetworkRouter.swift
//  CoinMarketCapCloneOnIOS
//
//  Created by Qubo on 6/23/18.
//  Copyright © 2018 Qubo. All rights reserved.
//

import Foundation

public typealias NetworkRouterCompletion = (_ data: Data?,
    _ response: URLResponse?,
    _ error: Error?)->()

class Router<EndPoint: EndPointType> {
    private let session = URLSession(configuration: .default)
    private var task: URLSessionTask!
    
    func request(_ endPoint: EndPoint, networkRouterCompletion: @escaping NetworkRouterCompletion) -> URLSessionTask {
        do {
            let request = try self.buildRequest(from: endPoint)
            NetworkLogger.log(request: request)
            self.task = session.dataTask(with: request, completionHandler: { data, response, error in
                networkRouterCompletion(data, response, error)
            })
        } catch {
            networkRouterCompletion(nil, nil, error)
        }
        self.task.resume()
        return self.task
    }
    
    fileprivate func buildRequest(from endPoint: EndPoint) throws -> URLRequest {
        var request = URLRequest(url: endPoint.baseURL.appendingPathComponent(endPoint.path), cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
                                 timeoutInterval: 5.0)
        request.httpMethod = endPoint.httpMethod.rawValue
        do {
            switch endPoint.task {
            case .request:
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            case .requestParameters(let bodyParameters,
                                    let urlParameters):
                try self.configureParameters(bodyParameters: bodyParameters,
                                             urlParameters: urlParameters,
                                             request: &request)
            case .requestParametersWithSignature(let bodyParameters, let urlParameters, let accessKey, let secretKey):
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
                let someDateTime = formatter.string(from: Date())
                
                var signatureParams = ["AccessKeyId": accessKey,
                                       "SignatureMethod": "HmacSHA256",
                                       "SignatureVersion": "2",
                                       "Timestamp": someDateTime] as Parameters
                if let urlParameters = urlParameters {
                    signatureParams.merge(urlParameters) { (first, _) in first }
                }
                
                let signature = Signature.signature(requestMethod: endPoint.httpMethod.rawValue, host: endPoint.baseURL.absoluteString, path: endPoint.path, params: signatureParams, secretKey: secretKey)
                
                signatureParams["Signuture"] = signature
                
                try self.configureParameters(bodyParameters: bodyParameters,
                                             urlParameters: signatureParams,
                                             request: &request)
            case .requestParametersAndHeaders(let bodyParameters,
                                              let urlParameters,
                                              let additionHeaders):
                self.additionalHeaders(additionHeaders, request: &request)
                try self.configureParameters(bodyParameters: bodyParameters,
                                             urlParameters: urlParameters,
                                             request: &request)
            }
            return request
        } catch {
            throw error
        }
    }
    
    fileprivate func configureParameters(bodyParameters: Parameters?,
                                         urlParameters: Parameters?,
                                         request: inout URLRequest) throws {
        do {
            if let bodyParameters = bodyParameters {
                try BodyParameterEncoder.encode(urlRequest: &request, with: bodyParameters)
            }
            if let urlParameters = urlParameters {
                try URLParameterEncoder.encode(urlRequest: &request, with: urlParameters)
            }
        } catch {
            throw error
        }
    }
    
    fileprivate func additionalHeaders(_ additionalHeaders: HTTPHeaders?, request: inout URLRequest) {
        guard let headers = additionalHeaders else { return }
        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }
    }
}



