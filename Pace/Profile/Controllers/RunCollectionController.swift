//
//  CompareRunController.swift
//  Pace
//
//  Created by Tan Zheng Wei on 8/4/19.
//  Copyright © 2019 nus.cs3217.pace. All rights reserved.
//

import UIKit
import CoreLocation

class RunCollectionController: PullUpController {

    @IBOutlet private var initialDisplay: UIView!
    @IBOutlet private var runCollectionView: UICollectionView!
    @IBOutlet private var collectionHeightConstraint: NSLayoutConstraint!
    // To be set on instantiation of controller
    private var maxHeight: CGFloat?
    private var initOffset: CGFloat?
    var delegate: RunCollectionControllerDelegate?
    var cellIdentifier: String = Identifiers.compareRunCell
    //    weak var route: Route?
//    weak var currentRun: Run?
    var runs = [Run]()

    override func viewDidLoad() {
        super.viewDidLoad()
        runCollectionView.register(CompareRunCollectionViewCell.self, forCellWithReuseIdentifier: cellIdentifier)
        var checkpoints = [CheckPoint]()
        let cp1 = CLLocationCoordinate2D(latitude: 1.308_22, longitude: 103.773_131)
        let loc1 = CLLocation(coordinate: cp1, altitude: 0, horizontalAccuracy: 25, verticalAccuracy: 25, course: 0, speed: 1, timestamp: Date())
        let cp2 = CLLocationCoordinate2D(latitude: 1.307_71, longitude: 103.770_719)
        let loc2 = CLLocation(coordinate: cp2, altitude: 0, horizontalAccuracy: 25, verticalAccuracy: 25, course: 0, speed: 4, timestamp: Date())
        let cp3 = CLLocationCoordinate2D(latitude: 1.302_39, longitude: 103.767_35)
        let loc3 = CLLocation(coordinate: cp3, altitude: 0, horizontalAccuracy: 25, verticalAccuracy: 25, course: 0, speed: 2, timestamp: Date())
        let cp4 = CLLocationCoordinate2D(latitude: 1.301_296, longitude: 103.772_961)
        let loc4 = CLLocation(coordinate: cp4, altitude: 0, horizontalAccuracy: 25, verticalAccuracy: 25, course: 0, speed: 3, timestamp: Date())
        let cp5 = CLLocationCoordinate2D(latitude: 1.305_222, longitude: 103.773_894)
        let loc5 = CLLocation(coordinate: cp5, altitude: 0, horizontalAccuracy: 25, verticalAccuracy: 25, course: 0, speed: 10, timestamp: Date())
        checkpoints.append(
            CheckPoint(location: loc1, time: 0, actualDistance: 0, routeDistance: 0))
        checkpoints.append(
            CheckPoint(location: loc2, time: 5, actualDistance: 274, routeDistance: 274))
        checkpoints.append(
            CheckPoint(location: loc3, time: 10, actualDistance: 971, routeDistance: 971))
        checkpoints.append(
            CheckPoint(location: loc4, time: 13, actualDistance: 1_607, routeDistance: 1_607))
        checkpoints.append(
            CheckPoint(location: loc5, time: 15, actualDistance: 2_100, routeDistance: 2_100))
        let run = Run(runner: Dummy.user, checkpoints: checkpoints)
        runs.append(run)
        runs.append(run)
        runs.append(run)
        runs.append(run)
        runs.append(run)
        runCollectionView.reloadData()
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

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = runCollectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! CompareRunCollectionViewCell
        cell.run = runs[indexPath.item]
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let clickedRun = runs[indexPath.item]
        delegate?.onClickCallback(run: clickedRun)
        pullUpControllerMoveToVisiblePoint(initialHeight, animated: true, completion: nil)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: runCollectionView.bounds.width, height: 75)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
}

/// A parent controller that instantiates this controller should set implement this protocol
protocol RunCollectionControllerDelegate {
    /// Callback when clicking the cell of a run
    func onClickCallback(run: Run)
}
