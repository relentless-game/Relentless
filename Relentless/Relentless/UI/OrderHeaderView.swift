//
//  OrderHeaderView.swift
//  Relentless
//
//  Created by Yanch on 20/3/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import UIKit

class OrderHeaderView: UICollectionReusableView {
    @IBOutlet private var label: UILabel!
    func setLabel(_ text: String) {
        label.text = text
    }
}
