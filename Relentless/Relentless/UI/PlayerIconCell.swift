//
//  PlayerIconCell.swift
//  Relentless
//
//  Created by Yanch on 26/4/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import UIKit

/// Represents a player in the DeliveryVC.
class PlayerIconCell: UICollectionViewCell {
    var player: Player!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var icon: UIImageView!

    /// Sets the player for this cell to display. Updates the display upon setting.
    func setPlayer(player: Player) {
        self.player = player
        textLabel.text = player.userName
        icon.image = PlayerImageHelper.getAvatarImage(for: player.profileImage)
    }
}
