//
//  AssembedItem.swift
//  Relentless
//
//  Created by Chow Yi Yin on 26/3/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import Foundation

class AssembledItem: Item {
    static let partType = PartType.partContainer
    internal var unsortedParts: [Part] {
        didSet {
            NotificationCenter.default.post(name: .didChangeAssembledItem, object: nil)
        }
    }

    let partType = AssembledItem.partType

    var parts: [Part] {
        unsortedParts.sorted()
    }

    init(parts: [Part], category: Category) {
        self.unsortedParts = parts.sorted()
        super.init(category: category)
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: AssembledItemKeys.self)
        let partsObject = try container.decode(PartFactory.self, forKey: .parts)
        self.unsortedParts = partsObject.parts

        try super.init(from: decoder)
    }

    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: AssembledItemKeys.self)
        let partFactoryWrapper = PartFactory(parts: unsortedParts)
        try container.encode(partFactoryWrapper, forKey: .parts)
        try container.encode(partType, forKey: .partType)

        try super.encode(to: encoder)
    }

    func addPart(part: Part) {
        unsortedParts.append(part)
    }

    func removePart(part: Part) {
        guard let partIndex = parts.firstIndex(of: part) else {
            return
        }
        unsortedParts.remove(at: partIndex)
    }

    override func isLessThan(other: Item) -> Bool {
        guard let otherItem = other as? AssembledItem else {
            return false
        }
        if self.category.rawValue < otherItem.category.rawValue {
            return true
        } else if self.category.rawValue > otherItem.category.rawValue {
            return false
        } else {
            return checkPartsAreLessThan(otherItem: otherItem)
        }
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
        "AssembledItem"
    }
}

enum AssembledItemKeys: CodingKey {
    case parts
    case category
    case partType
}
