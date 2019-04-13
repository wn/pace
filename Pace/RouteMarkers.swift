import Foundation
import GoogleMaps


/// Class to handle relation between GMSMarker and Route.
/// Used for caching of markers and handling of routes in the
/// view controller.
class RouteMarkers {
    var routes = Set<Route>()
    var markers: [GMSMarker] {
        return Array(routesInMarker.keys)
    }
    var routesInMarker: [GMSMarker: Set<Route>] = [:]
    let map: MapView

    init(map: MapView) {
        self.map = map
    }

    func insertRoute(_ route: Route) {
        routes.insert(route)
        var newRoutes = Set<Route>()
        newRoutes.insert(route)
        generateRouteMarker(routes: newRoutes)
        recalibrateMarkers()
    }

    func getRoutes(_ marker: GMSMarker) -> Set<Route>? {
        return routesInMarker[marker]
    }

    /// Derender all markers and resplit them
    func recalibrateMarkers() {
        resetMarkers()
        calibrateMarkers()
        setImage()
        print("Recalibrated")
    }

    private func setImage() {
        for (marker, routes) in routesInMarker {
            let count = routes.count
            if count < 18 {
                marker.icon = UIImage(named: "\(routes.count)")
            } else {
                marker.icon = UIImage(named: Constants.startFlag)
            }
        }
    }

    private func resetMarkers() {
        derenderMarkers()
        map.clear()
        routesInMarker = [:]
    }

    private func calibrateMarkers() {
        let collapseLength = map.diameter / 20
        print(collapseLength)
        for route in routes {
            if let nearestMarker = getNearestMarker(route.startingLocation!.coordinate, dist: collapseLength) {
                routesInMarker[nearestMarker]!.insert(route)
                print("YAY")
            } else {
                var newRoutes = Set<Route>()
                newRoutes.insert(route)
                generateRouteMarker(routes: newRoutes)
            }
        }
    }

    private func getNearestMarker(_ point: CLLocationCoordinate2D, dist minDist: CLLocationDegrees) -> GMSMarker? {
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

    func renderMarkers() {
        markers.forEach { $0.map = map }
    }

    func derenderMarkers() {
        markers.forEach { $0.map = nil }
    }

    func generateRouteMarker(routes: Set<Route>) {
        guard let location = routes.first?.startingLocation else {
            return
        }
        let marker = GMSMarker(position: location.coordinate)
        routesInMarker[marker] = routes
    }
}

extension CLLocationCoordinate2D {
    func distance(_ point: CLLocationCoordinate2D) -> CLLocationDistance {
        let locationX = CLLocation(latitude: latitude, longitude: longitude)
        let locationY = CLLocation(latitude: point.latitude, longitude: point.longitude)
        return locationX.distance(from: locationY)
    }
}
