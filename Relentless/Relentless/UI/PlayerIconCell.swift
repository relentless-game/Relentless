//
//  PlayerIconCell.swift
//  Relentless
//
//  Created by Yanch on 26/4/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import UIKit

class PlayerIconCell: UICollectionViewCell {
    // todo: change to UIImageView
    var player: Player!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var icon: UIImageView!

    func setPlayer(player: Player) {
        self.player = player
        textLabel.text = player.userName
        icon.image = PlayerImageHelper.getAvatarImage(for: player.profileImage)
    }
}
