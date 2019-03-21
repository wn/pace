//
//  LocatonTime.swift
//  Pace
//
//  Created by Yuntong Zhang on 16/3/19.
//  Copyright © 2019 nus.cs3217.pace. All rights reserved.
//

import Foundation

struct CheckPoint {
    private let location: Location
    let time: Double
    private let actualDistance: Double
    let routeDistance: Double?

    init(location: Location, time: Double, actualDistance: Double, routeDistance: Double) {
        self.location = location
        self.time = time
        self.actualDistance = actualDistance
        self.routeDistance = routeDistance
    }
    
    // TODO: remove/reimplement once we figure out the final shape of the data.
    init(time: Double, routeDistance: Double) {
        self.location = Location(longitude: 0.0, latitude: 0.0)
        self.time = time
        self.routeDistance = routeDistance
        self.actualDistance = 0.0
    }
}
