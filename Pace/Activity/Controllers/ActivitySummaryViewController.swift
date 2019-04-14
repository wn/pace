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
    @IBOutlet private var distanceLabel: UILabel!
    @IBOutlet private var paceLabel: UILabel!
    @IBOutlet private var timeLabel: UILabel!
    var createdRun: OngoingRun?
    var routesManager: RealmStorageManager?
    @IBOutlet var statsView: RunStatsView!


    @IBAction func saveRun(_ sender: UIButton) {
        // TODO: Check that we have sufficient distance to save!!
        guard distance >= Constants.checkPointDistanceInterval else {
            print("CANT SAVE THIS SHIT cause distance not long enuff")
            return
        }
        routesManager?.saveNewRoute(createdRun!.toNewRoute(), nil)
    }
    var distance: Double = 0
    var pace: Int = 0
    var time: Double = 0

    func setStats(createdRun: OngoingRun, distance: CLLocationDistance, time: Double) {
        self.distance = distance
        self.pace = distance == 0 ? 0 : Int(time / distance)
        self.time = time
        self.createdRun = createdRun
    }

    func showStats() {
        statsView.setStats(distance: distance, time: time)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = Titles.runSummary
        routesManager = CachingStorageManager.default
        showStats()
        VoiceAssistant.say("Distance: \(Int(distance)) meters")
        VoiceAssistant.say("Duration: \(Int(time)) seconds")
        VoiceAssistant.say("Pace: \(Int(pace)) seconds per kilometer")
    }

    @IBAction private func exit(_ sender: UIButton) {
        derenderChildController()
    }
}
