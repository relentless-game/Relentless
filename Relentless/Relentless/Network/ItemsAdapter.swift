//
//  ItemsAdapter.swift
//  Relentless
//
//  Created by Liu Zechu on 15/3/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import Foundation

/// This is a utility class that encodes an array of `Item`s as a `String` to be stored in the cloud,
/// and decodes a `String` back to an array of `Item`s.
class ItemsAdapter {
    static func encodeItems(items: [Item]) -> String? {
        let encoder = JSONEncoder()
        do {
            let itemsWrapper = Items(items: items)
            let data = try encoder.encode(itemsWrapper)
            let string = String(data: data, encoding: .utf8)
            
            return string
        } catch {
            return nil
        }
    }
    
    static func decodeItems(from string: String) -> [Item] {
        let decoder = JSONDecoder()
        guard let data = string.data(using: .utf8) else {
            return []
        }
        
        do {
            //let decodedItems = try decoder.decode([Item].self, from: data)
            
            print("BEFORE DECODE")
            let decodedItems = try decoder.decode(Items.self, from: data)
            for item in decodedItems.items {
                print(item.toString())
            }
            
            print("decoded items are \(decodedItems)")
            /////////TEST
            for item in decodedItems.items {
                print("item:")
                print((item as? Item)?.toString())
                print((item as? Book)?.toString())
                print((item as? Magazine)?.toString())
                print((item as? TitledItem)?.toString())
            }
            ////////TEST
            
            // return decodedItems
            return decodedItems.items
        } catch let error as Error {
            print(error.localizedDescription)
            return []
        }
    }
}
