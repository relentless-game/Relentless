//
//  HouseCell.swift
//  Relentless
//
//  Created by Yanch on 20/3/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import UIKit

class HouseCell: UICollectionViewCell {
    // todo: change to UIImageView
    var house: House!
    @IBOutlet private var icon: UIImageView!
    @IBOutlet private var progressView: UIProgressView!

    private func attachOrderListener() {
        NotificationCenter.default.addObserver(self,
                                                selector: #selector(handleOrderChanged),
                                                name: .didChangeOrders, object: nil)
    }

    @objc func handleOrderChanged() {
        if let timeRatio = house.activeOrders.first?.timeRatio {
            progressView.setProgress(timeRatio, animated: true)
        }
    }

    func setHouse(house: House) {
        self.house = house
        if !house.activeOrders.isEmpty {
            icon.backgroundColor = UIColor.orange
            progressView.isHidden = false
            attachOrderListener()
        } else {
            icon.backgroundColor = UIColor.black
            progressView.isHidden = true
        }
    }
}
