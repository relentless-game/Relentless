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
    
    static func decodeOrders(from string: String) -> [Order] {
        
    }
}
