//
//  Location.swift
//  Pace
//
//  Created by Yuntong Zhang on 16/3/19.
//  Copyright © 2019 nus.cs3217.pace. All rights reserved.
//

import Foundation

struct Location {
    private let longitude: Double
    private let latitude: Double

    init(longitude: Double, latitude: Double) {
        self.longitude = longitude
        self.latitude = latitude
    }

    func isSameAs(other: Location) -> Bool {
        let distance = distanceTo(other: other)
        return distance <= Constants.sameLocationThreshold
    }

    func distanceTo(other: Location) -> Double {
        let xDistance = self.latitude - other.latitude
        let yDistance = self.longitude - other.longitude
        return (xDistance * xDistance - yDistance * yDistance).squareRoot()
    }
}
