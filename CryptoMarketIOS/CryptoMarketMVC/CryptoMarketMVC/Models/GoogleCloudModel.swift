//
//  GoogleCloudModel.swift
//  CryptoMarketMVC
//
//  Created by Qubo on 10/10/18.
//  Copyright © 2018 Qubo. All rights reserved.
//

import Foundation

struct Point {
    var x: Int
    var y: Int
}

extension Point: Decodable {
    private enum PointCodingKeys: String, CodingKey {
        case x
        case y
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: PointCodingKeys.self)
        
        x = try container.decode(Int.self, forKey: .x)
        y = try container.decode(Int.self, forKey: .y)
    }
}

struct BoundingPoly {
    var vertices: [Point]
}

extension BoundingPoly: Decodable {
    private enum BoundingPolyCodingKeys: String, CodingKey {
        case vertices
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: BoundingPolyCodingKeys.self)
        
        vertices = try container.decode([Point].self, forKey: .vertices)
    }
}

struct TextAnnotation {
    var locale: String
    var description: String
    var boundingPoly: BoundingPoly
}

extension TextAnnotation: Decodable {
    private enum TextAnnotationCodingKeys: String, CodingKey {
        case locale
        case description
        case boundingPoly
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: TextAnnotationCodingKeys.self)
        
        locale = (try? container.decode(String.self, forKey: .locale)) ?? ""
        description = try container.decode(String.self, forKey: .description)
        boundingPoly = try container.decode(BoundingPoly.self, forKey: .boundingPoly)
    }
}

struct ResponseItem {
    var textAnnotations: [TextAnnotation]
}

extension ResponseItem: Decodable {
    private enum ResponseItemCodingKeys: String, CodingKey {
        case textAnnotations
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ResponseItemCodingKeys.self)
        
        textAnnotations = try container.decode([TextAnnotation].self, forKey: .textAnnotations)
    }
}

struct GoogleCloudResponses {
    var responses: [ResponseItem]
}

extension GoogleCloudResponses: Decodable {
    private enum GoogleCloudResponsesCodingKeys: String, CodingKey {
        case responses
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: GoogleCloudResponsesCodingKeys.self)
        
        responses = try container.decode([ResponseItem].self, forKey: .responses)
    }
}
