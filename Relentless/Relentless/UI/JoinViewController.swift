//
//  JoinViewController.swift
//  Relentless
//
//  Created by Yanch on 16/3/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import UIKit

class JoinViewController: UIViewController, UITextFieldDelegate {

    static var teamCodeCharacterLimit = 4
    @IBOutlet private var teamCodeTextField: UITextField!
    @IBOutlet private var joinButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        teamCodeTextField.smartInsertDeleteType = UITextSmartInsertDeleteType.no
        teamCodeTextField.delegate = self
    }

    // Code obtained and modified from:
    // https://stackoverflow.com/questions/12944789/allow-only-numbers-for-uitextfield-input
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        // Handle backspace/delete
        guard !string.isEmpty else {
            // Backspace detected, allow text change, no need to process the text any further
            return true
        }

        // Input Validation
        // Prevent invalid character input, if keyboard is numberpad
        if textField.keyboardType == .numberPad {
            // Check for invalid input characters
            if !CharacterSet(charactersIn: "0123456789").isSuperset(of: CharacterSet(charactersIn: string)) {
                // Invalid characters detected, disallow text change
                return false
            }
        }

        // Length Processing
        // Need to convert the NSRange to a Swift-appropriate type
        if let text = textField.text, let range = Range(range, in: text) {
            let proposedText = text.replacingCharacters(in: range, with: string)
            // Check proposed text length does not exceed max character count
            guard proposedText.count <= JoinViewController.teamCodeCharacterLimit else {
                // Present alert if pasting text
                if string.count > 1 {
                    // Pasting text, present alert so the user knows what went wrong
//                    presentAlert("Paste failed: Maximum character count exceeded.")
                }

                // Character count exceeded, disallow text change
                return false
            }

            joinButton.isEnabled = (proposedText.count == JoinViewController.teamCodeCharacterLimit)
        }

        // Allow text change
        return true
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "joinGame" {
            let viewController = segue.destination as? LobbyViewController
            guard let gameIdText = teamCodeTextField.text, viewController != nil else {
                return
            }
            // viewController is non-nil
            viewController!.gameId = Int(gameIdText)
        }
    }
}
