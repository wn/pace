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
    
    let route = Dummy.route
    var paces = [Pace]()
    @IBOutlet private var runHistory: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = Titles.profile
        // Dummy Data
        
        var checkpoints = [CheckPoint]()
        for i in 0...100 {
            checkpoints.append(
                CheckPoint(location: CLLocation(latitude: Double(100 + i), longitude: Double(100 + i)),
                           time: Double(i*2), actualDistance: Double(i*2), routeDistance: Double(i*2)))
        }
        
        for _ in 0...5 {
            paces.append(Pace(runner: Dummy.user, checkpoints: checkpoints))
        }
        runHistory.reloadData()
    }

    func buttonTapped(_ pace: Pace) {
        guard let runAnalysis = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: Identifiers.runAnalysisController) as? RunAnalysisController else {
            return
        }
        runAnalysis.pace = pace
        navigationController?.pushViewController(runAnalysis, animated: true)
    }
}

// MARK: - UICollectionViewDataSource
extension ProfileViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return paces.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Identifiers.pace, for: indexPath) as! PaceView
        cell.pace = paces[indexPath.item]
        cell.delegate = self
        return cell
    }
}

extension ProfileViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 100)
    }
}
