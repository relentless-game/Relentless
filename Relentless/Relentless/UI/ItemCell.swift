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

    static let bookImage = UIImage(named: "book.png")
    static let magazineImage = UIImage(named: "magazine.png")
    static let unlitRobotImage = UIImage(named: "robot_lit.png")
    static let litRobotImage = UIImage(named: "robot_unlit.png")
    static let carBatteryAAImage = UIImage(named: "toycar_battery_AA.png")
    static let carBatteryDImage = UIImage(named: "toycar_battery_D.png")
    static let carBatteryPP3Image = UIImage(named: "toycar_battery_PP3.png")
    static let carBodyRedImage = UIImage(named: "toycar_body_red.png")
    static let carBodyGreenImage = UIImage(named: "toycar_body_green.png")
    static let carBodyBlueImage = UIImage(named: "toycar_body_blue.png")
    static let carWheelCircleImage = UIImage(named: "toycar_wheel_circle.png")
    static let carWheelSquareImage = UIImage(named: "toycar_wheel_square.png")
    static let carWheelTriangleImage = UIImage(named: "toycar_wheel_triangle.png")

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
            setBookBackgroundFor(item: item)
        case .magazine:
            setMagazineBackgroundFor(item: item)
        case .robot:
            setRobotBackgroundFor(item: item)
        case .toyCar:
            setToyCarBackgroundFor(item: item)
        case .wheel:
            setToyCarWheelBackgroundFor(item: item)
        case .battery:
            setToyCarBatteryBackgroundFor(item: item)
        case .carBody:
            setToyCarBodyBackgroundFor(item: item)
        }
    }

    func setBookBackgroundFor(item: Item) {
        background.image = ItemCell.bookImage
    }

    func setMagazineBackgroundFor(item: Item) {
        background.image = ItemCell.magazineImage
    }

    func setRobotBackgroundFor(item: Item) {
        guard let litRobotImage = ItemCell.litRobotImage,
            let unlitRobotImage = ItemCell.unlitRobotImage else {
                return
        }
        if let robot = item as? RhythmicItem {
            background.animationDuration = TimeInterval(robot.unitDuration)
            var images = [UIImage]()
            for state in robot.stateSequence {
                if state == .lit {
                    images.append(litRobotImage)
                } else if state == .unlit {
                    images.append(unlitRobotImage)
                }
            }
            background.animationImages = images
            background.startAnimating()
        }
    }

    func setToyCarBackgroundFor(item: Item) {
//        if let car = item as? Part {
//            switch car.partType {
//            case .toyCarBattery:
//                if let battery = car as? ToyCarBattery {
//                    setToyCarBatteryBackgroundFor(battery: battery)
//                }
//
//            case .toyCarBody:
//                if let body = car as? ToyCarBody {
//                    setToyCarBodyBackgroundFor(body: body)
//                }
//
//            case .toyCarWheel:
//                if let wheel = car as? ToyCarWheel {
//                    setToyCarWheelBackgroundFor(wheel: wheel)
//                }
//
//            case .partContainer:
//                assert(false)
//            }
//        }
//        if let car = item as? ToyCar {
            setToyCarWholeBackgroundFor(item: item)
//        }
    }

    func setToyCarWholeBackgroundFor(item: Item) {
        if item.category != Category.toyCar {
            return
        }
        guard let car = item as? AssembledItem else {
            return
        }
        let imageString = car.imageString
        background.image = UIImage(named: imageString)
    }

    func setToyCarBatteryBackgroundFor(item: Item) {
//        switch battery.label {
//        case .aa:
//            background.image = ItemCell.carBatteryAAImage
//        case .d:
//            background.image = ItemCell.carBatteryDImage
//        case .pp3:
            background.image = ItemCell.carBatteryPP3Image
//        }
    }

    func setToyCarBodyBackgroundFor(item: Item) {
//        switch body.colour {
//        case .red:
//            background.image = ItemCell.carBodyRedImage
//        case .green:
//            background.image = ItemCell.carBodyGreenImage
//        case .blue:
            background.image = ItemCell.carBodyBlueImage
//        }
    }
    
    func setToyCarWheelBackgroundFor(item: Item) {
//        switch wheel.shape {
//        case .circle:
//            background.image = ItemCell.carWheelCircleImage
//        case .square:
//            background.image = ItemCell.carWheelSquareImage
//        case .triangle:
            background.image = ItemCell.carWheelTriangleImage
//        }
    }
}
