import Foundation
import GoogleMaps

/// Class to handle relation between GMSMarker and Route.
/// Used for caching of markers and handling of routes in the
/// view controller.
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
        guard markers.count < 20 else { // TODO
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
        resetMarkers()
        calibrateMarkers()
    }

    private func resetMarkers() {
        derenderMarkers()
        routesInMarker = [:]
        markers = Set()
    }

    private func calibrateMarkers() {
        for route in routes {
            var newRoutes = Set<Route>()
            newRoutes.insert(route)
            generateRouteMarker(routes: newRoutes)
        }
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
        marker.icon = UIImage(named: "\(17)") // TODO
        routesInMarker[marker] = routes
        markers.insert(marker)
    }
}
