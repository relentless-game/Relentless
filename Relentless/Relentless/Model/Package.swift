//
//  Package.swift
//  Relentless
//
//  Created by Liu Zechu on 13/3/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import Foundation

class Package: Codable {
    let creator: String /// user name of the player that created this package
    let packageNumber: Int
    var items = [Item]()

    init(creator: String, packageNumber: Int, items: [Item]) {
        self.creator = creator
        self.packageNumber = packageNumber
        self.items = items
    }

    func addItem(item: Item) {
        items.append(item)
    }

    func deleteItem(item: Item) {
        guard let indexOfItem = items.firstIndex(of: item) else {
            return
        }
        items.remove(at: indexOfItem)
    }

    func sort() -> Package {
        Package(creator: creator, packageNumber: packageNumber, items: items.sorted())
    }
}

extension Package: Equatable {
    public static func == (lhs: Package, rhs: Package) -> Bool {
        lhs.creator == rhs.creator &&
            lhs.packageNumber == rhs.packageNumber &&
            lhs.items == rhs.items
    }
}
