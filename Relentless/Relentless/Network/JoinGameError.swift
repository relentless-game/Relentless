//
//  JoinGameError.swift
//  Relentless
//
//  Created by Liu Zechu on 18/3/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import Foundation

enum JoinGameError: Error {
    case invalidId
    case nonexistentGameId
    case gameRoomFull
    case gameAlreadyPlaying
}
