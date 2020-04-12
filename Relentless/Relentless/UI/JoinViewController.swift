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
    var gameController: GameController?
    var userId: String?
    var gameId: Int?
    weak var delegate = UIApplication.shared.delegate as? AppDelegate

    override func viewDidLoad() {
        super.viewDidLoad()
        teamCodeTextField.smartInsertDeleteType = UITextSmartInsertDeleteType.no
        teamCodeTextField.delegate = self
        initUserId()
        if let userId = self.userId {
            // Game parameters should be taken from the game host
            gameController = GameControllerManager(userId: userId, gameParameters: nil)
        }
        addObservers()
    }
    
    func initUserId() {
        if let delegate = delegate {
            userId = delegate.userId
        }
    }

    func addObservers() {
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
    
    func removeObservers() {
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

    @IBAction private func tryJoinGame(_ sender: Any) {
        if let text = teamCodeTextField.text, let gameId = Int(text) {
            self.gameId = gameId
            // TODO: how do we decide default avatar?
            _ = gameController?.joinGame(gameId: gameId, userName: "", avatar: .red)
        }
    }

    @objc func handleJoinSuccess() {
        performSegue(withIdentifier: "joinGame", sender: self)
    }

    @objc func handleGameRoomFull() {
        let maxNumOfPlayers = GameParameters.numOfPlayersRange.upperBound
        let alert = createAlert(title: "Sorry.",
                                message: "The team is already full. There is a maximum of "
                                    + String(maxNumOfPlayers) + " players.",
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

    func createAlert(title: String, message: String, action: String) -> UIAlertController {
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
