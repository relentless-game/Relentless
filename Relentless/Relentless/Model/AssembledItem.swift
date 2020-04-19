//
//  AssembedItem.swift
//  Relentless
//
//  Created by Chow Yi Yin on 26/3/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import Foundation

class AssembledItem: Item {
    let mainImageString: String
    let partsImageStrings: [Category: String]
    
    internal var unsortedParts: [Item] {
        didSet {
            NotificationCenter.default.post(name: .didChangeAssembledItem, object: nil)
        }
    }
    
    var parts: [Item] {
        unsortedParts.sorted()
    }

    init(parts: [Item], category: Category, isInventoryItem: Bool,
         isOrderItem: Bool, mainImageString: String, partsImageStrings: [Category: String]) {
        self.unsortedParts = parts.sorted()
        self.mainImageString = mainImageString
        self.partsImageStrings = partsImageStrings
        super.init(itemType: .assembledItem, category: category,
                   isInventoryItem: isInventoryItem, isOrderItem: isOrderItem)
    }

    // To be called by ItemAssembler
    init(parts: [Item], category: Category, mainImageString: String, partsImageStrings: [Category: String]) {
        self.unsortedParts = parts
        self.mainImageString = mainImageString
        self.partsImageStrings = partsImageStrings
        // Set to false as item is assembled by user
        super.init(itemType: .assembledItem, category: category,
                   isInventoryItem: false, isOrderItem: false)
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: AssembledItemKeys.self)
        let partsObject = try container.decode(ItemFactory.self, forKey: .parts)
        self.unsortedParts = partsObject.items
        self.mainImageString = try container.decode(String.self, forKey: .mainImageString)
        self.partsImageStrings = try container.decode([Category: String].self, forKey: .partsImageStrings)
        try super.init(from: decoder)
    }

    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: AssembledItemKeys.self)
        let itemFactoryWrapper = ItemFactory(items: unsortedParts)
        try container.encode(itemFactoryWrapper, forKey: .parts)
        try container.encode(mainImageString, forKey: .mainImageString)
        try container.encode(partsImageStrings, forKey: .partsImageStrings)
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

    override func toString() -> String {
        ""
    }

    override func equals(other: Item) -> Bool {
        guard let otherItem = other as? AssembledItem else {
            return false
        }
        return self.category == otherItem.category &&
            self.parts == otherItem.parts
    }
}

enum AssembledItemKeys: CodingKey {
    case parts
    case mainImageString
    case partsImageStrings
}
