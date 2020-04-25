//
//  AssembledItemImageRepresentation.swift
//  Relentless
//
//  Created by Chow Yi Yin on 24/4/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import Foundation
class AssembledItemImageRepresentation: ImageRepresentation {
    // maps each Category to an array of strings. For StatefulItems and RhythmicItems,
    // the array is ordered by indices of the states that the image strings correspond to.
    // For TitledItems and AssembledItems, each array has only one string.
    let partsImageStrings: [Category: ImageRepresentation]

    init(mainImageStrings: [String], partsImageStrings: [Category: ImageRepresentation]) {
        self.partsImageStrings = partsImageStrings
        super.init(imageStrings: mainImageStrings)
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: AssembledItemImageRepresentationKeys.self)
        self.partsImageStrings = try container.decode([Category: ImageRepresentation].self,
                                                      forKey: .partsImageStrings)
        try super.init(from: decoder)
    }

    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: AssembledItemImageRepresentationKeys.self)
        try container.encode(partsImageStrings, forKey: .partsImageStrings)
        try super.encode(to: encoder)
    }
}

extension AssembledItemImageRepresentation {
    static func == (lhs: AssembledItemImageRepresentation,
                    rhs: AssembledItemImageRepresentation) -> Bool {
        lhs.imageStrings.sorted() == rhs.imageStrings.sorted() &&
            equal(lhs: lhs.partsImageStrings, rhs: rhs.partsImageStrings)
    }

    private static func equal(lhs: [Category: ImageRepresentation],
                              rhs: [Category: ImageRepresentation]) -> Bool {
        let keysAreTheSame = Array(lhs.keys).sorted() == Array(rhs.keys).sorted()
        if !keysAreTheSame {
            return false
        }
        for key in Array(lhs.keys) where lhs[key] != rhs[key] {
            return false
        }
        return true
    }
}

enum AssembledItemImageRepresentationKeys: CodingKey {
    case partsImageStrings
}
