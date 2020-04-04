//
//  SettingsViewController.swift
//  Relentless
//
//  Created by Yi Wai Chow on 4/4/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import Foundation
import UIKit

class SettingsViewController: UIViewController {

    var gameController: GameController?

    @IBOutlet weak var difficultyLevelSlider: UISlider!
    @IBOutlet weak var difficultyLevelLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func sliderValueChanged(_ sender: UISlider) {
        gameController?.gameParameters?.difficultyLevel = sender.value
        difficultyLevelLabel.text = String(format: "%.1f", sender.value)
    }
}
