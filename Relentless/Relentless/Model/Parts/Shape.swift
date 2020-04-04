//
//  Shape.swift
//  Relentless
//
//  Created by Chow Yi Yin on 2/4/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import Foundation
enum Shape: String, Codable, CaseIterable {
    case circle
    case triangle
    case square

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ShapeKeys.self)
        let rawValue = try container.decode(String.self, forKey: .shape)
        switch rawValue {
        case Shape.circle.rawValue:
            self = .circle
        case Shape.triangle.rawValue:
            self = .triangle
        case Shape.square.rawValue:
            self = .square
        default:
            throw ShapeError.unknownValue
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: ShapeKeys.self)
        switch self {
        case .circle:
            try container.encode(Shape.circle.rawValue, forKey: .shape)
        case .triangle:
            try container.encode(Shape.triangle.rawValue, forKey: .shape)
        case .square:
            try container.encode(Shape.square.rawValue, forKey: .shape)
        }
    }

    func toString() -> String {
        return self.rawValue
    }
}

enum ShapeKeys: CodingKey {
    case shape
}

enum ShapeError: Error {
    case unknownValue
}
