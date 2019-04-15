import GoogleMaps

/// Class to handle relation between GMSMarker and Route.
/// Used for caching of markers and handling of routes in the
/// view controller.
class RouteMarkers: RouteMarkerHandler {
    private var routes = Set<Route>()
    private var markers: [GMSMarker] {
        return Array(routesInMarker.keys)
    }
    private var routesInMarker: [GMSMarker: Set<Route>] = [:]
    private let map: MapView

    init(map: MapView) {
        self.map = map
    }

    private func canSplit(_ marker: GMSMarker) -> Bool {
        guard let routes = routesInMarker[marker] else {
            return false
        }
        let arr = Array(routes)
        for indexI in 0..<arr.count {
            for indexJ in (indexI + 1)..<arr.count {
                guard
                    let startI = arr[indexI].startingLocation,
                    let startJ = arr[indexJ].startingLocation else {
                    return false
                }
                if startI.distance(from: startJ) > 75 {
                    return true
                }
            }
        }
        return false
    }

    func insertRoute(_ route: Route) {
        routes.insert(route)
    }

    func getRoutes(_ marker: GMSMarker) -> Set<Route>? {
        guard !canSplit(marker) else {
            return nil
        }
        return routesInMarker[marker]
    }

    /// Derender all markers and resplit them
    func recalibrateMarkers() {
        resetMarkers()
        calibrateMarkers()
        setImage()
    }

    private func resetMarkers() {
        derender()
        routesInMarker = [:]
    }

    private func calibrateMarkers() {
        let collapseLength = map.diameter / 10
        for route in routes {
            if let nearestMarker = getNearestMarker(route.startingLocation!.coordinate, dist: collapseLength) {
                routesInMarker[nearestMarker]!.insert(route)
            } else {
                var newRoutes = Set<Route>()
                newRoutes.insert(route)
                generateRouteMarker(routes: newRoutes)
            }
        }
    }

    private func setImage() {
        for (marker, markerRoutes) in routesInMarker {
            let count = markerRoutes.count
            if count < 18 {
                marker.icon = UIImage(named: "\(markerRoutes.count)")
            } else {
                marker.icon = UIImage(named: Constants.endFlag)
            }
        }
    }

    private func getNearestMarker(_ point: CLLocationCoordinate2D, dist minDist: CLLocationDistance) -> GMSMarker? {
        var nearestMarker: GMSMarker? = nil
        var distance: CLLocationDegrees = Double.infinity
        for (marker, _) in routesInMarker {
            let currentDistance = marker.position.distance(point)
            if currentDistance < distance {
                nearestMarker = marker
                distance = currentDistance
            }
        }
        guard distance < minDist else {
            return nil
        }
        return nearestMarker
    }

    func render() {
        recalibrateMarkers()
        markers.forEach { $0.map = map }
    }

    func derender() {
        markers.forEach { $0.map = nil }
    }

    func generateRouteMarker(routes: Set<Route>) {
        guard let location = routes.first?.startingLocation else {
            return
        }
        let marker = GMSMarker(position: location.coordinate)
        routesInMarker[marker] = routes
    }

    private func getCentroid(routes: Set<Route>) -> CLLocationCoordinate2D {
        var latSum: CLLocationDegrees = 0
        var longSum: CLLocationDegrees = 0
        for route in routes {
            guard let startPoint = route.startingLocation?.coordinate else {
                continue
            }
            latSum += startPoint.latitude
            longSum += startPoint.longitude
        }
        let count = Double(routes.count)
        return CLLocationCoordinate2D(latitude: latSum / count, longitude: longSum / count)
    }
}

extension CLLocationCoordinate2D {
    func distance(_ point: CLLocationCoordinate2D) -> CLLocationDistance {
        let locationX = CLLocation(latitude: latitude, longitude: longitude)
        let locationY = CLLocation(latitude: point.latitude, longitude: point.longitude)
        return locationX.distance(from: locationY)
    }
}
