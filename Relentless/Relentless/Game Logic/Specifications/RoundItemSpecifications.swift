//
//  RoundItemSpecification.swift
//  Relentless
//
//  Created by Chow Yi Yin on 13/4/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import Foundation

/// This class represents a mapping between constituent parts and the assembled item that they form,
/// to be sent by the host to each player at the start of every round.
class RoundItemSpecifications: Codable {
    let partsToAssembledItemCategoryMapping: [[Category]: Category] // categories should be sorted

    init(partsToAssembledItemCategoryMapping: [[Category]: Category]) {
        self.partsToAssembledItemCategoryMapping = partsToAssembledItemCategoryMapping
    }
    
    func encodeToString() -> String? {
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(self)
            let string = String(data: data, encoding: .utf8)
            return string
        } catch {
            return nil
        }
    }
    
    static func decodeFromString(string: String) -> RoundItemSpecifications? {
        guard let data = string.data(using: .utf8) else {
            return nil
        }
        
        let decoder = JSONDecoder()
        do {
            let roundItemSpecs = try decoder.decode(RoundItemSpecifications.self, from: data)
            return roundItemSpecs
        } catch {
            return nil
        }
    }
}
