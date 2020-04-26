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
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(orders)
            let string = String(data: data, encoding: .utf8)
            return string
        } catch {
            return nil
        }
    }

    static func decodeOrders(from string: String) -> [Order] {
        guard let data = string.data(using: .utf8) else {
            return []
        }
        
        let decoder = JSONDecoder()
        do {
            let orders = try decoder.decode([Order].self, from: data)
            return orders
        } catch {
            return []
        }
    }
}
