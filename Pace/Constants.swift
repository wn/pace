//
//  Constants.swift
//  Pace
//
//  Created by Yuntong Zhang on 16/3/19.
//  Copyright © 2019 nus.cs3217.pace. All rights reserved.
//

import Foundation
import CoreLocation

struct Constants {
    static let sameLocationThreshold = 5.0
    static let checkPointDistanceInterval = 20.0

    // MARK: - MapView location constants
    // mapView constants
    static let initialZoom: Float = 18
    static let guardDistance: CLLocationDistance = 10 // New location must be greater than guardDistance for map to update
}
