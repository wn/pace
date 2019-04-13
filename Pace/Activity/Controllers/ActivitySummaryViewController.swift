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

    @IBAction func endRun(_ sender: UIButton) {
        // TODO: Check that we have sufficient distance to save!!
//        guard distance >= Constants.checkPointDistanceInterval else {
//            print("CANT SAVE THIS SHIT")
//            return
//        }
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

    override func viewDidLoad() {
        routesManager = CachingStorageManager.default
        distanceLabel.text = "distance: \(distance) meters"
        paceLabel.text = "pace: \(pace)"
        timeLabel.text = "time: \(time) seconds"
        VoiceAssistant.say("Distance: \(distance) meters")
        VoiceAssistant.say("Duration: \(time) seconds")
        VoiceAssistant.say("Pace: \(pace) seconds per kilometer")
    }

    @IBAction private func exit(_ sender: UIButton) {
        derenderChildController()
    }
}
