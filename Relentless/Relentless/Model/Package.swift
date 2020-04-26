//
//  Package.swift
//  Relentless
//
//  Created by Liu Zechu on 13/3/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import Foundation

/// Represents a package of items which the player can send to other players or use to fulfill an order.
class Package: Codable {
    let creator: String /// user name of the player that created this package
    let creatorAvatar: PlayerAvatar /// avatar of creator
    let packageNumber: Int
    private var unsortedItems = [Item]() {
        didSet {
            NotificationCenter.default.post(name: .didChangeItemsInPackage, object: nil)
        }
    }

    var items: [Item] {
        unsortedItems.sorted()
    }
    var itemsLimit: Int?

    /// packages are sorted when created
    init(creator: String, creatorAvatar: PlayerAvatar, packageNumber: Int, items: [Item], itemsLimit: Int?) {
        self.creator = creator
        self.creatorAvatar = creatorAvatar
        self.packageNumber = packageNumber
        self.unsortedItems = items.sorted()
        self.itemsLimit = itemsLimit
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: PackageKeys.self)
        self.creator = try container.decode(String.self, forKey: .creator)
        self.creatorAvatar = try container.decode(PlayerAvatar.self, forKey: .creatorAvatar)
        self.packageNumber = try container.decode(Int.self, forKey: .packageNumber)
        self.itemsLimit = try container.decode(Int?.self, forKey: .itemsLimit)
        let itemsObject = try container.decode(ItemFactory.self, forKey: .items)
        self.unsortedItems = itemsObject.items
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: PackageKeys.self)
        try container.encode(creator, forKey: .creator)
        try container.encode(creatorAvatar, forKey: .creatorAvatar)
        try container.encode(packageNumber, forKey: .packageNumber)
        let itemFactoryWrapper = ItemFactory(items: unsortedItems)
        try container.encode(itemFactoryWrapper, forKey: .items)
        try container.encode(itemsLimit, forKey: .itemsLimit)
    }

    func addItem(item: Item) {
        if let limit = itemsLimit {
            guard items.count < limit else {
                NotificationCenter.default.post(name: .didItemLimitReachedInPackage, object: nil)
                return
            }
        }
        unsortedItems.append(item)
    }

    func removeItem(item: Item) {
        guard let indexOfItem = unsortedItems.firstIndex(of: item) else {
            return
        }
        unsortedItems.remove(at: indexOfItem)
    }

    func sort() -> Package {
        Package(creator: creator, creatorAvatar: creatorAvatar,
                packageNumber: packageNumber, items: unsortedItems.sorted(), itemsLimit: itemsLimit)
    }

    func toString() -> String {
        guard let itemsLimit = itemsLimit else {
            return creator + ": " + String(packageNumber)
        }
        return creator + ": " + String(packageNumber) + " [" + String(itemsLimit) + "]"
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
    case creatorAvatar
    case packageNumber
    case items
    case itemsLimit
}
