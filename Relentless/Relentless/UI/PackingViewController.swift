//
//  PackingViewController.swift
//  Relentless
//
//  Created by Yanch on 16/3/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import UIKit

class PackingViewController: UIViewController {
    var gameController: GameController?

    // todo: connect to storyboard
    private weak var itemsCollectionView: UICollectionView!
    private weak var categoryButton: UIButton!

    // items will be updated when the category is changed
    var items: [Item]?
    private let reuseIdentifier = "ItemCell"

    override func viewDidLoad() {
        super.viewDidLoad()
        itemsCollectionView.delegate = self
        itemsCollectionView.dataSource = self
    }

}

extension PackingViewController: UICollectionViewDataSource,
UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        items?.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier,
                                                            for: indexPath) as? ItemCell, let items = self.items else {
            return UICollectionViewCell()
        }
        cell.setItem(item: items[indexPath.row])

       return cell
    }

}
