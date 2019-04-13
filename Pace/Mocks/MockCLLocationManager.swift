//
//  MockCLLocationManager.swift
//  Pace
//
//  Created by Yuntong Zhang on 14/4/19.
//  Referenced from: https://hackernoon.com/simulating-user-location-and-navigation-route-on-iphone-without-xcode-761f06905f1c
//  Copyright © 2019 nus.cs3217.pace. All rights reserved.
//

import Foundation
import CoreLocation

struct MockLocationConfiguration {
    static var updateInterval = 1.0
    static var GpxFileName: String?
}

class MockCLLocationManager: CLLocationManager {
    private var parser: GpxParser?
    private var timer: Timer?
    private var locations: [CLLocation]?
    private var _isRunning: Bool = false
    var updateInterval: TimeInterval = MockLocationConfiguration.updateInterval
    var isRunning: Bool {
        return _isRunning
    }
    var lastPolledLocation: CLLocation?
    // provide location when requested
    override var location: CLLocation? {
        return lastPolledLocation
    }

    // singleton instance
    static let shared = MockCLLocationManager()

    private override init() {
        locations = [CLLocation]()
    }

    func startMocks() {
        guard let fileName = MockLocationConfiguration.GpxFileName else {
            return
        }
        parser = GpxParser(forResource: fileName, ofType: "gpx")
        parser?.delegate = self
        parser?.parse()
    }

    override func startUpdatingLocation() {
        timer = Timer(timeInterval: updateInterval, repeats: true, block: {
            [unowned self](_) in
            self.updateLocation()
        })
        guard let timer = timer else {
            return
        }
        RunLoop.main.add(timer, forMode: RunLoop.Mode.default)
    }

    override func stopUpdatingLocation() {
        timer?.invalidate()
        _isRunning = false
    }

    override func requestLocation() {
        guard let isEmpty = locations?.isEmpty, !isEmpty, let location = locations?.removeFirst() else {
            // no more location in the file
            stopUpdatingLocation()
            return
        }
        lastPolledLocation = location
        delegate?.locationManager?(self, didUpdateLocations: [location])
    }

    private func updateLocation() {
        guard let isEmpty = locations?.isEmpty, !isEmpty, let location = locations?.removeFirst() else {
            stopUpdatingLocation()
            return
        }
        _isRunning = true
        lastPolledLocation = location
        delegate?.locationManager?(self, didUpdateLocations: [location])
    }
}

extension MockCLLocationManager: GpxParsing {
    func parser(_ parser: GpxParser, didCompleteParsing locations: [CLLocation]) {
        self.locations = locations
    }
}
