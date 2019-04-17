//
//  CompareRunController.swift
//  Pace
//
//  Created by Tan Zheng Wei on 8/4/19.
//  Copyright © 2019 nus.cs3217.pace. All rights reserved.
//

import UIKit
import RealmSwift
import CoreLocation

class RunCollectionController: PullUpController {

    @IBOutlet private var initialDisplay: UIView!
    @IBOutlet private var runCollectionView: UICollectionView!
    @IBOutlet private var collectionHeightConstraint: NSLayoutConstraint!
    private var maxHeight: CGFloat?
    private var initOffset: CGFloat?
    private var cellIdentifier: String = Identifiers.compareRunCell

    // To be set on instantiation of controller
    weak var delegate: RunCollectionControllerDelegate?
    var currentRunId: String?
    var routeId: String?
    private lazy var runs = {
        return Realm.inMemory.objects(Run.self).filter(self.runsToComparePredicate)
    }()
    private lazy var runsToComparePredicate = {
        return NSPredicate(format: "routeId = %@ AND objectId != %@",
                           routeId ?? "", currentRunId ?? "")
    }()
    private var notificationToken: NotificationToken?

    override func viewDidLoad() {
        super.viewDidLoad()
        runCollectionView.register(CompareRunCollectionViewCell.self, forCellWithReuseIdentifier: cellIdentifier)
        guard let routeId = routeId, currentRunId != nil else {
            return
        }
        CachingStorageManager.default.getRunsFor(routeId: routeId)
        notificationToken = runs.observe { [unowned self] _ in
            self.runCollectionView.reloadData()
        }
    }

    // Maximum height of the pullup view
    var height: CGFloat {
        get {
            return maxHeight ?? 0
        }
        set {
            maxHeight = newValue
            collectionHeightConstraint.constant = collectionHeight
        }
    }

    override var initialDisplayOffset: CGFloat {
        return parent?.tabBarController?.tabBar.frame.height ?? 0
    }

    override var includeInitialStickyPoint: Bool {
        return false
    }

    /// Height from bottom when first displayed
    var initialHeight: CGFloat {
        return initialDisplay.frame.height
    }

    /// Height of the run collection
    var collectionHeight: CGFloat {
        return height - initialHeight
    }

    override var pullUpControllerMiddleStickyPoints: [CGFloat] {
        return [initialHeight]
    }

    override var pullUpControllerPreferredSize: CGSize {
        return CGSize(width: UIScreen.main.bounds.width, height: runCollectionView.frame.maxY)
    }
}

extension RunCollectionController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return runs.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = runCollectionView.dequeueReusableCell(
            withReuseIdentifier: cellIdentifier,
            for: indexPath) as! CompareRunCollectionViewCell
        cell.run = runs[indexPath.item]
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let clickedRun = runs[indexPath.item]
        let cell = runCollectionView.cellForItem(at: indexPath) as! CompareRunCollectionViewCell
        cell.toggleClicked()
        delegate?.onClickCallback(run: clickedRun)
        pullUpControllerMoveToVisiblePoint(initialHeight, animated: true, completion: nil)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: runCollectionView.bounds.width, height: 75)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
}

/// A parent controller that instantiates this controller should set implement this protocol
protocol RunCollectionControllerDelegate: class {
    /// Callback when clicking the cell of a run
    func onClickCallback(run: Run)
}
