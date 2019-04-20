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
public struct GridMap {
    // The width and height of a grid, in metres.
    public let gridWidth: Double
    public let gridHeight: Double
    private let longitudeLength: CLLocationDegrees
    private let latitudeLength: CLLocationDegrees

    /// Get CLLocationDegree representing a unit of gridHeight.
    static func getLatitudeLength(_ gridHeight: Double) -> CLLocationDegrees {
        var low: CLLocationDegrees = 0
        var high: CLLocationDegrees = 90

        let origin = CLLocation(latitude: 0, longitude: 0)
        while low != high {
            let mid = low + (high - low) / 2
            let currLocation = CLLocation(latitude: mid, longitude: 0)
            let distance = currLocation.distance(from: origin)
            if distance - gridHeight < 0.000_1 {
                return mid
            } else if distance < gridHeight {
                low = mid
            } else {
                high = mid
            }
        }
        return -1
    }

    /// Get CLLocationDegree representing a unit of gridWidth.
    static func getLongitudeLength(_ gridWidth: Double) -> CLLocationDegrees {
        var low: CLLocationDegrees = 0
        var high: CLLocationDegrees = 180

        let origin = CLLocation(latitude: 0, longitude: 0)
        while low != high {
            let mid = low + (high - low) / 2
            let currLocation = CLLocation(latitude: 0, longitude: mid)
            let distance = currLocation.distance(from: origin)
            if distance - gridWidth < 0.000_1 {
                return mid
            } else if distance < gridWidth {
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
        longitudeLength = GridMap.getLongitudeLength(gridWidth)
        latitudeLength = GridMap.getLatitudeLength(gridHeight)
    }

    /// Get the id of the grid that `position` is in.
    ///
    /// - Parameter position: The position to look up.
    /// - Returns: The id of the grid that `position` is in.
    public func getGridId(_ position: CLLocationCoordinate2D) -> GridNumber {
        let long = position.longitude - (position.longitude.truncatingRemainder(dividingBy: longitudeLength))
        let lat = position.latitude - (position.latitude.truncatingRemainder(dividingBy: latitudeLength))
        return GridNumber(latitude: lat, longitude: long)
    }

    public func getBoundedGrid(_ bound: GridBound) -> [GridNumber] {
        var result = Set<GridNumber>()
        var smallLat = bound.minLat

        while smallLat < bound.maxLat {
            var smallLong = bound.minLong
            while smallLong < bound.maxLong {
                let currentGridId = getGridId(CLLocationCoordinate2D(latitude: smallLat, longitude: smallLong))
                result.insert(currentGridId)
                smallLong += longitudeLength / 2
            }
            smallLat += latitudeLength / 2
        }
        return Array(result)
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

    public init(topLeft: CLLocationCoordinate2D,
                topRight: CLLocationCoordinate2D,
                bottomLeft: CLLocationCoordinate2D,
                bottomRight: CLLocationCoordinate2D) {
        let latitudes = [topLeft.latitude, topRight.latitude, bottomLeft.latitude, bottomRight.latitude]
        let longitudes = [topLeft.longitude, topRight.longitude, bottomLeft.longitude, bottomRight.longitude]
        minLat = latitudes.min() ?? 0
        minLong = longitudes.min() ?? 0
        maxLat = latitudes.max() ?? 0
        maxLong = longitudes.max() ?? 0
    }

    public init(minLat: CLLocationDegrees,
                minLong: CLLocationDegrees,
                maxLat: CLLocationDegrees,
                maxLong: CLLocationDegrees) {
        self.minLat = minLat
        self.minLong = minLong
        self.maxLat = maxLat
        self.maxLong = maxLong
    }

    public var maxSide: CLLocationDegrees {
        return max(maxLat - minLat, maxLong - minLong)
    }

    public var diameter: CLLocationDistance {
        let pointX = CLLocationCoordinate2D(latitude: minLat, longitude: minLong)
        let pointY = CLLocationCoordinate2D(latitude: maxLat, longitude: maxLong)
        return pointX.distance(pointY)
    }
}

public struct GridNumber: Hashable {
    let latitude: CLLocationDegrees
    let longitude: CLLocationDegrees
    let code: String

    public init(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        self.latitude = latitude.roundTo(places: 4)
        self.longitude = longitude.roundTo(places: 4)
        code = GridNumber.encode(CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
    }

    public init(_ str: String) {
        code = str
        let position = GridNumber.decode(str)
        latitude = position.latitude
        longitude = position.longitude
    }

    static func encode(_ position: CLLocationCoordinate2D) -> String {
        return CLLocationCoordinate2D(latitude: position.latitude,
                                      longitude: position.longitude).geohash(precision: .seventyFourMillimeters)
    }

    static func decode(_ str: String) -> CLLocationCoordinate2D {
        let result = CLLocationCoordinate2D(geohash: str)
        return CLLocationCoordinate2D(latitude: result.latitude.roundTo(places: 4),
                                      longitude: result.longitude.roundTo(places: 4))
    }
}

extension Double {
    func roundTo(places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
