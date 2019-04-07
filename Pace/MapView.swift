//
//  MapView.swift
//  Pace
//
//  Created by Ang Wei Neng on 5/4/19.
//  Copyright © 2019 nus.cs3217.pace. All rights reserved.
//

import UIKit
import GoogleMaps

class MapView: GMSMapView {
    func setup() {
        animate(toZoom: Constants.initialZoom)
        isMyLocationEnabled = true
        settings.myLocationButton = true

        // Required to activate gestures in googleMapView
        settings.consumesGesturesInView = false
        setMinZoom(Constants.minZoom, maxZoom: Constants.maxZoom)
    }

    func generateRouteMarker(location: CLLocation, count: Int) -> GMSMarker {
        let marker = GMSMarker(position: location.coordinate)
        marker.map = self
        marker.icon = UIImage(named: "\(count)")
        return marker
    }

    func drawPath(path: GMSPath) {
        let mapPaths = GMSPolyline(path: path)
        mapPaths.strokeColor = .blue
        mapPaths.strokeWidth = 5
        mapPaths.map = self
    }
}
