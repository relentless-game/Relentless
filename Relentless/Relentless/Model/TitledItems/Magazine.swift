//
//  Magazine.swift
//  Relentless
//
//  Created by Chow Yi Yin on 14/3/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import Foundation

class Magazine: TitledItem {
    static let category = Category.magazine
    static let magazineHeader = "Magazine: "
    
    init(name: String) {
        super.init(name: name, category: Magazine.category)
    }

    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
    }

    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
    }

    override func equals(other: Item) -> Bool {
        guard let otherMagazine = other as? Magazine else {
            return false
        }
        return otherMagazine.name == self.name
    }

    override func toString() -> String {
        Magazine.magazineHeader + name
    }
}
