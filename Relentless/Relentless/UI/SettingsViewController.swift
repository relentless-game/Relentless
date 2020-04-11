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

    @IBOutlet private var difficultyLevelSlider: UISlider!
    @IBOutlet private var difficultyLevelLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        difficultyLevelSlider.value = gameController?.gameParameters?.difficultyLevel ?? 1.0
        difficultyLevelLabel.text = String(format: "%.1f", difficultyLevelSlider.value)
    }

    @IBAction private func sliderValueChanged(_ sender: UISlider) {
        gameController?.gameParameters?.difficultyLevel = sender.value
        difficultyLevelLabel.text = String(format: "%.1f", sender.value)
    }

    @IBAction private func handleBackButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
