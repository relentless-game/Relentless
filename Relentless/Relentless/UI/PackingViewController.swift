//
//  PackingViewController.swift
//  Relentless
//
//  Created by Yanch on 16/3/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import UIKit

/// Displays the player's packages and items. It allows for the creation and modification of packages.
/// From this VC, you can move to DeliveryVC and HousesVC.
class PackingViewController: UIViewController {
    // swiftlint:disable private_outlet
    // Necessary to be accessed in extensions.
    @IBOutlet internal var packagesView: UICollectionView!
    @IBOutlet internal var itemsView: UICollectionView!
    @IBOutlet internal var currentPackageView: UICollectionView!
    // swiftlint:enable private_outlet
    @IBOutlet private var currentPackageLabel: UILabel!
    @IBOutlet private var satisfactionBar: UIProgressView!
    @IBOutlet private var categoryButton: UIButton!
    @IBOutlet private var openBoxImageView: UIImageView!
    @IBOutlet private var assemblingView: UILabel!

    var gameController: GameController?
    private var backgroundTask: UIBackgroundTaskIdentifier = .invalid
    private var endRoundTimer: Timer?
    private var packageForDelivery: Package?

    // This set of variables are used for the collection views.
    // items will be updated when the category is changed
    internal var items: [Category: [Item]]?
    internal var packages: [Package]?
    internal var currentCategory: Category?
    internal var currentPackage: Package?
    internal var currentPackageItems: [Item]?
    internal let categoryIdentifier = "CategoryViewController"
    internal let itemIdentifier = "ItemCell"
    internal let packageIdentifier = "PackageCell"
    internal let addPackageIdentifier = "AddPackageButton"

    internal var assemblyMode = false {
        didSet {
            assemblingView.isHidden = !assemblyMode
        }
    }
    internal var selectedParts = [Bool]()

    override func viewDidLoad() {
        super.viewDidLoad()
        initialiseCollectionViews()
        addObservers()
        reloadAllViews()
        registerBackgroundTask()
    }

    private func initialiseCollectionViews() {
        attachLongPressToPackages()
        let itemNib = UINib(nibName: itemIdentifier, bundle: nil)
        currentPackageView.register(itemNib, forCellWithReuseIdentifier: itemIdentifier)
        itemsView.register(itemNib, forCellWithReuseIdentifier: itemIdentifier)
    }

    @IBAction private func toHouses(_ sender: UIButton) {
        guard let gameStatus = gameController?.gameStatus else {
            return
        }
        let didEndRound = gameStatus.isGamePlaying && !gameStatus.isRoundPlaying && gameStatus.currentRound != 0
        if !didEndRound {
            performSegue(withIdentifier: "toHouses", sender: self)
        } else {
            performSegue(withIdentifier: "endRound", sender: self)
        }
    }

    @objc internal func reloadAllViews() {
        reloadPackages()
        reloadItems()
        reloadCurrentPackage()
        reloadCategoryButton()
        updateSatisfactionBar()
    }
    
    @objc internal func reloadPackages() {
        currentPackage = gameController?.retrieveOpenPackage()
        currentPackageLabel.text = gameController?.openedPackage?.toString()
        reloadOpenBoxView()
        packages = gameController?.playerPackages
        packagesView.reloadData()
    }

    private func reloadOpenBoxView() {
        openBoxImageView.isHidden = currentPackage == nil
    }

    private func reloadItems() {
        items = gameController?.playerItems

        if let newCategory = items?.keys.first {
            changeCurrentCategory(to: newCategory)
        }

        itemsView.reloadData()
    }

    @objc internal func reloadCurrentPackage() {
        currentPackage = gameController?.retrieveOpenPackage()
        reloadOpenBoxView()
        currentPackageItems = gameController?.retrieveItemsFromOpenPackage()
        currentPackageView.reloadData()
        currentPackageLabel.text = gameController?.openedPackage?.toString()
        packagesView.reloadData()
    }

    @objc internal func updateSatisfactionBar() {
        if let value = gameController?.satisfactionBar.currentFractionalSatisfaction {
            satisfactionBar.setProgress(Float(value), animated: false)
        }
    }
    
    @objc internal func handleRoundEnded() {
        NotificationCenter.default.removeObserver(self, name: .didEndRound, object: nil)
        self.view.isUserInteractionEnabled = false
        let title = "This round has ended."
        let alert = UIAlertController(title: title, message: "", preferredStyle: .alert)
        self.present(alert, animated: true, completion: nil)
        
        endRoundTimer = Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { _ in
            self.removeObservers()
            self.performSegue(withIdentifier: "endRound", sender: self)
        }
    }
    
    @objc internal func handleGameEnded() {
        endRoundTimer?.invalidate()
        performSegue(withIdentifier: "endGameFromPacking", sender: self)
    }

    @objc internal func handleItemLimitReached() {
        let alert = createAlert(title: "You can't add any more items!",
                                message: "If you still have items to add, "
                                    + "try placing the items into the package in a different order.",
                                action: "Ok.")
        self.present(alert, animated: true, completion: nil)
    }

    private func changeCurrentCategory(to category: Category) {
        currentCategory = category
        reloadCategoryButton()
        itemsView.reloadData()
    }

    private func reloadCategoryButton() {
        categoryButton.setTitle(currentCategory?.categoryName, for: .normal)
    }

