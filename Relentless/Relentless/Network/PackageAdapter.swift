//
//  PackageAdapter.swift
//  Relentless
//
//  Created by Liu Zechu on 15/3/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import Foundation

/// This is a utility class that encodes a `Package` as a `String` to be stored in the cloud,
/// and decodes a `String` back to a `Package`.
class PackageAdapter {
    
    // TODO: make use of Codable instead of encoding the attributes
    static func encodePackage(package: Package) -> String? {
        let encoder = JSONEncoder()
        do {
//            let creator = package.creator
//            let packageNumber = package.packageNumber
//            let items = ItemFactory(items: package.items)
//
//            let itemsData = try encoder.encode(items)
//            let itemsString = String(data: itemsData, encoding: .utf8) ?? ""
//            let packageStringsArray = [creator, String(packageNumber), itemsString]
//            let encodedData = try encoder.encode(packageStringsArray)
            let encodedData = try encoder.encode(package)
            let encodedString = String(data: encodedData, encoding: .utf8)
            
            return encodedString
        } catch {
            return nil
        }
    }
    
    static func decodePackage(from string: String) -> Package? {
        let decoder = JSONDecoder()
        guard let data = string.data(using: .utf8) else {
            return nil
        }
        do {
//            let decodedPackageStringArray = try decoder.decode([String].self, from: data)
//            let creator = decodedPackageStringArray[0]
//            let packageNumber = Int(decodedPackageStringArray[1]) ?? 0
//            let itemsString = decodedPackageStringArray[2]
//
//            let itemsData = itemsString.data(using: .utf8) ?? Data()
//            let itemsWrapper = try decoder.decode(ItemFactory.self, from: itemsData)
//            let items = itemsWrapper.items
//
//            let decodedPackage = Package(creator: creator, packageNumber: packageNumber, items: items)

            let decodedPackage = try decoder.decode(Package.self, from: data)
            
            return decodedPackage
        } catch {
            return nil
        }
    }
}
