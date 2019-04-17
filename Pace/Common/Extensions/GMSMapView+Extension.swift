//
//  GMSMapView+Extension.swift
//  Pace
//
//  Created by Ang Wei Neng on 27/3/19.
//  Copyright © 2019 nus.cs3217.pace. All rights reserved.
//

import GoogleMaps

extension GMSMapView {
    var zoom: Float {
        return camera.zoom
    }

    /// Set the camera position of mapView
    ///
    /// - Parameter coordinate: The coordinate that mapView will be centered on.
    func setCameraPosition(_ coordinate: CLLocationCoordinate2D) {
        // The following is to ensure that we do not change users viewing
        // specification while updating location. Done by reusing the old zoom,
        // bearing and angle.
        let mapZoom = self.camera.zoom
        let mapBearing = self.camera.bearing
        let mapViewAngle = self.camera.viewingAngle

        self.camera = GMSCameraPosition(
            target: coordinate,
            zoom: mapZoom,
            bearing: mapBearing,
            viewingAngle: mapViewAngle)
    }

    func zoomIn() {
        animate(toZoom: zoom + 1)
    }

    func showLocation(_ position: CLLocationCoordinate2D, zoom: Float = Constants.initialZoom) {
        setCameraPosition(position)
        animate(toZoom: zoom)
    }
}
