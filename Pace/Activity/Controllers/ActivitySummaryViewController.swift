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
        // decide which button to render
    }

    private func setupNavigation() {
        navigationItem.title = Titles.runSummary
        let image = UIImage(named: "save.png")?.withRenderingMode(.alwaysOriginal)
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
        saveRun()
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
        guard let finishedRun = finishedRun else {
            // run was not set up properly when initializing this VC
            return
        }
        isSaved = true
        routesManager.saveNewRoute(finishedRun.toNewRoute(), nil)

        // TODO: improve the after-saving UI interaction
        derenderChildController()
    }

    @IBAction func saveFollowRun(_ sender: UIButton) {
        // TODO: Check that we have sufficient distance to save!!
        guard let distance = finishedRun?.distanceSoFar,
            distance >= Constants.checkPointDistanceInterval else {
                // Distance of the run is not long enough for saving
                return
        }
        guard let finishedRun = finishedRun,
            let parentRoute = finishedRun.paceRun?.route else {
            return
        }

        if finishedRun.classifiedAsFollow() { // save to the parent
            routesManager?.saveNewRun(finishedRun.toRun(), toRoute: parentRoute, nil)
        } else { // save as new route
            routesManager?.saveNewRoute(finishedRun.toNewRoute(), nil)
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
