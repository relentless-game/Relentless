//
//  UIVIewController+ClearNavStack.swift
//  Relentless
//
//  Created by Yanch on 20/3/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import UIKit

extension UIViewController {
    func removePreviousViewController() {
        guard let count = navigationController?.viewControllers.count else {
            return
        }
        navigationController?.viewControllers.remove(at: count - 2)
    }

    func removeAllPreviousViewControllers() {
        guard let count = navigationController?.viewControllers.count else {
            return
        }
        for index in 0...count - 2 {
            navigationController?.viewControllers.remove(at: index)
        }
    }
}
