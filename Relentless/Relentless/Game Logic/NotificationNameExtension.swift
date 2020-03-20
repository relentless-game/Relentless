//
//  NotificationNameExtension.swift
//  Relentless
//
//  Created by Liu Zechu on 18/3/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import Foundation

extension Notification.Name {
    static let didCreateGame = Notification.Name("didCreateGame")
    static let didJoinGame = Notification.Name("didJoinGame")
    static let newPlayerDidJoin = Notification.Name("newPlayerDidJoin")
    static let didStartGame = Notification.Name("didStartGame")
    static let didStartRound = Notification.Name("didStartRound")
    static let didEndGame = Notification.Name("didEndGame")
    static let didEndRound = Notification.Name("didEndRound")
    static let didEndGamePrematurely = Notification.Name("didEndGamePrematurely")
    static let didReceiveGameId = Notification.Name("didReceiveGameId")
    static let invalidGameId = Notification.Name("invalidGameId")
    static let gameAlreadyPlaying = Notification.Name("gameAlreadyPlaying")
    static let gameRoomFull = Notification.Name("gameRoomFull")
    static let didChangePackagesInModel = Notification.Name("didChangePackagesInModel")
    static let didChangeItemsInPackage = Notification.Name("didChangeItemsInPackage")
    static let didChangeItemsInModel = Notification.Name("didChangeItemsInModel")
    static let didChangeItems = Notification.Name("didChangeItems")
    static let didChangePackages = Notification.Name("didChangePackages")
}
