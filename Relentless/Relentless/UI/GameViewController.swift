//
//  GameViewController.swift
//  Relentless
//
//  Created by Yanch on 17/3/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import UIKit

class GameViewController: UIViewController {
    var gameController: GameController?

    override func viewDidLoad() {
        super.viewDidLoad()
        addObservers()
    }
    func addObservers() {
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(handleRoundStarted),
                                           name: .didStartRound, object: nil)
    }

    @IBAction private func proceed(_ sender: Any) {
        gameController?.startRound()
    }

    @objc func handleRoundStarted() {
        performSegue(withIdentifier: "startRound", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "startRound" {
            let viewController = segue.destination as? PackingViewController
            viewController?.gameController = gameController
        }
    }
}
