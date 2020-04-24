//
//  StringExtension.swift
//  Relentless
//
//  Created by Yi Wai Chow on 12/4/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import Foundation
import SwiftTryCatch

extension String {

    var expression: NSExpression? {
        var expression: NSExpression?
        SwiftTryCatch.try({
            expression = NSExpression(format: self)
        }, catch: { error in
            print("\(error?.description ?? "No error description available")")
            expression = nil
        }, finally: {
            // do nothing
        })
        return expression
    }
    
}
