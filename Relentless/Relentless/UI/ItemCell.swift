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
    @IBOutlet private var selection: UIImageView!

    var state: ItemCellState = .deselected {
        didSet {
            switch state {
            case .deselected:
                selection.isHidden = true
            case .selected:
                selection.isHidden = false
            }
        }
    }

    // swiftlint:disable unused_setter_value
    // unused settervalue in order to override normal cell behaviour
    // causes problems in selection of animated items - animation will stop
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
        for view in background.subviews {
            view.removeFromSuperview()
        }
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
        assert(item.imageRepresentation.imageStrings.count == 1)
        setBackgroundTo(named: item.imageRepresentation.imageStrings[0])
    }

    func setStatefulItemBackgroundFor(item: StatefulItem) {
        assert(item.imageRepresentation.imageStrings.count == 1)
        setBackgroundTo(named: item.imageRepresentation.imageStrings[0])    }

    func setRhythmicItemBackgroundFor(item: RhythmicItem) {
        background.animationDuration = TimeInterval(item.unitDuration)
        var images = [UIImage]()
        for state in item.stateSequence {
            let index = state.stateIndex
            if let frame = UIImage(named: item.imageRepresentation.imageStrings[index]) {
                images.append(frame)
            }
        }
        background.animationImages = images
        background.startAnimating()
    }

    func setAssembledItemBackgroundFor(item: AssembledItem) {
        guard let assembledItemImageRepresentation = item.imageRepresentation as?
            AssembledItemImageRepresentation else {
            return
        }
        setBackgroundTo(named: assembledItemImageRepresentation.imageStrings[0])
        let partsImageStrings = assembledItemImageRepresentation.partsImageStrings
        for part in item.parts {
            let category = part.category
            if let imageRepresentation = partsImageStrings[category] {
                drawPartImageViewFor(part: part, imageRepresentation: imageRepresentation)
            }
        }
    }

    func drawStaticPartImageViewWith(image: UIImage?) {
        let imageView = UIImageView()
        background.addSubview(imageView)
        imageView.image = image
        let square_length = min(self.frame.width, self.frame.height)
        imageView.frame = CGRect(x: 0, y: 0, width: square_length, height: square_length)
    }

    func drawAnimatedPartImageViewWith(images: [UIImage], duration: Int) {
        let imageView = UIImageView()
        background.addSubview(imageView)
        imageView.animationDuration = TimeInterval(duration)
        imageView.animationImages = images
        imageView.startAnimating()
        let square_length = min(self.frame.width, self.frame.height)
        imageView.frame = CGRect(x: 0, y: 0, width: square_length, height: square_length)
    }

    func drawPartImageViewFor(part: Item, imageRepresentation: ImageRepresentation) {
        let imageStrings = imageRepresentation.imageStrings
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
            if let assembledItem = part as? AssembledItem {
                setAssembledItemBackgroundFor(item: assembledItem)
            }
        }
    }
}
