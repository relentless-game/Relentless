//
//  Order.swift
//  Relentless
//
//  Created by Chow Yi Yin on 14/3/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import Foundation

class Order: Hashable, Codable {
    static var MAX_NUMBER_OF_ITEMS = 10

    var items: [Item]
    var timer: Timer?
    var timeLimit: Int {
        didSet {
            timeLeft = timeLimit
        }
    }
    var timeLeft: Int {
        didSet {
            NotificationCenter.default.post(name: .didTimeUpdateInOrder, object: nil)
        }
    }

    // Float from 0 to 1
    var timeRatio: Float {
        Float(timeLeft) / Float(timeLimit)
    }
    
    var hasStarted: Bool = false

    init(items: [Item], timeLimitInSeconds: Int) {
        self.items = items.sorted()
        self.timeLimit = timeLimitInSeconds
        self.timeLeft = timeLimitInSeconds
    }

    enum OrderKeys: CodingKey {
        case items
        case timeLimit
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: OrderKeys.self)
        let itemsWrapper = try container.decode(ItemFactory.self, forKey: .items)
        self.items = itemsWrapper.items
        self.timeLimit = try container.decode(Int.self, forKey: .timeLimit)
        self.timeLeft = self.timeLimit
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: OrderKeys.self)
        let itemsWrapper = ItemFactory(items: items)
        try container.encode(itemsWrapper, forKey: .items)
        try container.encode(timeLimit, forKey: .timeLimit)
    }

    func startOrder() {
        hasStarted = true
        self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimeLeft),
                                          userInfo: nil, repeats: true)
    }

    func stopTimer() {
        self.timer?.invalidate()
    }

    func resumeTimer() {
        self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimeLeft),
                                          userInfo: nil, repeats: true)
    }

    /// Returns true if package matches items in order
    func checkPackage(package: Package) -> Bool {
        package.items == items
    }

    /// Returns number of differences between the items in the package and the items in the order
    func getNumberOfDifferences(with package: Package) -> Int {
        let orderItems = self.items
        let packageItems = package.items
        if orderItems.count > packageItems.count {
            return getNumberOfDifferences(arrayWithFewerItems: packageItems,
                                          arrayWithMoreItems: orderItems)
        } else {
            return getNumberOfDifferences(arrayWithFewerItems: orderItems,
                                          arrayWithMoreItems: packageItems)
        }
    }

    func getNumberOfDifferences(arrayWithFewerItems: [Item], arrayWithMoreItems: [Item]) -> Int {
        var numberFulfilled = 0
        var smallerArray = arrayWithFewerItems
        for item in arrayWithMoreItems where smallerArray.contains(item) {
            numberFulfilled += 1
            guard let indexOfItem = smallerArray.firstIndex(of: item) else {
                continue
            }
            // duplicates of the same item should not increment number fulfilled and
            // should be removed once it has been counted once
            smallerArray.remove(at: indexOfItem)
        }
        return arrayWithMoreItems.count - numberFulfilled
    }

    @objc
    func updateTimeLeft() {
        timeLeft -= 1
        if timeLeft == 0 {
            handleTimeOut()
        }
    }

    func handleTimeOut() {
        NotificationCenter.default.post(name: .didTimeOutInOrder, object: nil)
        stopTimer()
    }

    func containsAssembledItem() -> Bool {
        !(items.compactMap { $0 as? AssembledItem }.isEmpty)
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
