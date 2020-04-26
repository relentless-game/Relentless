//
//  HouseCell.swift
//  Relentless
//
//  Created by Yanch on 20/3/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import UIKit

/// Represents a house.
class HouseCell: UICollectionViewCell {
    var house: House!
    @IBOutlet private var icon: UIImageView!
    @IBOutlet private var progressView: UIProgressView!

    private func attachOrderListener() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleOrderChanged),
                                               name: .didChangeOrders, object: nil)
    }

    @objc private func handleOrderChanged() {
        if let timeRatio = house.nearestActiveOrderTimeRatio {
            progressView.setProgress(timeRatio, animated: false)
        }
    }

    /// Sets the house for this cell to display. Updates the display upon setting.
    func setHouse(house: House) {
        self.house = house
        if !house.activeOrders.isEmpty {
            progressView.isHidden = false
            attachOrderListener()
        } else {
            progressView.isHidden = true
        }
    }
}
