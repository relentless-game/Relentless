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
        let container = try decoder.container(keyedBy: TitledItemKeys.self)
        let superDecoder = try container.superDecoder()
        try super.init(from: superDecoder)
    }

    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: TitledItemKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(category, forKey: .category)
        
        let superEncoder = container.superEncoder()
        try super.encode(to: superEncoder)
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

    override func toDisplayString() -> String {
        Book.bookHeader + name
    }
}
