//
//  TitleViewController.swift
//  Relentless
//
//  Created by Chow Yi Yin on 5/4/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import Foundation
import UIKit

class TitleViewController: UIViewController {

    @IBAction private func createRoom(_ sender: UIButton) {
        removeAllPreviousViewControllers()
        performSegue(withIdentifier: "createRoom", sender: self)
    }
    
    @IBAction private func joinRoom(_ sender: UIButton) {
        removeAllPreviousViewControllers()
        performSegue(withIdentifier: "joinRoom", sender: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "createRoom" {
            let viewController = segue.destination as? LobbyViewController
            viewController?.gameController = nil
        } else if segue.identifier == "joinRoom" {
            let viewController = segue.destination as? JoinViewController
            viewController?.gameController = nil
        }
    }
}
