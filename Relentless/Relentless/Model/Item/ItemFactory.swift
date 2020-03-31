//
//  Items.swift
//  Relentless
//
//  Created by Liu Zechu on 21/3/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import Foundation

/// This is a wrapper class that contains an array of items of heterogeneous types.
class ItemFactory: Codable {
    let items: [Item]
    
    init(items: [Item]) {
        self.items = items
    }
    
    enum ItemsKey: CodingKey {
        case items
    }

    enum ItemTypeKey: CodingKey {
        case category
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: ItemsKey.self)
        try container.encode(items, forKey: .items)
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ItemsKey.self)
        var itemsArrayForType = try container.nestedUnkeyedContainer(forKey: ItemsKey.items)
        var items = [Item]()
        var itemsArray = itemsArrayForType
        while !itemsArrayForType.isAtEnd {
            let item = try itemsArrayForType.nestedContainer(keyedBy: ItemTypeKey.self)
            let type = try item.decode(Category.self, forKey: ItemTypeKey.category)
            switch type {
            case .book:
                items.append(try itemsArray.decode(Book.self))
            case .magazine:
                items.append(try itemsArray.decode(Magazine.self))
            case .toyCar:
                items.append(try itemsArray.decode(ToyCar.self))
            case .bulb:
                items.append(try itemsArray.decode(Bulb.self))
            default:
                continue
            }
        }
        self.items = items
    }
}
