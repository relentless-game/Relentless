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
    var items = [Item]()
    
    init(items: [Item]) {
        self.items = items
    }
    
    enum ItemFactoryKey: CodingKey {
        case items
    }

    enum ItemTypeKey: CodingKey {
        case itemType
        case partType
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: ItemFactoryKey.self)
        try container.encode(items, forKey: .items)
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ItemFactoryKey.self)
        var itemsArrayForType = try container.nestedUnkeyedContainer(forKey: ItemFactoryKey.items)
        var items = [Item]()
        var itemsArray = itemsArrayForType
        while !itemsArrayForType.isAtEnd {
            let item = try itemsArrayForType.nestedContainer(keyedBy: ItemTypeKey.self)
            let type = try item.decode(ItemType.self, forKey: ItemTypeKey.itemType)
            switch type {
            case .titledItem:
                items.append(try itemsArray.decode(TitledItem.self))
            case .assembledItem:
                items.append(try itemsArray.decode(AssembledItem.self))
            case .statefulItem:
                items.append(try itemsArray.decode(StatefulItem.self))
            case .rhythmicItem:
                items.append(try itemsArray.decode(RhythmicItem.self))
            }
        }
        self.items = items
    }
}
