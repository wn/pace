import GoogleMaps

class RouteCounterMarkers: RouteMarkerHandler {

    var marker: GMSMarker
    var counter = 0
    var map: MapView

    init(position: CLLocationCoordinate2D, map: MapView) {
        marker = GMSMarker(position: position)
        self.map = map
    }

    func getRoutes(_: GMSMarker) -> Set<Route>? {
        return nil
    }

    func insertRoute(_ route: Route) {
        counter += 1
    }

    func render() {
        marker.map = map
        if counter == 12 {
            marker.icon = UIImage(named: Constants.startFlag)
        } else if counter < 18 {
            marker.icon = UIImage(named: "\(counter)")
        } else {
            marker.icon = UIImage(named: Constants.startFlag)
        }
    }

    func derender() {
        marker.map = nil
    }
}

protocol RouteMarkerHandler {
    func render()
    func derender()
    func insertRoute(_ route: Route)
    func getRoutes(_: GMSMarker) -> Set<Route>?
}
