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
    var hasStarted: Bool = false {
        didSet {
            NotificationCenter.default.post(name: .didTimeUpdateInOrder, object: nil)
        }
    }

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
        self.items = try container.decode([Item].self, forKey: .items)
        self.timeLimit = try container.decode(Int.self, forKey: .timeLimit)
        self.timeLeft = self.timeLimit
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: OrderKeys.self)
        try container.encode(items, forKey: .items)
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
        self.timer = Timer(timeInterval: 1, target: self, selector: #selector(updateTimeLeft),
                           userInfo: nil, repeats: false)
    }

    /// Returns true if package matches items in order
    func checkPackage(package: Package) -> Bool {
        package.items == items
    }

    /// Returns number of differences between the items in the package and the items in the order
    func getNumberOfDifferences(with package: Package) -> Int {
        var orderItems = items
        var packageItems = package.items
        for item in items where packageItems.contains(item) {
            guard let packageItemIndex = packageItems.firstIndex(of: item),
                let orderItemIndex = orderItems.firstIndex(of: item) else {
                continue
            }
            packageItems.remove(at: packageItemIndex)
            orderItems.remove(at: orderItemIndex)
        }
        return orderItems.count + packageItems.count
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
