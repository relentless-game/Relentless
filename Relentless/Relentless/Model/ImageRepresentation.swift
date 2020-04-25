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
        lhs.imageStrings == rhs.imageStrings
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(imageStrings)
    }
}
