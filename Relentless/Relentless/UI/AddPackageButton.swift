//
//  AddPackageButton.swift
//  Relentless
//
//  Created by Yanch on 4/4/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import UIKit

class AddPackageButton: UICollectionViewCell {
    @IBOutlet private var addImage: UIImageView!

    func setAvatar(to avatar: PlayerAvatar) {
        addImage.image = PlayerImageHelper.getAddImage(for: avatar)
    }
}
