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
    @IBOutlet private var distanceLabel: UILabel!
    @IBOutlet private var paceLabel: UILabel!
    @IBOutlet private var timeLabel: UILabel!
    @IBOutlet private var statsView: RunStatsView!

    // MARK: Run variables
    var createdRun: OngoingRun?
    private var routesManager = CachingStorageManager.default
    private var isSaved = false

    // MARK: Run statistics variables
    private var distance: Double = 0
    private var pace: Int = 0
    private var time: Double = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigation()
        showStats()
        readStats()
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
        saveButton.addTarget(self, action: #selector(popupSettings), for: .allTouchEvents)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: saveButton)
    }

    @objc
    private func popupSettings() {
        guard !isSaved else {
            return
        }
        saveRun()
    }

    private func saveRun() {
        guard
            distance >= Constants.checkPointDistanceInterval,
            let route = createdRun?.toNewRoute()
        else {
            print("CANT SAVE THIS SHIT cause distance not long enuff")
            return
        }
        routesManager.saveNewRoute(route, nil)
        print("RUN SAVED")
    }

    func setStats(createdRun: OngoingRun, distance: CLLocationDistance, time: Double) {
        self.distance = distance
        self.pace = distance == 0 ? 0 : Int(time / distance)
        self.time = time
        self.createdRun = createdRun
    }

    private func showStats() {
        statsView.setStats(distance: distance, time: time)
    }

    private func readStats() {
        VoiceAssistant.say("Distance: \(Int(distance)) meters")
        VoiceAssistant.say("Duration: \(Int(time)) seconds")
        VoiceAssistant.say("Pace: \(Int(pace)) seconds per kilometer")
    }
}
