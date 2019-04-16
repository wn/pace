//
//  ActivitySummaryViewController.swift
//  Pace
//
//  Created by Ang Wei Neng on 25/3/19.
//  Copyright © 2019 nus.cs3217.pace. All rights reserved.
//

import UIKit
import CoreLocation

class ActivitySummaryViewController: UIViewController {
    // MARK: UI variables
    @IBOutlet private var statsView: RunStatsView!

    // MARK: Run variables
    var finishedRun: OngoingRun?
    private var routesManager = CachingStorageManager.default
    private var isSaved = false

    /// Set the necessary information for the summary. Called when initializing the summary.
    func setRun(as finishedRun: OngoingRun?) {
        self.finishedRun = finishedRun
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigation()
        showStats()
        // TODO: decide which button to render
    }

    private func setupNavigation() {
        navigationItem.title = Titles.runSummary
        let image = UIImage(named: Images.saveButton)?.withRenderingMode(.alwaysOriginal)
        let saveButton = UIButton(type: .system)
        let widthConstraint = saveButton.widthAnchor.constraint(equalToConstant: 30)
        let heightConstraint = saveButton.heightAnchor.constraint(equalToConstant: 30)
        widthConstraint.isActive = true
        heightConstraint.isActive = true
        saveButton.setImage(image, for: .normal)
        saveButton.addTarget(self, action: #selector(saveButtonPressed), for: .allTouchEvents)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: saveButton)
    }

    @objc
    private func saveButtonPressed() {
        guard !isSaved else {
            return
        }

        guard
            let distance = finishedRun?.distanceSoFar,
            distance >= Constants.checkPointDistanceInterval else {
                // Distance of the run is not long enough for saving
                let alert = UIAlertController(
                    title: nil,
                    message: "Distance covered is insufficient to be saved",
                    preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                present(alert, animated: true)
                return
        }

        let followingRun = finishedRun?.paceRun?.route != nil
        var message = ""
        if followingRun {
            message = "Would you like to create a new route or add your run to this route?"
        } else {
            message = "Would you like to share the route to public?"
        }
        let alert = UIAlertController(
            title: "Save run",
            message: message,
            preferredStyle: .alert)
        if followingRun {
            alert.addAction(UIAlertAction(title: "Add my run", style: .default) { [unowned self] _ in
                self.saveFollowRun()
            })
        }
        alert.addAction(UIAlertAction(title: "Create new route", style: .default) { [unowned self] _ in
            self.saveRun()
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true)
    }

    // This is another saving button for testing
    @IBAction func bottomSaveButtonPressed(_ sender: UIButton) {
        saveRun()
    }

    private func saveRun() {
        // TODO: Check that we have sufficient distance to save!!
        guard let distance = finishedRun?.distanceSoFar,
            distance >= Constants.checkPointDistanceInterval else {
            // Distance of the run is not long enough for saving
            return
        }
        guard let newRoute = finishedRun?.toNewRoute() else {
            // user is not logged in
            return
        }
        isSaved = true
        routesManager.saveNewRoute(newRoute, nil)

        // TODO: improve the after-saving UI interaction
        derenderChildController()
    }

    func saveFollowRun() {
        guard
            let finishedRun = finishedRun,
            let parentRoute = finishedRun.paceRun?.route else {
                return
        }

        if finishedRun.classifiedAsFollow() { // save to the parent
            guard let newRun = finishedRun.toRun() else {
                // user not logged in
                return
            }
            routesManager.saveNewRun(newRun, toRoute: parentRoute, nil)
        } else { // save as new route
            guard let newRoute = finishedRun.toNewRoute() else {
                // user not logged in
                return
            }
            routesManager.saveNewRoute(newRoute, nil)
        }

        derenderChildController()
    }

    private func showStats() {
        guard let distance = finishedRun?.distanceSoFar, let time = finishedRun?.timeSoFar else {
            return
        }
        statsView.setStats(distance: distance, time: time)
    }
}
