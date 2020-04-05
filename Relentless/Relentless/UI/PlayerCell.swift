//
//  PlayerCell.swift
//  Relentless
//
//  Created by Yanch on 4/4/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import UIKit

class PlayerCell: UICollectionViewCell {
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var icon: UIImageView!

    func setPlayer(to player: Player) {
        textLabel.text = player.userName
        icon.image = PlayerImageHelper.getAvatarImage(for: player.profileImage)
    }
}
