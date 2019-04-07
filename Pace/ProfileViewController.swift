//
//  ProfileViewController.swift
//  Pace
//
//  Created by Ang Wei Neng on 21/3/19.
//  Copyright © 2019 nus.cs3217.pace. All rights reserved.
//

import UIKit
import FacebookCore
import FacebookLogin
import CoreLocation

class ProfileViewController: UIViewController {

    var runs = [Run]()
    @IBOutlet private var runHistory: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = Titles.profile
        // Dummy Data
        var checkpoints = [CheckPoint]()
        let c1 = CLLocationCoordinate2D(latitude: 1.308_22, longitude: 103.773_131)
        let l1 = CLLocation(coordinate: c1, altitude: 0, horizontalAccuracy: 25, verticalAccuracy: 25, course: 0, speed: 5, timestamp: Date())
        let c2 = CLLocationCoordinate2D(latitude: 1.307_71, longitude: 103.770_719)
        let l2 = CLLocation(coordinate: c2, altitude: 0, horizontalAccuracy: 25, verticalAccuracy: 25, course: 0, speed: 6, timestamp: Date())
        let c3 = CLLocationCoordinate2D(latitude: 1.302_39, longitude: 103.767_35)
        let l3 = CLLocation(coordinate: c3, altitude: 0, horizontalAccuracy: 25, verticalAccuracy: 25, course: 0, speed: 3, timestamp: Date())
        let c4 = CLLocationCoordinate2D(latitude: 1.301_296, longitude: 103.772_961)
        let l4 = CLLocation(coordinate: c4, altitude: 0, horizontalAccuracy: 25, verticalAccuracy: 25, course: 0, speed: 6, timestamp: Date())
        let c5 = CLLocationCoordinate2D(latitude: 1.305_222, longitude: 103.773_894)
        let l5 = CLLocation(coordinate: c5, altitude: 0, horizontalAccuracy: 25, verticalAccuracy: 25, course: 0, speed: 2, timestamp: Date())
        checkpoints.append(
            CheckPoint(location: l1, time: 0, actualDistance: 0, routeDistance: 0))
        checkpoints.append(
            CheckPoint(location: l2, time: 5, actualDistance: 274, routeDistance: 274))
        checkpoints.append(
            CheckPoint(location: l3, time: 10, actualDistance: 971, routeDistance: 971))
        checkpoints.append(
            CheckPoint(location: l4, time: 13, actualDistance: 1_607, routeDistance: 1_607))
        checkpoints.append(
            CheckPoint(location: l5, time: 15, actualDistance: 2_053, routeDistance: 2_053))

        for _ in 0...5 {
            runs.append(Run(runner: Dummy.user, checkpoints: checkpoints))
        }
        runHistory.reloadData()
    }
}

// MARK: - UICollectionViewDataSource
extension ProfileViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return runs.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Identifiers.runCell, for: indexPath) as! RunCollectionViewCell
        cell.run = runs[indexPath.item]
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let runAnalysis = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: Identifiers.runAnalysisController) as? RunAnalysisController else {
            return
        }
        runAnalysis.run = runs[indexPath.item]
        navigationController?.pushViewController(runAnalysis, animated: true)

    }
}

extension ProfileViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 100)
    }
}
