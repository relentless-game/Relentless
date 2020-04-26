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
    
    static func encodePackage(package: Package) -> String? {
        let encoder = JSONEncoder()
        do {
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
            let decodedPackage = try decoder.decode(Package.self, from: data)
            return decodedPackage
        } catch {
            return nil
        }
    }
}
