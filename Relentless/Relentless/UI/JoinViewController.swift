//
//  JoinViewController.swift
//  Relentless
//
//  Created by Yanch on 16/3/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import UIKit

/// Controls the joining of games with a game ID.
class JoinViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet private var teamCodeTextField: UITextField!
    @IBOutlet private var joinButton: UIButton!

    /// Represents the number of characters in a team code.
    static var teamCodeCharacterLimit = 4
    var gameController: GameController?
    private var userId: String?
    private var gameId: Int?
    private weak var delegate = UIApplication.shared.delegate as? AppDelegate

    override func viewDidLoad() {
        super.viewDidLoad()
        initTeamCodeTextField()
        initUserId()
        if let userId = self.userId {
            gameController = GameControllerManager(userId: userId)
        }
        addObservers()
    }

    private func initTeamCodeTextField() {
        teamCodeTextField.smartInsertDeleteType = UITextSmartInsertDeleteType.no
        teamCodeTextField.delegate = self
    }
    
    private func initUserId() {
        if let delegate = delegate {
            userId = delegate.userId
        }
    }

    private func addObservers() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleJoinSuccess),
                                               name: .didJoinGame, object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleInvalidGameId),
                                               name: .invalidGameId, object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleGameRoomFull),
                                               name: .gameRoomFull, object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleGameAlreadyPlaying),
                                               name: .gameAlreadyPlaying, object: nil)
    }
    
    private func removeObservers() {
        NotificationCenter.default.removeObserver(self, name: .didJoinGame, object: nil)
        NotificationCenter.default.removeObserver(self, name: .invalidGameId, object: nil)
        NotificationCenter.default.removeObserver(self, name: .gameRoomFull, object: nil)
        NotificationCenter.default.removeObserver(self, name: .gameAlreadyPlaying, object: nil)
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
                // Character count exceeded, disallow text change
                return false
            }
            joinButton.isEnabled = (proposedText.count == JoinViewController.teamCodeCharacterLimit)
        }

        // Allow text change
        return true
    }

    // On Join Button press, tries to join the game with room ID.
    @IBAction private func tryJoinGame(_ sender: Any) {
        if let text = teamCodeTextField.text, let gameId = Int(text) {
            self.gameId = gameId
            // By default, players begin with a blank username and the red avatar.
            _ = gameController?.joinGame(gameId: gameId, userName: "", avatar: .red)
        }
    }

    @objc private func handleJoinSuccess() {
        performSegue(withIdentifier: "joinGame", sender: self)
    }

    @objc private func handleGameRoomFull() {
        let message = "The team is already full."
        let alert = createAlert(title: "Sorry.",
                                message: message,
                                action: "Ok.")
        self.present(alert, animated: true, completion: nil)
    }

    @objc func handleInvalidGameId() {
        let alert = createAlert(title: "Sorry.",
                                message: "The team code is invalid. Are you sure you keyed in the right code?",
                                action: "Ok.")
        self.present(alert, animated: true, completion: nil)
    }

    @objc func handleGameAlreadyPlaying() {
        let alert = createAlert(title: "Sorry.",
                                message: "You cannot join a team once the game has already started.",
                                action: "Ok.")
        self.present(alert, animated: true, completion: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        removeObservers()
        removeAllPreviousViewControllers()
        if segue.identifier == "joinGame" {
            if let viewController = segue.destination as? LobbyViewController {
                viewController.gameController = self.gameController
                viewController.gameId = self.gameId
            }
        }
    }

    // Helper function for simple alerts with one dismissal action.
    private func createAlert(title: String, message: String, action: String) -> UIAlertController {
        let controller = UIAlertController(title: String(title),
                                           message: String(message),
                                           preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: String(action),
                                          style: .default)
        controller.addAction(defaultAction)
        return controller
    }
    
    @IBAction private func handleBackButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
