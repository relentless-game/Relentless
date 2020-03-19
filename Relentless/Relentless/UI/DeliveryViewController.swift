//
//  DeliveryViewController.swift
//  Relentless
//
//  Created by Yanch on 20/3/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import UIKit

class DeliveryViewController: UIViewController {
    var gameController: GameController?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(PackageCell())
    }
}
