//
//  CLLocationManager+Swizzle.swift
//  Pace
//
//  Created by Yuntong Zhang on 13/4/19.
//  Referenced from: https://hackernoon.com/simulating-user-location-and-navigation-route-on-iphone-without-xcode-761f06905f1c
//  Copyright © 2019 nus.cs3217.pace. All rights reserved.
//

import Foundation
import CoreLocation

private let swizzling: (AnyClass, Selector, Selector) -> () = { forClass, originalSelector, swizzledSelector in
    if let originalMethod = class_getInstanceMethod(forClass, originalSelector),
        let swizzledMethod = class_getInstanceMethod(forClass, swizzledSelector) {
        method_exchangeImplementations(originalMethod, swizzledMethod)
    }
}

extension CLLocationManager: SelfAware {
    // implement to perform swizzling at runtime
    public static func awake() {
        let originalLocationSelector = #selector(getter: CLLocationManager.location)
        let swizzledLocationSelector = #selector(getter: swizzledLocation)
        swizzling(CLLocationManager.self, originalLocationSelector, swizzledLocationSelector)

        let originalStartSelector = #selector(CLLocationManager.startUpdatingLocation)
        let swizzledStartSelector = #selector(swizzledStartLocation)
        swizzling(CLLocationManager.self, originalStartSelector, swizzledStartSelector)

        let originalStopSelector = #selector(CLLocationManager.stopUpdatingLocation)
        let swizzledStopSelector = #selector(swizzledStopLocation)
        swizzling(CLLocationManager.self, originalStopSelector, swizzledStopSelector)

        let originalRequestSelector = #selector(CLLocationManager.requestLocation)
        let swizzledRequestSelector = #selector(swizzledRequestLocation)
        swizzling(CLLocationManager.self, originalRequestSelector, swizzledRequestSelector)
    }

    @objc var swizzledLocation: CLLocation? {
        return MockCLLocationManager.shared.location
    }

    @objc func swizzledStartLocation() {
        if !MockCLLocationManager.shared.isRunning {
            MockCLLocationManager.shared.startMocks()
        }
        MockCLLocationManager.shared.delegate = self.delegate
        MockCLLocationManager.shared.startUpdatingLocation()
    }

    @objc func swizzledStopLocation() {
        MockCLLocationManager.shared.stopUpdatingLocation()
    }

    @objc func swizzledRequestLocation() {
        if !MockCLLocationManager.shared.isRunning {
            MockCLLocationManager.shared.startMocks()
        }
        MockCLLocationManager.shared.delegate = self.delegate
        MockCLLocationManager.shared.requestLocation()
    }
}
