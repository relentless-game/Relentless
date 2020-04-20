//
//  StringExtension.swift
//  Relentless
//
//  Created by Yi Wai Chow on 12/4/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import Foundation

extension String {

    var expression: NSExpression {
        // HAVE TO CATCH NSEXCEPTION HERE AND USE (format: self)
        return NSExpression(format: self)
    }
    
}
