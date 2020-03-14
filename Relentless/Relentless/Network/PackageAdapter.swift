//
//  PackageAdapter.swift
//  Relentless
//
//  Created by Liu Zechu on 15/3/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import Foundation

/// This is a utility class that encodes a `Package` as an `NSDictionary` to be stored in the cloud,
/// and decodes an `NSDictionary` back to a `Package`.
class PackageAdapter {
    static func encodePackage(package: Package) -> NSDictionary {
        let creator = package.creator
        let packageNumber = package.packageNumber
        // TODO: encode items
        let items = ["string"]
        
        let result: NSDictionary = [
            "creator": creator,
            "packageNumber": packageNumber,
            "items": items
        ]
        
        return result
    }
    
    static func decodePackageDictionary(dict: NSDictionary) -> Package? {
        guard let creator = dict["creator"] as? String else {
            return nil
        }
        guard let packageNumber = dict["packageNumber"] as? Int else {
            return nil
        }
        // TODO: decode items
        
        return Package(creator: creator, packageNumber: packageNumber, items: [])
    }
}
