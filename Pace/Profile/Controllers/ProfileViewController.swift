//
//  ProfileViewController.swift
//  Pace
//
//  Created by Ang Wei Neng on 21/3/19.
//  Copyright © 2019 nus.cs3217.pace. All rights reserved.
//

import UIKit
import RealmSwift
import FacebookCore
import FacebookLogin
import CoreLocation

class ProfileViewController: RequireLoginController {

    @IBOutlet private var runHistory: UICollectionView!
    @IBOutlet private var userStats: UserStatsView!
    @IBOutlet private var historyLabel: UILabel!

    private var runs: Results<Run>?

    private var runnerPredicate: NSPredicate {
        return NSPredicate(format: "runner.objectId == %@", user?.objectId ?? "")
    }
    private var notificationToken: NotificationToken?

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        userDidLoad()
        setupNavigation()
    }

    override func userDidLoad() {
        guard let user = user else {
            runHistory.reloadData()
            return
        }
        if runs == nil {
            runs = Realm.persistent.objects(Run.self).filter(self.runnerPredicate)
                .sorted(byKeyPath: "dateCreated", ascending: false)
        }
        userStats.runs = runs
        userStats.calculateStats()
        setLabel(runs?.count ?? 0)
        setupNavigation()
        CachingStorageManager.default.getRunsFor(user: user, nil)
        notificationToken?.invalidate()
        notificationToken = runs?.observe { [unowned self] _ in
            self.runHistory.reloadData()
            self.userStats.calculateStats()
            self.setLabel(self.runs?.count ?? 0)
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        notificationToken?.invalidate()
    }

    @objc
    private func logout() {
        let loginManager = LoginManager()
        loginManager.logOut()
        viewWillAppear(true)
    }

    private func setupNavigation() {
        navigationItem.title = Titles.profile
        guard let _ = user else {
            navigationItem.rightBarButtonItem = nil
            return
        }
        let logoutButton = UIBarButtonItem(title: "Log Out",
                                           style: .plain,
                                           target: self,
                                           action: #selector(logout))
        navigationItem.rightBarButtonItem = logoutButton
    }

    private func setLabel(_ numRuns: Int) {
        let count = runs?.count ?? 0
        historyLabel.text = "Past Runs (\(count))"
    }
}

// MARK: - UICollectionViewDataSource
extension ProfileViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return runs?.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView
            .dequeueReusableCell(withReuseIdentifier: Identifiers.runCell, for: indexPath) as! RunCollectionViewCell
        cell.run = runs?[indexPath.item]
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let runAnalysis = UIStoryboard(name: Identifiers.storyboard, bundle: nil)
            .instantiateViewController(withIdentifier: Identifiers.runAnalysisController)
            as? RunAnalysisController else {
            return
        }
        runAnalysis.run = runs?[indexPath.item]
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
