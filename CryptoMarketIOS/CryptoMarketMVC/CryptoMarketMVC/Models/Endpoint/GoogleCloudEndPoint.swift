//
//  GoogleCloudEndPoint.swift
//  CryptoMarketMVC
//
//  Created by Qubo on 10/9/18.
//  Copyright © 2018 Qubo. All rights reserved.
//

import Foundation
import UIKit

public enum GoogleCloudAPI {
    case detect_handwriting(image: UIImage?)
}

extension GoogleCloudAPI: EndPointType {
    var APIKey: String {
        get {
            return "AIzaSyBZeCnbSasN0Nutu7LkFOYBxf-4OIHFjDA"
        }
    }
    
    var environmentBaseURL: String {
        switch NetworkEnvironment.environment {
        case .product:
            return "https://vision.googleapis.com/v1p3beta1/images"
        case .staging:
            return "https://vision.googleapis.com/v1p3beta1/images"
        case .qa:
            return "https://vision.googleapis.com/v1p3beta1/images"
        }
    }
    
    var baseURL: URL {
        guard let url = URL(string: environmentBaseURL) else { fatalError("baseURL coud not be configured.") }
        return url
    }
    
    var path: String {
        switch self {
        case .detect_handwriting(_):
            return ":annotate"
        }
    }
    
    var httpMethod: HTTPMethod {
        return .post
    }
    
    var task: HTTPTask {
        switch self {
        case .detect_handwriting(let image):
            let base64 = image?.base64(format: .PNG)
            let body = ["requests":
                [
                    "image": [
                        "content": base64
                    ],
                    "features": [
                        ["type": "DOCUMENT_TEXT_DETECTION"]
                    ],
                    "imageContext": [
                        "languageHints": ["en-t-i0-handwrit"]
                    ]
                ]
            ]
            return .requestParametersAndHeaders(bodyParameters: body, urlParameters: nil, additionHeaders: headers)
        }
    }
    
    var headers: HTTPHeaders? {
        return ["X-Goog-Api-Key": APIKey, "Content-Type": "application/json; charset=utf-8"]
    }
}
