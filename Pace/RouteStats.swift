//
//  RouteStats.swift
//  Pace
//
//  Created by Yuntong Zhang on 2/4/19.
//  Copyright © 2019 nus.cs3217.pace. All rights reserved.
//

import Foundation
import CoreLocation

/// This struct is not persistently stored.
/// It is generated based on the Route model upon requested.
struct RouteStats {

    let startingLocation: CLLocation
    let dateCreated: Date
    let totalDistance: Double
    let numOfRunners: Int
    let fastestTime: Double

    /// Constructs a RouteStats based on the provided stats.
    /// - Returns: The constructed `RouteStats` if all of the stats are not nil; nil otherwise.
    init?(startingLocation: CLLocation?, dateCreated: Date?, totalDistance: Double?, numOfRunners: Int?, fastestTime: Double?) {
        guard let startingLocation = startingLocation,
            let dateCreated = dateCreated,
            let totalDistance = totalDistance,
            let numOfRunners = numOfRunners,
            let fastestTime = fastestTime else {
                return nil
        }
        self.startingLocation = startingLocation
        self.dateCreated = dateCreated
        self.totalDistance = totalDistance
        self.numOfRunners = numOfRunners
        self.fastestTime = fastestTime
    }
}
