import GoogleMaps

class RouteCounterMarkers: RouteMarkerHandler {

    var marker: GMSMarker
    var counter = 0
    var map: MapView

    init(position: CLLocationCoordinate2D, map: MapView, count: Int = 0) {
        marker = GMSMarker(position: position)
        self.map = map
        counter = count
    }

    func getRoutes(_: GMSMarker) -> Set<Route>? {
        return nil
    }

    func insertRoute(_ route: Route? = nil) {
        counter += 1
    }

    func render() {
        guard counter > 0 else {
            return
        }
        marker.map = map
        if counter < 18 {
            marker.icon = UIImage(named: "\(counter)")
        } else {
            marker.icon = UIImage(named: Images.asterick)
        }
    }

    func derender() {
        marker.map = nil
    }
}

protocol RouteMarkerHandler {
    func render()
    func derender()
    func insertRoute(_ route: Route?)
    func getRoutes(_: GMSMarker) -> Set<Route>?
}
