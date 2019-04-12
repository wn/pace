import UIKit
import GoogleMaps

class MapViewDelegate: NSObject, GMSMapViewDelegate {
    var gridMapManager = Constants.defaultGridManager
    let delegate: MapViewiable

    init(_ delegate: MapViewiable) {
        self.delegate = delegate
    }

    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        let gridNumber = gridMapManager.getGridId(marker.position)
        guard
            let routeMarkers = delegate.routesInGrid[gridNumber],
            let routes = routeMarkers.getRoutes(marker)
            else {
                fatalError("Created marker should be associated to a route.")
        }
        delegate.renderRoute(routes)
        return true
    }

    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        guard !delegate.runStarted else {
            print(1)
            // If run has started, we do not perform any action.
            return
        }
        guard mapView.camera.zoom > Constants.minZoomToShowRoutes else {
            print(2)
            mapView.clear()
            if let drawer = delegate.currentDrawer {
                print(3)
                delegate.removePullUpController(drawer, animated: true)
            }
            print("ZOOM LEVEL: \(mapView.camera.zoom) | ZOOM IN TO VIEW MARKERS")
            return
        }
        delegate.redrawMarkers()
    }

    func didTapMyLocationButton(for mapView: GMSMapView) -> Bool {
        guard let location = location else {
            print(4)
            return false
        }
        mapView.setCameraPosition(location.coordinate)
        mapView.animate(toZoom: Constants.initialZoom)
        return true
    }

    var location: CLLocation? {
        return delegate.coreLocationManager.location
    }
}

protocol MapViewiable {
    var runStarted: Bool {get}
    func renderRoute(_ routes: Set<Route>)
    func redrawMarkers()
    var currentDrawer: DrawerViewController? {get}
    var coreLocationManager: CLLocationManager {get}
    func removePullUpController(_: PullUpController, animated: Bool)
    var routesInGrid: [GridNumber: RouteMarkers] {get}
}
