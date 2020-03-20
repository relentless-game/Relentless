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
}
