//
//  AssembedItem.swift
//  Relentless
//
//  Created by Chow Yi Yin on 26/3/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import Foundation

/// Assembled items cannot be added to the inventory
class AssembledItem: Item {
    static let isInventoryItem = false
    internal var unsortedParts: [Item] {
        didSet {
            NotificationCenter.default.post(name: .didChangeAssembledItem, object: nil)
        }
    }
    
    var parts: [Item] {
        unsortedParts.sorted()
    }

    init(parts: [Item], category: Category, isOrderItem: Bool) {
        self.unsortedParts = parts.sorted()
        super.init(category: category, isInventoryItem: AssembledItem.isInventoryItem,
                   isOrderItem: isOrderItem)
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: AssembledItemKeys.self)
        let partsObject = try container.decode(ItemFactory.self, forKey: .parts)
        self.unsortedParts = partsObject.items

        try super.init(from: decoder)
    }

    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: AssembledItemKeys.self)
        let itemFactoryWrapper = ItemFactory(items: unsortedParts)
        try container.encode(itemFactoryWrapper, forKey: .parts)
        try super.encode(to: encoder)
    }

    func addPart(part: Item) {
        unsortedParts.append(part)
    }

    func removePart(part: Item) {
        guard let partIndex = parts.firstIndex(of: part) else {
            return
        }
        unsortedParts.remove(at: partIndex)
    }

//    func toImageString() -> String {
//        var colour: Colour?
//        var label: Label?
//        var shape: Shape?
//        for part in unsortedParts {
//            switch part.partType {
//            case .toyCarBattery:
//                label = (part as? ToyCarBattery)?.label
//            case .toyCarBody:
//                colour = (part as? ToyCarBody)?.colour
//            case .toyCarWheel:
//                shape = (part as? ToyCarWheel)?.shape
//            case .partContainer:
//                assert(false)
//            }
//        }
//        guard colour != nil, label != nil, shape != nil else {
//            return ""
//        }
//        // Force as all are not nil
//        let string = "toycar_whole_\(colour!.toString())_\(shape!.toString())_\(label!.toString())"
//        return string
//    }
//

    /// Other item should be of type AssembledItem and should have the same category as this object
    override func isLessThan(other: Item) -> Bool {
        guard let otherItem = other as? AssembledItem else {
            assertionFailure("other item should be of type AssembledItem")
            return false
        }
        assert(otherItem.category == self.category)
        return checkPartsAreLessThan(otherItem: otherItem)
    }

    private func checkPartsAreLessThan(otherItem: AssembledItem) -> Bool {
        if self.unsortedParts.count < otherItem.unsortedParts.count {
            return true
        } else if self.unsortedParts.count > otherItem.unsortedParts.count {
            return false
        } else {
            var numberOfPartsThatAreLessThanOther = 0
            var numberOfPartsThatAreMoreThanOther = 0
            let numberOfParts = self.unsortedParts.count
            for counter in 0..<numberOfParts {
                let ownPart = self.unsortedParts[counter]
                let otherPart = self.unsortedParts[counter]
                if ownPart < otherPart {
                    numberOfPartsThatAreLessThanOther += 1
                } else {
                    numberOfPartsThatAreMoreThanOther += 1
                }
            }
            return numberOfPartsThatAreLessThanOther < numberOfPartsThatAreMoreThanOther
        }
    }

    override func hash(into hasher: inout Hasher) {
        hasher.combine(category)
        hasher.combine(unsortedParts)
    }

//    override func toString() -> String {
//        var string = "AssembledItem:"
//        for part in parts {
//            string.append(" " + part.toString())
//        }
//        return string
//    }

}

enum AssembledItemKeys: CodingKey {
    case parts
    case category
    case partType
}
