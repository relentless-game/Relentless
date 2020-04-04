//
//  PauseViewController.swift
//  Relentless
//
//  Created by Liu Zechu on 28/3/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import UIKit

class PauseViewController: UIViewController {
    @IBOutlet private var textLabel: UILabel!
    var gameController: GameController?

    override func viewDidLoad() {
        super.viewDidLoad()
        addObservers()
    }
    
    private func addObservers() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateCountDownLabel),
                                               name: .didUpdateCountDown,
                                               object: nil)
    }
    
    @objc private func updateCountDownLabel() {
        let countDown = gameController?.pauseCountDown ?? -1
        self.textLabel.text = String(countDown)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        removeAllPreviousViewControllers()
        if segue.identifier == "resumeGame" {
            let viewController = segue.destination as? PackingViewController
            viewController?.gameController = gameController
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
