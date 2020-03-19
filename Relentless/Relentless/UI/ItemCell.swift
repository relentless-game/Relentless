//
//  ItemCellViewController.swift
//  Relentless
//
//  Created by Chow Yi Yin on 19/3/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import Foundation
import UIKit

class ItemCell: UICollectionViewCell {
    // todo: change to UIImageView
    var itemLabel: UILabel!

    func setItem(item: Item) {
        itemLabel.text = item.toString()
    }
}
