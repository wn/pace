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

    private lazy var runs = {
        return Realm.persistent.objects(Run.self).filter(self.runnerPredicate)
    }()
    private lazy var runnerPredicate = {
        return NSPredicate(format: "runner.objectId == %@", user?.objectId ?? "")
    }()
    private var notificationToken: NotificationToken?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigation()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.loadData()
    }

    override func loadData() {
        guard let user = user else {
            runHistory.reloadData()
            return
        }
        userStats.runs = runs
        userStats.calculateStats()
        RealmUserSessionManager.default.getRunsFor(user: user)

        notificationToken = runs.observe { [unowned self] _ in
            self.runHistory.reloadData()
            self.userStats.calculateStats()
        }
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
        guard let runAnalysis = UIStoryboard(name: Identifiers.storyboard, bundle: nil)
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
