//
//  RouteMarkers.swift
//  Pace
//
//  Created by Ang Wei Neng on 10/4/19.
//  Copyright © 2019 nus.cs3217.pace. All rights reserved.
//

import Foundation
import GoogleMaps

class RouteMarkers {
    var routes = Set<Route>()
    var markers = Set<GMSMarker>()
    var routesInMarker: [GMSMarker: Set<Route>] = [:]
    let map: MapView

    init(map: MapView) {
        self.map = map
    }

    func insertRoute(_ route: Route) {
        routes.insert(route)
        guard markers.count < 20 else {
            recalibrateMarkers()
            return
        }
        var newRoutes = Set<Route>()
        newRoutes.insert(route)
        generateRouteMarker(routes: newRoutes)
    }

    func getRoutes(_ marker: GMSMarker) -> Set<Route>? {
        return routesInMarker[marker]
    }

    /// Derender all markers and resplit them
    func recalibrateMarkers() {
        for marker in markers {
            marker.map = nil
        }
        routesInMarker = [:]
        markers = Set()

        // recalibration
        for route in routes {
            var newRoutes = Set<Route>()
            newRoutes.insert(route)
            generateRouteMarker(routes: newRoutes)
        }
    }

    func derenderMarkers() {
        markers.forEach { $0.map = nil }
    }

    func renderMarkers() {
        markers.forEach { $0.map = map }
    }

    func generateRouteMarker(routes: Set<Route>) {
        guard let location = routes.first?.startingLocation else {
            return
        }
        let marker = GMSMarker(position: location.coordinate)
        marker.icon = UIImage(named: "\(17)") // TODO
        routesInMarker[marker] = routes
        markers.insert(marker)
    }
}
