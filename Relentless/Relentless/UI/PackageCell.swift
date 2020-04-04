//
//  PackageCell.swift
//  Relentless
//
//  Created by Yanch on 20/3/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import UIKit

class PackageCell: UICollectionViewCell {
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var packageImage: UIImageView!

    var package: Package!
    var active = false {
        didSet {
            packageImage.alpha = active ? 1.0 : 0.5
        }
    }

    func setPackage(package: Package) {
        textLabel.text = package.toString()
        self.package = package
    }
}
