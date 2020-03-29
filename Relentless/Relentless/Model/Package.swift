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
    private var unsortedItems = [Item]() {
        didSet {
            NotificationCenter.default.post(name: .didChangeItemsInPackage, object: nil)
        }
    }

    var items: [Item] {
        unsortedItems.sorted()
    }

    /// packages are sorted when created
    init(creator: String, packageNumber: Int, items: [Item]) {
        self.creator = creator
        self.packageNumber = packageNumber
        self.unsortedItems = items.sorted()
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: PackageKeys.self)
        self.creator = try container.decode(String.self, forKey: .creator)
        self.packageNumber = try container.decode(Int.self, forKey: .packageNumber)
        let itemsObject = try container.decode(ItemFactory.self, forKey: .items)
        self.unsortedItems = itemsObject.items
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: PackageKeys.self)
        try container.encode(creator, forKey: .creator)
        try container.encode(packageNumber, forKey: .packageNumber)
        try container.encode(unsortedItems, forKey: .items)

    }

    func addItem(item: Item) {
        unsortedItems.append(item)
    }

    func removeItem(item: Item) {
        guard let indexOfItem = unsortedItems.firstIndex(of: item) else {
            return
        }
        unsortedItems.remove(at: indexOfItem)
    }

    func sort() -> Package {
        Package(creator: creator, packageNumber: packageNumber, items: unsortedItems.sorted())
    }

    func toString() -> String {
        creator + ": " + String(packageNumber)
    }

    func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleAssembledItemChange),
                                               name: .didChangeAssembledItem, object: nil)
    }

    @objc
    func handleAssembledItemChange() {
        NotificationCenter.default.post(name: .didChangeItemsInPackage, object: nil)
    }
}

extension Package: Equatable {

    public static func == (lhs: Package, rhs: Package) -> Bool {
        lhs.creator == rhs.creator &&
            lhs.packageNumber == rhs.packageNumber &&
            lhs.items == rhs.items
    }

}

enum PackageKeys: CodingKey {
    case creator
    case packageNumber
    case items
}
