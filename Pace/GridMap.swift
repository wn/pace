//
//  GridMap.swift
//  Pace
//
//  Created by Ang Wei Neng on 6/4/19.
//  Copyright © 2019 nus.cs3217.pace. All rights reserved.
//

import CoreLocation

/// Create a grid system for the world map.
/// Works by storing a gridId as the bottom right of the grid.
public class GridMap {
    // The width and height of a grid, in metres.
    public let gridWidth: Double
    public let gridHeight: Double

    /// Get CLLocationDegree representing a unit of gridWidth.
    private var longitudeLength: CLLocationDegrees {
        var low: CLLocationDegrees = 0
        var high: CLLocationDegrees = 180

        let origin = CLLocation(latitude: 0, longitude: 0)
        while low != high {
            let mid = low + (high - low) / 2
            let currLocation = CLLocation(latitude: 0, longitude: mid)
            let distance = currLocation.distance(from: origin)
            if distance == gridWidth {
                return mid
            } else if distance < gridWidth {
                low = mid
            } else {
                high = mid
            }
        }
        return -1
    }

    /// Get CLLocationDegree representing a unit of gridHeight.
    private var latitudeLength: CLLocationDegrees {
        var low: CLLocationDegrees = 0
        var high: CLLocationDegrees = 90

        let origin = CLLocation(latitude: 0, longitude: 0)
        while low != high {
            let mid = low + (high - low) / 2
            let currLocation = CLLocation(latitude: mid, longitude: 0)
            let distance = currLocation.distance(from: origin)
            if distance == gridHeight {
                return mid
            } else if distance < gridHeight {
                low = mid
            } else {
                high = mid
            }
        }
        return -1
    }

    public init?(width: Double, height: Double) {
        guard width > 0 && height > 0 else {
            return nil
        }
        gridWidth = width
        gridHeight = height
    }


    /// Get the id of the grid that `position` is in.
    ///
    /// - Parameter position: The position to look up.
    /// - Returns: The id of the grid that `position` is in.
    public func getGridId(_ position: CLLocationCoordinate2D) -> GridNumber {
        let long = position.longitude - (position.longitude.truncatingRemainder(dividingBy: gridWidth))
        let lat = position.latitude - (position.latitude.truncatingRemainder(dividingBy: gridHeight))
        return GridNumber(latitude: lat, longitude: long)
    }

    public func getBoundedGrid(_ bound: GridBound) -> [GridNumber] {
        var result: [GridNumber] = []
        var smallLat = bound.minLat
        while smallLat < bound.maxLat {
            var smallLong = bound.minLong
            while smallLong < bound.maxLong {
                let currentGridId = getGridId(CLLocationCoordinate2D(latitude: smallLat, longitude: smallLong))
                result.append(currentGridId)
                smallLong += gridHeight
            }
            smallLat += gridHeight
        }
        return result
    }

    /// Get the bounds of a grid.
    ///
    /// - Parameter gridId: The id of the grid.
    /// - Returns: The bounds of the grid with the id `gridId`.
    public func getBounds(gridId: GridNumber) -> GridBound {
        let minLat = gridId.latitude
        let minLong = gridId.longitude
        let maxLat = gridId.latitude + latitudeLength
        let maxLong = gridId.longitude + longitudeLength
        return GridBound(minLat: minLat, minLong: minLong, maxLat: maxLat, maxLong: maxLong)
    }
}

public struct GridBound {
    public let minLat: CLLocationDegrees
    public let minLong: CLLocationDegrees
    public let maxLat: CLLocationDegrees
    public let maxLong: CLLocationDegrees

    public init(topLeft: CLLocationCoordinate2D, topRight: CLLocationCoordinate2D, bottomLeft: CLLocationCoordinate2D, bottomRight: CLLocationCoordinate2D) {
        let latitudes = [topLeft.latitude, topRight.latitude, bottomLeft.latitude, bottomRight.latitude]
        let longitudes = [topLeft.longitude, topRight.longitude, bottomLeft.longitude, bottomRight.longitude]
        minLat = latitudes.min() ?? 0
        minLong = longitudes.min() ?? 0
        maxLat = latitudes.max() ?? 0
        maxLong = longitudes.max() ?? 0
    }

    public init(minLat: CLLocationDegrees, minLong: CLLocationDegrees, maxLat: CLLocationDegrees, maxLong: CLLocationDegrees) {
        self.minLat = minLat
        self.minLong = minLong
        self.maxLat = maxLat
        self.maxLong = maxLong
    }
}

public struct GridNumber: Hashable {
    let latitude: CLLocationDegrees
    let longitude: CLLocationDegrees

    public init(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        self.latitude = latitude
        self.longitude = longitude
    }
}
