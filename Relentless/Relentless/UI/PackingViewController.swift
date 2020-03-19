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
//    private weak var itemsCollectionView: UICollectionView!
//    private weak var categoryButton: UIButton!

    // items will be updated when the category is changed
    var items: [Item]?
    private let reuseIdentifier = "ItemCell"

    override func viewDidLoad() {
        super.viewDidLoad()
//        itemsCollectionView.delegate = self
//        itemsCollectionView.dataSource = self
//        drawPackages()
    }

//    func drawPackages() {
////        let packages = gameController.playerPackages
//        var packages = [Package]()
//        packages.append(Package(creator: "hi", packageNumber: 100, items: []))
//        for package in packages {
//            drawPackage(package)
//        }
//    }

//    func drawPackage(_ package: Package) {
//        let packageView = UILabel()
//        packageView.text = String(package.packageNumber)
//        packageView.isUserInteractionEnabled = true
//        attachPackageTouchHandlers(to: packageView)
////        packageStack.addSubview(packageView)
//    }
//
//    func attachPackageTouchHandlers(to view: UIView) {
//        let pan = UIPanGestureRecognizer(target: self, action: #selector(self.handlePackageDrag))
//        view.addGestureRecognizer(pan)
//    }
//
//    @objc func handlePackageDrag(_ recognizer: UIPanGestureRecognizer) {
//        let translation = recognizer.translation(in: self.view)
//        view.center = CGPoint(x: view.center.x + translation.x,
//                              y: view.center.y + translation.y)
//
//        recognizer.setTranslation(CGPoint.zero, in: self.view)
//
////        if recognizer.state == .began {
////            initialPegPoint = view.center
////        }
//        if recognizer.state == .ended {
////            let moveSuccess = movePeg(view: view, to: view.center)
////            if !moveSuccess {
////                view.center = initialPegPoint
////                return
////            }
//        }
//    }

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

class PackageWrapper {
    let package: Package
    let view: UILabel

    init(package: Package) {
        self.package = package
        self.view = UILabel()
        view.text = String(package.packageNumber)
    }
}
