//
//  Signature.swift
//  CoinMarketCapCloneOnIOS
//
//  Created by Qubo on 6/22/18.
//  Copyright © 2018 Qubo. All rights reserved.
//

import Foundation

public struct Signature {
    static func signature(requestMethod method: String, host: String, path: String, params: Parameters, secretKey: String) -> String? {
        var host = host.replacingOccurrences(of: "https://", with: "")
        host = host.replacingOccurrences(of: "http://", with: "")
        
        var signatureOriginal: String = "\(method)\n\(host)\n\(path)\n"
        
        let sortedKeys = params.keys.sorted()
            
        for (index, key) in sortedKeys.enumerated()  {
            if index == 0 {
                signatureOriginal += "\(key)=\(String(describing: params[key]))"
            } else {
                signatureOriginal += "&\(key)=\(String(describing: params[key]))"
            }
        }
        
        if let dataToSign = signatureOriginal.data(using: .utf8) {
            if let signingSecretData = secretKey.data(using: .utf8) {
                let digestLength = Int(CC_SHA256_DIGEST_LENGTH)
                let digestBytes = UnsafeMutablePointer<UInt8>.allocate(capacity:digestLength)
                
                CCHmac(CCHmacAlgorithm(kCCHmacAlgSHA256), [UInt8](signingSecretData), signingSecretData.count, [UInt8](dataToSign), dataToSign.count, digestBytes)
                
                let hmacData = Data(bytes: digestBytes, count: digestLength)
                return hmacData.base64EncodedString()
            }
        }
        
        return nil
    }
}
