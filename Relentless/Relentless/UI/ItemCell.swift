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

    var state: ItemCellState = .opaque {
        didSet {
            switch state {
            case .transparent:
                background.alpha = 0.2
            case .translucent:
                background.alpha = 0.6
            case .opaque:
                background.alpha = 1
            }
        }
    }

    // swiftlint:disable unused_setter_value
    // unused settervalue in order to override normal cell behaviour
    // causes problems in selection of robot - animation will stop
    override var isSelected: Bool {
        set {
        }
        get {
            super.isSelected
        }
    }

    override var isHighlighted: Bool {
        set {
        }
        get {
             super.isHighlighted
        }
    }
    // swiftlint:enable unused_setter_value

    func setItem(item: Item) {
        setTextFor(item: item)
        setBackgroundFor(item: item)
    }

    func setTextFor(item: Item) {
        textLabel.text = item.toString()
    }

    func setBackgroundFor(item: Item) {
        switch item.itemType {
        case .titledItem:
            if let titledItem = item as? TitledItem {
                setTitledItemBackgroundFor(item: titledItem)
            }
        case .statefulItem:
            if let statefulItem = item as? StatefulItem {
                setStatefulItemBackgroundFor(item: statefulItem)
            }
        case .rhythmicItem:
            if let rhythmicItem = item as? RhythmicItem {
                setRhythmicItemBackgroundFor(item: rhythmicItem)
            }
        case .assembledItem:
            if let assembledItem = item as? AssembledItem {
                setAssembledItemBackgroundFor(item: assembledItem)
            }
        }
    }

    func setBackgroundTo(named: String) {
        background.image = UIImage(named: named)
    }

    func setTitledItemBackgroundFor(item: TitledItem) {
        setBackgroundTo(named: item.imageString)
    }

    func setStatefulItemBackgroundFor(item: StatefulItem) {
        setBackgroundTo(named: item.imageString)
    }

    func setRhythmicItemBackgroundFor(item: RhythmicItem) {
        background.animationDuration = TimeInterval(item.unitDuration)
        var images = [UIImage]()
        for state in item.stateSequence {
            let index = state.stateIndex
            if let frame = UIImage(named: item.imageStrings[index]) {
                images.append(frame)
            }
        }
        background.animationImages = images
        background.startAnimating()
    }

    func setAssembledItemBackgroundFor(item: AssembledItem) {
        for view in subviews where view != background && view != textLabel {
            view.removeFromSuperview()
        }
        setBackgroundTo(named: "house.png")
        for part in item.parts {
            let category = part.category
            if let imageStrings = item.partsImageStrings[category] {
                drawPartImageViewFor(part: item, imageStrings: imageStrings)
            }
        }
    }

    func drawStaticPartImageViewWith(image: UIImage?) {
        let imageView = UIImageView()
        self.addSubview(imageView)
        imageView.image = image
        let square_length = min(self.frame.width, self.frame.height)
        imageView.frame = CGRect(x: 0, y: 0, width: square_length, height: square_length)
    }

    func drawAnimatedPartImageViewWith(images: [UIImage], duration: Int) {
        let imageView = UIImageView()
        self.addSubview(imageView)
        imageView.animationDuration = TimeInterval(duration)
        imageView.animationImages = images
        imageView.startAnimating()
        let square_length = min(self.frame.width, self.frame.height)
        imageView.frame = CGRect(x: 0, y: 0, width: square_length, height: square_length)
    }


    func drawPartImageViewFor(part: Item, imageStrings: [String]) {
        switch part.itemType {
        case .titledItem:
            let imageString = imageStrings[0]
            drawStaticPartImageViewWith(image: UIImage(named: imageString))
        case .statefulItem:
            if let statefulItem = part as? StatefulItem {
                let imageString = imageStrings[statefulItem.stateIdentifier]
                drawStaticPartImageViewWith(image: UIImage(named: imageString))
            }
        case .rhythmicItem:
            if let rhythmicItem = part as? RhythmicItem {
                var images = [UIImage]()
                for state in rhythmicItem.stateSequence {
                    let index = state.stateIndex
                    if let frame = UIImage(named: imageStrings[index]) {
                        images.append(frame)
                    }
                }
                drawAnimatedPartImageViewWith(images: images, duration: rhythmicItem.unitDuration)
            }
        case .assembledItem:
            let imageString = imageStrings[0]
            drawStaticPartImageViewWith(image: UIImage(named: imageString))
        }
    }
}
