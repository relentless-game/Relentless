//
//  OrdersAdapter.swift
//  Relentless
//
//  Created by Liu Zechu on 15/3/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import Foundation

/// This is a utility class that encodes an array of `Order`s as a `String` to be stored in the cloud,
/// and decodes a `String` back to an array of `Order`s.
class OrdersAdapter {
    // TODO: make use of Codable instead of encoding the attributes
    static func encodeOrders(orders: [Order]) -> String? {
        // convert this array of orders into an array of [itemsString, timeLimitInSeconds],
        // each itemsString representing items in an order.
        var encodedStringArray: [[String]] = []
        for order in orders {
            let items = order.items
            let timeLimit = String(order.timeLimit)
            if let encodedItemsString = ItemsAdapter.encodeItems(items: items) {
                encodedStringArray.append([encodedItemsString, timeLimit])
            }
        }

        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(encodedStringArray)
            let string = String(data: data, encoding: .utf8)
            return string
        } catch {
            return nil
        }
    }

    // TODO: don't hardcode timeLimitInSeconds
    static func decodeOrders(from string: String) -> [Order] {
        guard let data = string.data(using: .utf8) else {
            return []
        }
        let decoder = JSONDecoder()
        // an array of [itemsString, timeLimitInSeconds],
        // each itemsString representing items in an order.
        do {
            let orderStringArray = try decoder.decode([[String]].self, from: data)
            var orders: [Order] = []
            for orderString in orderStringArray {
                let itemsString = orderString[0]
                let timeLimit = Int(orderString[1]) ?? -1
                if let itemsData = itemsString.data(using: .utf8) {
                    let items = try decoder.decode(Items.self, from: itemsData).items
                    let order = Order(items: items, timeLimitInSeconds: timeLimit)
                    orders.append(order)
                }
            }
            return orders
        } catch {
            return []
        }
    }

//    static func encodeOrders(orders: [Order]) -> String? {
//        let encoder = JSONEncoder()
//        do {
//            let data = try encoder.encode(orders)
//            let string = String(data: data, encoding: .utf8)
//            return string
//        } catch {
//            return nil
//        }
//    }
//
//    static func decodeOrders(from string: String) -> [Order] {
//        guard let data = string.data(using: .utf8) else {
//            return []
//        }
//        let decoder = JSONDecoder()
//        do {
//            let decodedOrders = try decoder.decode([Order].self, from: data)
//            return decodedOrders
//        } catch {
//            return []
//        }
//    }

}
