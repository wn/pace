//
//  GMSCameraPosition+Extension.swift
//  Pace
//
//  Created by Tan Zheng Wei on 6/4/19.
//  Copyright © 2019 nus.cs3217.pace. All rights reserved.
//

import Foundation
import RealmSwift
import GoogleMaps

extension GMSCameraPosition {
    var asRealmObject: RealmGMSCameraPosition {
        return RealmGMSCameraPosition(self)
    }
}

class RealmGMSCameraPosition: Object {
    @objc dynamic var latitude: Double = 0.0
    @objc dynamic var longitude: Double = 0.0
    @objc dynamic var zoom: Float = 0.0
    @objc dynamic var bearing: CLLocationDirection = 0.0
    @objc dynamic var angle: Double = 0.0

    convenience init(_ camPos: GMSCameraPosition) {
        self.init()
        latitude = camPos.target.latitude
        longitude = camPos.target.longitude
        zoom = camPos.zoom
        bearing = camPos.bearing
        angle = camPos.viewingAngle
    }

    var asGMSCameraPosition: GMSCameraPosition {
        return GMSCameraPosition(latitude: latitude,
                                 longitude: longitude,
                                 zoom: zoom,
                                 bearing: bearing,
                                 viewingAngle: angle)
    }
}
