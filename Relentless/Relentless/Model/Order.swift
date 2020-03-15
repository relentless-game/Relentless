//
//  Order.swift
//  Relentless
//
//  Created by Chow Yi Yin on 14/3/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import Foundation

class Order: Hashable {
    static var MAX_NUMBER_OF_ITEMS = 10

    var items: [Item]
    var timer: Timer
    var timeLimit: Int
    var timeLeft: Int

    init(items: [Item], timeLimitInSeconds: Int) {
        self.items = items.sorted()
        self.timeLimit = timeLimitInSeconds
        self.timeLeft = timeLimitInSeconds
        self.timer = Timer()
    }

    func startOrder() {
        self.timer = Timer(timeInterval: TimeInterval(timeLimit), target: self,
                           selector: #selector(updateTimeLeft), userInfo: nil, repeats: false)
    }

    /// Returns true if package matches items in order
    func checkPackage(package: Package) -> Bool {
        let sortedPackage = package.sort()
        return sortedPackage.items == items
    }

    /// Returns number of differences between the items in the package and the items in the order
    func getNumberOfDifferences(with package: Package) -> Int {
        items.count - zip(items, package.items).filter { $0.0 == $0.1 }.count
    }

    @objc func updateTimeLeft() {
        timeLeft -= 1
    }

}

extension Order {
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(items)
        hasher.combine(timer)
        hasher.combine(timeLimit)
    }

    static func == (lhs: Order, rhs: Order) -> Bool {
        lhs.items == rhs.items &&
            lhs.timeLimit == rhs.timeLimit
    }
}
