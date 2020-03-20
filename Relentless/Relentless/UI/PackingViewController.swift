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

    @IBOutlet private var packagesView: UICollectionView!
    @IBOutlet private var itemsView: UICollectionView!
    @IBOutlet private var currentPackageView: UICollectionView!
    @IBOutlet private var satisfactionBar: UIProgressView!

    // items will be updated when the category is changed
    var items: [Item]?
    var packages: [Package]?
    var currentPackageItems: [Item]?
    private let itemIdentifier = "ItemCell"
    private let packageIdentifier = "PackageCell"

    override func viewDidLoad() {
        super.viewDidLoad()
        packages = [Package]()
        packages?.append(Package(creator: "hi", packageNumber: 100, items: []))
        items = [Item]()
        items?.append(Book(name: "test"))
        items?.append(Book(name: "woop"))
        initialiseCollectionViews()
        reloadAllViews()
//        packagesView.reloadData()
//        itemsView.reloadData()
//        print(packages.count)
//        let flowLayout = self.playersView.collectionViewLayout as? UICollectionViewFlowLayout
//        itemsCollectionView.delegate = self
//        itemsCollectionView.dataSource = self
//        drawPackages()
    }

    func initialiseCollectionViews() {
        attachLongPressToPackages()
        let itemNib = UINib(nibName: "ItemCell", bundle: nil)
        currentPackageView.register(itemNib, forCellWithReuseIdentifier: itemIdentifier)
        itemsView.register(itemNib, forCellWithReuseIdentifier: itemIdentifier)
    }

    func reloadAllViews() {
        reloadPackages()
        reloadItems()
        reloadCurrentPackage()
    }
    
    func reloadPackages() {
        packagesView.reloadData()
    }

    func reloadItems() {
        itemsView.reloadData()
    }

    func reloadCurrentPackage() {
        currentPackageView.reloadData()
    }

    func updateSatisfactionBar(to value: Float) {
        satisfactionBar.setProgress(value, animated: true)
    }

    func attachLongPressToPackages() {
        let longPressGR = UILongPressGestureRecognizer(target: self,
                                                       action: #selector(handlePackageLongPress(longPressGR:)))
        longPressGR.minimumPressDuration = 0.5
        longPressGR.delaysTouchesBegan = true
        self.packagesView.addGestureRecognizer(longPressGR)
    }

    @objc
    func handlePackageLongPress(longPressGR: UILongPressGestureRecognizer) {
        if longPressGR.state != .ended {
            return
        }

        let point = longPressGR.location(in: self.packagesView)
        let indexPath = self.packagesView.indexPathForItem(at: point)

        if let indexPath = indexPath {
            let cell = self.packagesView.cellForItem(at: indexPath)
            if let packageCell = cell as? PackageCell {
                print(packageCell.package ?? "problem")
            }
        }
    }

//    func drawPackages() {
//        let packages = gameController.playerPackages
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
//       packageStack.addSubview(packageView)
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
//        if recognizer.state == .began {
//            initialPegPoint = view.center
//        }
//        if recognizer.state == .ended {
//            let moveSuccess = movePeg(view: view, to: view.center)
//            if !moveSuccess {
//                view.center = initialPegPoint
//                return
//            }
//        }
//    }

}

extension PackingViewController: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.packagesView {
            return packages?.count ?? 0
        } else if collectionView == self.currentPackageView {
            return currentPackageItems?.count ?? 0
        } else {
            return items?.count ?? 0
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.packagesView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: packageIdentifier, for: indexPath)
            if let packageCell = cell as? PackageCell, let package = packages?[indexPath.row] {
                packageCell.setPackage(package: package)
//                packageCell.segueAction = {
//                    self.performSegue(withIdentifier: "deliverPackage", sender: self)
//                }
//                packageCell.addToSuperview = { (view: UIView) -> Void in
//                    self.view.addSubview(view)
//                    print("added.")
//                }
            }
            return cell
        } else if collectionView == self.currentPackageView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: itemIdentifier, for: indexPath)
            if let itemCell = cell as? ItemCell, let item = currentPackageItems?[indexPath.row] {
                itemCell.setItem(item: item)
            }
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: itemIdentifier, for: indexPath)
            if let itemCell = cell as? ItemCell, let item = items?[indexPath.row] {
                itemCell.setItem(item: item)
            }
            return cell
        }
    }
}

extension PackingViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == self.packagesView {
            guard let packages = packages else {
                return
            }
            gameController?.openPackage(package: packages[indexPath.item])
        } else if collectionView == self.currentPackageView {
            guard let currentPackageItems = currentPackageItems else {
                return
            }
            gameController?.removeItem(item: currentPackageItems[indexPath.item])
        } else {
            guard let items = items else {
                return
            }
            gameController?.addItem(item: items[indexPath.item])
        }
    }
}

extension PackingViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == self.packagesView {
            let width = collectionView.frame.width / 6
            let height = collectionView.frame.height
            return CGSize(width: width, height: height)
        } else {
            let width = collectionView.frame.width / 3 - 20
            let height = collectionView.frame.height / 2 - 20
            return CGSize(width: width, height: height)
        }
    }
}

//extension PackingViewController: UICollectionViewDragDelegate {
//    func collectionView(_ collectionView: UICollectionView,
//    itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
//        let item
//    }
//}

/*
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
*/
