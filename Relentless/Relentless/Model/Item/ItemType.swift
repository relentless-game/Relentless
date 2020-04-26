//
//  ItemType.swift
//  Relentless
//
//  Created by Liu Zechu on 14/4/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import Foundation

/// This enum is used for encoding and decoding of `Item`s.
enum ItemType: String, Codable {
    case statefulItem
    case titledItem
    case rhythmicItem
    case assembledItem
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ItemTypeKeys.self)
        let rawValue = try container.decode(String.self, forKey: .itemType)
        switch rawValue {
        case ItemType.statefulItem.rawValue:
            self = .statefulItem
        case ItemType.titledItem.rawValue:
            self = .titledItem
        case ItemType.rhythmicItem.rawValue:
            self = .rhythmicItem
        case ItemType.assembledItem.rawValue:
            self = .assembledItem
        default:
            throw ItemTypeError.unknownValue
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: ItemTypeKeys.self)
        switch self {
        case .statefulItem:
            try container.encode(ItemType.statefulItem.rawValue, forKey: .itemType)
        case .titledItem:
            try container.encode(ItemType.titledItem.rawValue, forKey: .itemType)
        case .rhythmicItem:
            try container.encode(ItemType.rhythmicItem.rawValue, forKey: .itemType)
        case .assembledItem:
            try container.encode(ItemType.assembledItem.rawValue, forKey: .itemType)

        }
    }
}

enum ItemTypeKeys: CodingKey {
    case itemType
}

enum ItemTypeError: Error {
    case unknownValue
}
