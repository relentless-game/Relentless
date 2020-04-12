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
        case category
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
            let type = try item.decode(Category.self, forKey: ItemTypeKey.category)
            switch type {
            case .book, .magazine:
                items.append(try itemsArray.decode(TitledItem.self))
            case .toyCar:
                items.append(try itemsArray.decode(AssembledItem.self))
//                let partType = try item.decode(PartType.self, forKey: ItemTypeKey.partType)
//                let itemsArrayAndDecodedItem = try decodeAssembledItemOrPart(partType: partType,
//                                                                             container: itemsArray,
//                                                                             category: Category.toyCar)
//                itemsArray = itemsArrayAndDecodedItem.0
//                guard let item = itemsArrayAndDecodedItem.1 else {
//                    continue
//                }
//                items.append(item)
                //items.append(try itemsArray.decode(ToyCar.self))
            case .wheel, .carBody, .battery:
                items.append(try itemsArray.decode(StatefulItem.self))
            case .robot:
                items.append(try itemsArray.decode(RhythmicItem.self))
            }
        }
        self.items = items
    }

//    private func decodeAssembledItemOrPart(partType: PartType, container: UnkeyedDecodingContainer,
//                                           category: Category) throws -> (UnkeyedDecodingContainer, Item?) {
//        var dataContainer = container
//        switch partType {
//        case PartType.toyCarWheel:
//            let item = try dataContainer.decode(ToyCarWheel.self)
//            return (dataContainer, item)
//        case PartType.toyCarBattery:
//            let item = try dataContainer.decode(ToyCarBattery.self)
//            return (dataContainer, item)
//        case PartType.toyCarBody:
//            let item = try dataContainer.decode(ToyCarBody.self)
//            return (dataContainer, item)
//        case PartType.partContainer:
//            return try decodeAssembledItem(container: container, category: category)
//        }
//    }

//    private func decodeAssembledItem(container: UnkeyedDecodingContainer,
//                                     category: Category) throws -> (UnkeyedDecodingContainer, Item?) {
//        var dataContainer = container
//        switch category {
//        case .toyCar:
//            let toyCar = try dataContainer.decode(ToyCar.self)
//            return (dataContainer, toyCar)
//        default:
//            return (dataContainer, nil)
//        }
//    }
}
