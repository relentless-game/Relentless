//
//  ImageString.swift
//  Relentless
//
//  Created by Chow Yi Yin on 24/4/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import Foundation
class ImageRepresentation: Codable {
    let imageStrings: [String]

    init(imageStrings: [String]) {
        self.imageStrings = imageStrings
    }
}

extension ImageRepresentation: Hashable {
    static func == (lhs: ImageRepresentation, rhs: ImageRepresentation) -> Bool {
        if let lhs = lhs as? AssembledItemImageRepresentation,
            let rhs = rhs as? AssembledItemImageRepresentation {
            return lhs == rhs
        }
        return lhs.imageStrings.sorted() == rhs.imageStrings.sorted()
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(imageStrings)
    }
}
