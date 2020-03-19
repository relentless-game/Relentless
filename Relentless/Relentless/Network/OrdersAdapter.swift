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
    static func encodeOrders(orders: [Order]) -> String? {
        // convert this array of orders into an array of strings, each string representing items in an order.
        var encodedStringArray: [String] = []
        for order in orders {
            let items = order.items
            if let encodedItemsString = ItemsAdapter.encodeItems(items: items) {
                encodedStringArray.append(encodedItemsString)
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
    
    // TODO: don't hardcode `timeLimitInSeconds`
    static func decodeOrders(from string: String) -> [Order] {
        guard let data = string.data(using: .utf8) else {
            return []
        }
        let decoder = JSONDecoder()
        // An array of strings, each string representing items in an order
        do {
            let orderStringArray = try decoder.decode([String].self, from: data)
            var orders: [Order] = []
            for itemsString in orderStringArray {
                if let itemsData = itemsString.data(using: .utf8) {
                    let items = try decoder.decode([Item].self, from: itemsData)
                    let order = Order(items: items, timeLimitInSeconds: 30)
                    orders.append(order)
                }
            }
            return orders
        } catch {
            return []
        }
    }
}
