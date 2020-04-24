//
//  PackingViewController+CollectionViews.swift
//  Relentless
//
//  Created by Yanch on 20/4/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import UIKit

extension PackingViewController: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.packagesView {
            return getPackagesViewCount()
        } else if collectionView == self.currentPackageView {
            return getCurrentPackageViewCount()
        } else {
            return getItemsViewCount()
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.packagesView {
            return getPackagesViewCell(indexPath, collectionView)
        } else if collectionView == self.currentPackageView {
            return getCurrentPackageViewCell(collectionView, indexPath)
        } else {
            return getItemsViewCell(collectionView, indexPath)
        }
    }

    func getPackagesViewCount() -> Int {
        1 + (packages?.count ?? 0)
    }

    func getCurrentPackageViewCount() -> Int {
        currentPackageItems?.count ?? 0
    }

    func getItemsViewCount() -> Int {
        guard let currentCategory = currentCategory else {
            return 0
        }
        return items?[currentCategory]?.count ?? 0
    }

    func getCurrentPackageViewCell(_ collectionView: UICollectionView, _ indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: itemIdentifier, for: indexPath)
        if let itemCell = cell as? ItemCell, let item = currentPackageItems?[indexPath.row] {
            itemCell.setItem(item: item)
            itemCell.state = .deselected
            if assemblyMode {
                itemCell.state = selectedParts[indexPath.row]
                    ? .selected
                    : .deselected
//                if selectedParts[indexPath.row] {
//                    itemCell.state = .opaque
//                }
//                if let item = currentPackageItems?[indexPath.row] {
//                    if selectedPartsSet.contains(item) {
//                        itemCell.state = .opaque
//                    } else {
//                        itemCell.state = .translucent
//                    }
//                }
            }
        }
        return cell
    }

    func getAddButton(_ collectionView: UICollectionView, _ indexPath: IndexPath) -> UICollectionViewCell {
        // Add Button at the end.
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: addPackageIdentifier, for: indexPath)
        if let addPackageButton = cell as? AddPackageButton, let avatar = gameController?.player?.profileImage {
            addPackageButton.setAvatar(to: avatar)
        }
        return cell
    }

    func getSinglePackageCell(_ collectionView: UICollectionView, _ indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: packageIdentifier, for: indexPath)

        if let packageCell = cell as? PackageCell, let package = packages?[indexPath.row] {
            packageCell.setPackage(package: package)
            packageCell.active = false
            if package == currentPackage {
                packageCell.active = true
            }
        }
        return cell
    }

    func getPackagesViewCell(_ indexPath: IndexPath, _ collectionView: UICollectionView) -> UICollectionViewCell {
        if indexPath.item == packages?.count {
            return getAddButton(collectionView, indexPath)
        }
        return getSinglePackageCell(collectionView, indexPath)
    }

    func getItemsViewCell(_ collectionView: UICollectionView, _ indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: itemIdentifier, for: indexPath)
        if let currentCategory = currentCategory,
            let itemCell = cell as? ItemCell,
            let item = items?[currentCategory]?[indexPath.item] {
            itemCell.setItem(item: item)
            itemCell.state = .deselected
        }
        return cell
    }
}

extension PackingViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == self.packagesView {
            handlePackagesViewDidSelect(indexPath)
        } else if collectionView == self.currentPackageView {
            handleCurrentItemsViewDidSelect(indexPath)
        } else {
            handleItemViewDidSelect(indexPath)
        }
        reloadCurrentPackage()
    }

    func handleItemViewDidSelect(_ indexPath: IndexPath) {
        guard !assemblyMode else {
            return
        }
        if let currentCategory = currentCategory,
            let item = items?[currentCategory]?[indexPath.item] {
            gameController?.addItem(item: item)
        }
    }

    func handlePackagesViewDidSelect(_ indexPath: IndexPath) {
        if indexPath.item == packages?.count {
            // Add Button at the end
            gameController?.addNewPackage()
            reloadPackages()
            return
        }
        guard let packages = packages else {
            return
        }
        gameController?.openPackage(package: packages[indexPath.item])
    }

    func handleCurrentItemsViewDidSelect(_ indexPath: IndexPath) {
        guard let currentPackageItems = currentPackageItems else {
                        return
                    }
                    if assemblyMode {
                        let item = currentPackageItems[indexPath.item]
                        print(selectedParts[indexPath.item])
                        selectedParts[indexPath.item].toggle()
                        print(selectedParts[indexPath.item])
//                        if selectedPartsSet.contains(item) {
//                            selectedPartsSet.remove(item)
//                        } else {
//                            selectedPartsSet.insert(item)
//                        }
        //                guard let part = currentPackageItems[indexPath.item] as? Part else {
        //                    return
        //                }
        //                if selectedParts.contains(part) {
        //                    selectedParts.remove(part)
        //                } else {
        //                    selectedParts.insert(part)
        //                }
                    } else {
                        gameController?.removeItem(item: currentPackageItems[indexPath.item])
                    }
    }
}

extension PackingViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == self.packagesView {
            return getPackageCellSize(indexPath, collectionView)
        } else {
            return getItemCellSize(collectionView)
        }
    }

    func getItemCellSize(_ collectionView: UICollectionView) -> CGSize {
        let width = collectionView.frame.width / 3.1
        let height = collectionView.frame.height / 2.1
        return CGSize(width: width, height: height)
    }

    func getAddButtonSize(_ collectionView: UICollectionView) -> CGSize {
        //addButton
        let width = collectionView.frame.height - 5
        let height = collectionView.frame.height - 5
        return CGSize(width: width, height: height)
    }

    func getPackageCellSize(_ indexPath: IndexPath, _ collectionView: UICollectionView) -> CGSize {
        if indexPath.item == packages?.count {
            return getAddButtonSize(collectionView)
        }
        let width = collectionView.frame.width / 6 - 5
        let height = collectionView.frame.height - 5
        return CGSize(width: width, height: height)
    }
}
