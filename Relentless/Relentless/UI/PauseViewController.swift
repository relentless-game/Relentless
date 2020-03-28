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
    private var countDown = 30

    override func viewDidLoad() {
        super.viewDidLoad()
        //addObservers()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleRoundResumed),
                                               name: .didResumeRound, object: nil)
        _ = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { _ in
            self.textLabel.text = String(self.countDown)
            self.countDown -= 1
        })
    }
    
    @objc func handleRoundResumed() {
        performSegue(withIdentifier: "resumeGame", sender: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
}
