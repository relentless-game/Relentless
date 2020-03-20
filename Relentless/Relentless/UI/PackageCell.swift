//
//  PackageCell.swift
//  Relentless
//
//  Created by Yanch on 20/3/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import UIKit

class PackageCell: UICollectionViewCell {
    @IBOutlet fileprivate var textLabel: UILabel!
    var package: Package!

    func setPackage(package: Package) {
        textLabel.text = package.toString()
        self.package = package
    }
}
