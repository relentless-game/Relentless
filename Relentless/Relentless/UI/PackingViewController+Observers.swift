//
//  PackingViewController+Observers.swift
//  Relentless
//
//  Created by Yanch on 26/4/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import UIKit

/// This extension deals with the addition and removal of observers.
extension PackingViewController {
    internal func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(reloadAllViews),
                                               name: .didStartRound, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reloadPackages),
                                               name: .didChangePackages, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reloadCurrentPackage),
                                               name: .didChangeItems, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateSatisfactionBar),
                                               name: .didChangeSatisfactionBar, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleRoundEnded),
                                               name: .didEndRound, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleGameEnded),
                                               name: .didEndGame, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleItemLimitReached),
                                               name: .didItemLimitReached, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reloadCurrentPackage),
                                               name: .didChangeOpenPackage, object: nil)
        // The following observers are for the pausing feature
        NotificationCenter.default.addObserver(self, selector: #selector(handleAppMovedToBackground),
                                               name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleAppMovedToForeground),
                                               name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleRoundPaused),
                                               name: .didPauseRound, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleRoundResumed),
                                               name: .didResumeRound, object: nil)
        // To inform player about the result of their delivery
        NotificationCenter.default.addObserver(self, selector: #selector(handleCorrectDelivery),
                                               name: .correctDelivery, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleWrongDelivery),
                                               name: .wrongDelivery, object: nil)
    }

    internal func removeObservers() {
        NotificationCenter.default.removeObserver(self, name: .didStartRound, object: nil)
        NotificationCenter.default.removeObserver(self, name: .didChangePackages, object: nil)
        NotificationCenter.default.removeObserver(self, name: .didChangeItems, object: nil)
        NotificationCenter.default.removeObserver(self, name: .didChangeSatisfactionBar, object: nil)
        NotificationCenter.default.removeObserver(self, name: .didEndRound, object: nil)
        NotificationCenter.default.removeObserver(self, name: .didEndGame, object: nil)
        NotificationCenter.default.removeObserver(self, name: .didChangeOpenPackage, object: nil)
        // The following observers are for the pausing feature
        NotificationCenter.default.removeObserver(self, name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.willEnterForegroundNotification,
                                                  object: nil)
        NotificationCenter.default.removeObserver(self, name: .didPauseRound, object: nil)
        NotificationCenter.default.removeObserver(self, name: .didResumeRound, object: nil)
        // The following observers are to inform player about the result of their delivery
        NotificationCenter.default.removeObserver(self, name: .correctDelivery, object: nil)
        NotificationCenter.default.removeObserver(self, name: .wrongDelivery, object: nil)
    }

    // The following methods are for the pausing feature
    // Called before segue to Game VC at the end of a round
    internal func removeBackgroundObservers() {
        NotificationCenter.default.removeObserver(self,
                                                  name: UIApplication.willResignActiveNotification,
                                                  object: nil)
        NotificationCenter.default.removeObserver(self,
                                                  name: UIApplication.willEnterForegroundNotification,
                                                  object: nil)
        NotificationCenter.default.removeObserver(self,
                                                  name: .didPauseRound,
                                                  object: nil)
        NotificationCenter.default.removeObserver(self,
                                                  name: .didResumeRound,
                                                  object: nil)
    }
}
