//
//  Image-Extensions.swift
//  CryptoMarketMVC
//
//  Created by Qubo on 10/10/18.
//  Copyright © 2018 Qubo. All rights reserved.
//

import Foundation
import UIKit

public enum ImageFormat {
    case PNG
    case JPEG(CGFloat)
}

extension UIImage {
    
    public func base64(format: ImageFormat) -> String {
        var imageData: NSData
        switch format {
        case .PNG: imageData = self.pngData()! as NSData
        case .JPEG(let compression): imageData = self.jpegData(compressionQuality: compression)! as NSData
        }
        return imageData.base64EncodedString(options: .lineLength64Characters)
    }
}
