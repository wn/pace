//
//  ActivityViewController+GMSMapDelegate.swift
//  Pace
//
//  Created by Ang Wei Neng on 15/4/19.
//  Copyright © 2019 nus.cs3217.pace. All rights reserved.
//

import GoogleMaps

// MARK: - GMSMapViewDelegate
extension ActivityViewController: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        guard let gMapView = mapView as? MapView else {
            return false
        }
        let gridNumber = gridMapManager.getGridId(zoom: mapView.zoom, position: marker.position)
        guard let routeMarkers = gridNumberAtZoomLevel[gMapView.nearestZoom]?[gridNumber] else {
            fatalError("Created marker should be associated to a routeHandler.")
        }
        guard let routes = routeMarkers.getRoutes(marker) else {
            gMapView.zoomIn()
            return false
        }
        renderRoutes(routes)
        return true
    }

    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        guard !runStarted, let map = mapView as? MapView else {
            return
        }
        print("ZOOM LEVEL IS \(mapView.zoom)")
        redrawMarkers(map.viewingGrids, zoomLevel: map.nearestZoom)
    }

    func didTapMyLocationButton(for mapView: GMSMapView) -> Bool {
        guard let location = coreLocationManager.location else {
            return false
        }
        mapView.showLocation(location.coordinate)
        return true
    }
}
