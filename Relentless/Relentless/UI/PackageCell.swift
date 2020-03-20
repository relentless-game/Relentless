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
//    var pan: UIPanGestureRecognizer!
//    var view: UILabel?
    var package: Package!

//    var segueAction : (()->())?
//    var addToSuperview: ((UIView) -> ())?

//    override init(frame: CGRect) {
//      super.init(frame: frame)
//      commonInit()
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//      super.init(coder: aDecoder)
//      commonInit()
//    }
//
//    private func commonInit() {
//      pan = UIPanGestureRecognizer(target: self, action: #selector(onPan(_:)))
//      pan.delegate = self
//      self.addGestureRecognizer(pan)
//    }

//    @objc func onPan(_ pan: UIPanGestureRecognizer) {
//        if pan.state == UIGestureRecognizer.State.began {
//           segueAction?()
//            view = UILabel()
//            if let view = view {
//                view.frame = self.frame
//                view.text = self.textLabel.text
//                view.backgroundColor = UIColor.gray
//                addToSuperview?(view)
//            }
//        }
//        guard let view = view else {
//            return
//        }
//        let translation = pan.translation(in: self)
//        view.center = CGPoint(x: self.center.x + translation.x,
//                              y: self.center.y + translation.y)
//    }

    func setPackage(package: Package) {
        textLabel.text = package.toString()
        self.package = package
    }
}
