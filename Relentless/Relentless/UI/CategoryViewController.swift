//
//  CategoryViewController.swift
//  Relentless
//
//  Created by Yanch on 21/3/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import UIKit

class CategoryViewController: UIViewController {
    var categories: [Category]?
    var categoryChangeDelegate: CategoryChangeDelegate?
    private let categoryCellIdentifier = "CategoryCell"

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

protocol CategoryChangeDelegate {
    func setCategory(_ category: Category)
}

extension CategoryViewController: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        categories?.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: categoryCellIdentifier, for: indexPath)
        if let categoryCell = cell as? CategoryCell,
            let name = categories?[indexPath.row].toString() {
            categoryCell.setText(to: name)
        }
        return cell
    }
}

extension CategoryViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let categories = categories, let categoryChangeDelegate = categoryChangeDelegate else {
            return
        }
        categoryChangeDelegate.setCategory(categories[indexPath.item])
        dismiss(animated: true, completion: nil)
    }
}

class CategoryCell: UICollectionViewCell {
    @IBOutlet private var textLabel: UILabel!

    func setText(to text: String) {
        textLabel.text = text
    }
}