    private func attachLongPressToPackages() {
        let longPressGR = UILongPressGestureRecognizer(target: self,
                                                       action: #selector(handlePackageLongPress(longPressGR:)))
        longPressGR.minimumPressDuration = 0.5
        longPressGR.delaysTouchesBegan = true
        self.packagesView.addGestureRecognizer(longPressGR)
    }

    @objc internal func handlePackageLongPress(longPressGR: UILongPressGestureRecognizer) {
        if longPressGR.state != .began {
            return
        }
        let point = longPressGR.location(in: self.packagesView)
        let indexPath = self.packagesView.indexPathForItem(at: point)
        if let indexPath = indexPath {
            if indexPath.item == packages?.count {
                // The last item is actually the Add Button.
                return
            }
            let cell = self.packagesView.cellForItem(at: indexPath)
            if let packageCell = cell as? PackageCell {
                packageForDelivery = packageCell.package
                performSegue(withIdentifier: "deliverPackage", sender: self)
            }
        }
    }

    @IBAction private func touchAssembleButton(_ sender: Any) {
        if assemblyMode {
            assembleParts()
            assemblyMode = false
            currentPackageView.reloadData()
        } else {
            selectedParts = [Bool](repeating: false, count: currentPackageItems?.count ?? 0)
            assemblyMode = true
            currentPackageView.reloadData()
        }
    }

    private func assembleParts() {
        do {
            var parts = [Item]()
            for index in 0..<selectedParts.count {
                if selectedParts[index], let items = currentPackageItems {
                    parts.append(items[index])
                }
            }
            try gameController?.constructAssembledItem(parts: parts)
        } catch ItemAssembledError.assembledItemConstructionError {
            // Currently, do nothing. Invalid selection of parts by player.
        } catch {
            assert(false, "Unexpected error.")
        }
    }

    @IBAction private func touchCategoryButton(_ sender: UIView) {
        if let viewController = self.storyboard?.instantiateViewController(identifier: categoryIdentifier)
            as? CategoryViewController {
            let width = view.frame.width - 60
            let height = view.frame.width / 2
            viewController.preferredContentSize = CGSize(width: width, height: height)
            viewController.modalPresentationStyle = .popover
            if let categoriesAsKeys = items?.keys {
                viewController.categories = Array(categoriesAsKeys)
            }
            viewController.categoryChangeDelegate = self
            if let pres = viewController.presentationController {
                pres.delegate = self
            }
            if let pop = viewController.popoverPresentationController {
                pop.sourceView = sender
                pop.sourceRect = sender.bounds
                pop.permittedArrowDirections = []
            }
            self.present(viewController, animated: true)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        removeAllPreviousViewControllers()
        if segue.identifier == "toHouses" {
            let viewController = segue.destination as? HousesViewController
            viewController?.gameController = gameController
        }
        if segue.identifier == "deliverPackage" {
            let viewController = segue.destination as? DeliveryViewController
            viewController?.gameController = gameController
            viewController?.packageForDelivery = packageForDelivery
        }
        if segue.identifier == "endRound" {
            removeBackgroundObservers() // prevent background observers from responding to notifs
            let viewController = segue.destination as? GameViewController
            viewController?.gameController = gameController
        }
        // for background pausing feature
        if segue.identifier == "pauseGame" {
            let viewController = segue.destination as? PauseViewController
            viewController?.gameController = gameController
            NotificationCenter.default.removeObserver(self, name: .didPauseRound, object: nil)
        }
        if segue.identifier == "endGameFromPacking" {
            let viewController = segue.destination as? GameOverViewController
            do {
                try viewController?.scores = gameController?.getExistingScores()
            } catch {
                viewController?.scores = []
            }
        }
    }
    
    @objc internal func handleAppMovedToForeground() {
        endBackgroundTask()
        gameController?.resumeRound()
        if backgroundTask == .invalid {
            registerBackgroundTask()
        }
    }

    @objc internal func handleRoundPaused() {
        performSegue(withIdentifier: "pauseGame", sender: self)
    }
    
    private func endBackgroundTask() {
        UIApplication.shared.endBackgroundTask(backgroundTask)
        backgroundTask = .invalid
    }
    
    private func registerBackgroundTask() {
        backgroundTask = UIApplication.shared.beginBackgroundTask { [weak self] in
            self?.endBackgroundTask()
        }
    }
    
    @objc internal func handleRoundResumed() {
        dismiss(animated: true, completion: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleRoundPaused),
                                               name: .didPauseRound, object: nil)
    }
    
    @objc internal func handleAppMovedToBackground() {
        gameController?.pauseRound()
    }
    
    @objc internal func handleCorrectDelivery() {
        // Shows user that the order was completed correctly
        generateTextLabelForDeliveryStatus(isCorrect: true)
    }

    @objc internal func handleWrongDelivery() {
        // Shows user that the order was completed wrongly
        generateTextLabelForDeliveryStatus(isCorrect: false)
    }
    
    private func generateTextLabelForDeliveryStatus(isCorrect: Bool) {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 50))
        label.center = self.view.center
        if isCorrect {
            label.backgroundColor = UIColor.green
            label.text = "Correct Order!"
        } else {
            label.backgroundColor = UIColor.red
            label.text = "Wrong Order!"
        }
        label.textAlignment = .center
        label.layer.cornerRadius = 20
        label.layer.masksToBounds = true
        self.view.addSubview(label)
        
        Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { _ in
            UIView.animate(withDuration: 0.5) {
                label.alpha = 0.0
            }
        }
    }
    
    private func createAlert(title: String, message: String, action: String) -> UIAlertController {
        let controller = UIAlertController(title: String(title),
                                           message: String(message),
                                           preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: String(action),
                                          style: .default)
        controller.addAction(defaultAction)
        return controller
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension PackingViewController: CategoryChangeDelegate {
    func setCategory(_ category: Category) {
        changeCurrentCategory(to: category)
    }
}

extension PackingViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController,
                                   traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        .none
    }
}
