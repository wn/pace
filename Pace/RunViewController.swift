//
//  RunViewController.swift
//  Pace
//
//  Created by Tan Zheng Wei on 16/3/19.
//  Copyright © 2019 nus.cs3217.pace. All rights reserved.
//

import UIKit
import CoreLocation

class RunViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet private var stopwatch: StopWatch!
    @IBOutlet private var locationLabel: UILabel!

    private let locationManager = CLLocationManager()
    private var seconds = TimeInterval(0)
    private var timer: Timer?
    private var checkpoints = [CheckPoint]()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupLocationManager()
        stopwatch.setTime(to: 0)
    }

    private func setupLocationManager() {
        locationManager.requestAlwaysAuthorization()
        /// Location Manager Configurations
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.distanceFilter = CLLocationDistance(1)
            locationManager.startUpdatingLocation()
            locationManager.startUpdatingHeading()
        }
    }

    @IBAction func start(_ sender: UIButton) {
        timer = Timer.scheduledTimer(timeInterval: 1,
                      target: self,
                      selector: #selector(updateTime),
                      userInfo: nil,
                      repeats: true)
        locationManager.requestLocation()
    }

    @IBAction func stop(_ sender: UIButton) {
        timer?.invalidate()
        timer = nil
    }

    @IBAction func save(_ sender: UIButton) {
//        let route = Route(runner: Dummy.user, runnerRecords: checkpoints)
    }

    @objc
    func updateTime() {
        seconds += 1.0
        stopwatch.setTime(to: seconds)
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            return
        }
        guard timer != nil else {
            return
        }
        var distance: Double = 0
        if let lastCheckpoint = checkpoints.last, let lastLocation = lastCheckpoint.location {
            distance = location.distance(from: lastLocation)
        }
        let newCheckpoint = CheckPoint(location: location,
                                       time: seconds,
                                       actualDistance: distance,
                                       routeDistance: distance)
        checkpoints.append(newCheckpoint)
        locationLabel.text = "(\(location.coordinate.longitude), \(location.coordinate.latitude))"
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error:: \(error.localizedDescription)")
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }
}
