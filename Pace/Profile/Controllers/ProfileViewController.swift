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
    @IBOutlet private var userStats: UserStatsView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigation()
        // Dummy Data
        var checkpoints = [CheckPoint]()
        var route: Route?
        let cp1 = CLLocationCoordinate2D(latitude: 1.308_22, longitude: 103.773_131)
        let loc1 = CLLocation(coordinate: cp1, altitude: 0, horizontalAccuracy: 25, verticalAccuracy: 25, course: 0, speed: 5, timestamp: Date())
        let cp2 = CLLocationCoordinate2D(latitude: 1.307_71, longitude: 103.770_719)
        let loc2 = CLLocation(coordinate: cp2, altitude: 0, horizontalAccuracy: 25, verticalAccuracy: 25, course: 0, speed: 6, timestamp: Date())
        let cp3 = CLLocationCoordinate2D(latitude: 1.302_39, longitude: 103.767_35)
        let loc3 = CLLocation(coordinate: cp3, altitude: 0, horizontalAccuracy: 25, verticalAccuracy: 25, course: 0, speed: 3, timestamp: Date())
        let cp4 = CLLocationCoordinate2D(latitude: 1.301_296, longitude: 103.772_961)
        let loc4 = CLLocation(coordinate: cp4, altitude: 0, horizontalAccuracy: 25, verticalAccuracy: 25, course: 0, speed: 6, timestamp: Date())
        let cp5 = CLLocationCoordinate2D(latitude: 1.305_222, longitude: 103.773_894)
        let loc5 = CLLocation(coordinate: cp5, altitude: 0, horizontalAccuracy: 25, verticalAccuracy: 25, course: 0, speed: 2, timestamp: Date())
        checkpoints.append(
            CheckPoint(location: loc1, time: 0, actualDistance: 0, routeDistance: 0))
        checkpoints.append(
            CheckPoint(location: loc2, time: 5, actualDistance: 274, routeDistance: 274))
        checkpoints.append(
            CheckPoint(location: loc3, time: 10, actualDistance: 971, routeDistance: 971))
        checkpoints.append(
            CheckPoint(location: loc4, time: 13, actualDistance: 1_607, routeDistance: 1_607))
        checkpoints.append(
            CheckPoint(location: loc5, time: 15, actualDistance: 2_053, routeDistance: 2_053))

        for idx in 0...5 {
            let run = Run(runner: Dummy.user, checkpoints: checkpoints)
            if idx == 0 {
                route = Route(creator: Dummy.user, name: "Fun Run", creatorRun: run)
            } else {
                route?.addNewRun(run)
            }
            runs.append(run)
        }
        userStats.setStats(with: User())
        runHistory.reloadData()
    }

    @objc
    private func popupSettings() {
        let loginManager = LoginManager()
        loginManager.logOut()
    }

    private func setupNavigation() {
        navigationItem.title = Titles.profile
        let image = UIImage(named: "settings.png")?.withRenderingMode(.alwaysOriginal)
        let settingsButton = UIButton(type: .system)
        let widthConstraint = settingsButton.widthAnchor.constraint(equalToConstant: 30)
        let heightConstraint = settingsButton.heightAnchor.constraint(equalToConstant: 30)
        widthConstraint.isActive = true
        heightConstraint.isActive = true
        settingsButton.setImage(image, for: .normal)
        settingsButton.addTarget(self, action: #selector(popupSettings), for: .allTouchEvents)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: settingsButton)
    }
}

// MARK: - UICollectionViewDataSource
extension ProfileViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return runs.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView
            .dequeueReusableCell(withReuseIdentifier: Identifiers.runCell, for: indexPath) as! RunCollectionViewCell
        cell.run = runs[indexPath.item]
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let runAnalysis = UIStoryboard(name: "Main", bundle: nil)
            .instantiateViewController(withIdentifier: Identifiers.runAnalysisController)
            as? RunAnalysisController else {
            return
        }
        runAnalysis.run = runs[indexPath.item]
        navigationController?.pushViewController(runAnalysis, animated: true)

    }
}

extension ProfileViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 100)
    }
}
