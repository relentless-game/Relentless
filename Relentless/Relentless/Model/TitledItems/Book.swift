//
//  Book.swift
//  Relentless
//
//  Created by Chow Yi Yin on 14/3/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import Foundation

class Book: TitledItem {
    static let category = Category.book
    static let bookHeader = "Book: "

    init(name: String) {
        super.init(name: name, category: Book.category)
    }
    
    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
    }

    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
    }

    override func equals(other: Item) -> Bool {
        guard let otherBook = other as? Book else {
            return false
        }
        return otherBook.name == self.name
    }

    override func toString() -> String {
        Book.bookHeader + name
    }
}
