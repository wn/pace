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

class ProfileViewController: UIViewController, ViewDelegate {

    var runs = [Run]()
    @IBOutlet private var runHistory: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = Titles.profile
        // Dummy Data

        var checkpoints = [CheckPoint]()
        for idx in 0...100 {
            checkpoints.append(
                CheckPoint(location: CLLocation(latitude: Double(100 + idx), longitude: Double(100 + idx)),
                           time: Double(idx * 2), actualDistance: Double(idx * 2), routeDistance: Double(idx * 2)))
        }

        for _ in 0...5 {
            runs.append(Run(runner: Dummy.user, checkpoints: checkpoints))
        }
        runHistory.reloadData()
    }

    func buttonTapped(_ run: Run) {
        guard let runAnalysis = UIStoryboard(name: Constants.mainStoryboard, bundle: nil).instantiateViewController(withIdentifier: Identifiers.runAnalysisController) as? RunAnalysisController else {
            return
        }
        runAnalysis.run = run
        navigationController?.pushViewController(runAnalysis, animated: true)
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
        cell.delegate = self
        return cell
    }
}

extension ProfileViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 100)
    }
}
