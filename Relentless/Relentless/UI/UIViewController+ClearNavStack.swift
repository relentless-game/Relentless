//
//  UIVIewController+ClearNavStack.swift
//  Relentless
//
//  Created by Yanch on 20/3/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import UIKit

/// Allows the removal of previous VCs in the navigation stack.
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
            if let viewController = navigationController?.viewControllers[index] {
                NotificationCenter.default.removeObserver(viewController)
            }
            navigationController?.viewControllers.remove(at: index)
        }
    }
}
