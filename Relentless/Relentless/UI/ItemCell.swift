//
//  ItemCellViewController.swift
//  Relentless
//
//  Created by Chow Yi Yin on 19/3/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import UIKit

class ItemCell: UICollectionViewCell {
    // todo: change to UIImageView
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var background: UIImageView!

    static let bookImage = UIImage(named: "book.png")
    static let magazineImage = UIImage(named: "magazine.png")
    static let unlitRobotImage = UIImage(named: "robot_lit.png")
    static let litRobotImage = UIImage(named: "robot_unlit.png")

    func setItem(item: Item) {
        setTextFor(item: item)
        setBackgroundFor(item: item)
    }

    func setTextFor(item: Item) {
        textLabel.text = item.toString()
    }

    func setBackgroundFor(item: Item) {
        switch item.category {
        case .book:
            background.image = ItemCell.bookImage
        case .magazine:
            background.image = ItemCell.magazineImage
        case .bulb:
            background.image = ItemCell.unlitRobotImage
        }
    }
}
