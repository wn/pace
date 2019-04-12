import UIKit
import GoogleMaps

/// Subclass of GMSMapView to suit Pace's use case.
class MapView: GMSMapView {
    private var gridMapManager = Constants.defaultGridManager
    private var path = GMSMutablePath()
    private var currentMapPath: GMSPolyline?

    /// Setup the view
    ///
    /// - Parameter delegate: delegate of this view
    func setup(_ delegate: GMSMapViewDelegate) {
        animate(toZoom: Constants.initialZoom)
        isMyLocationEnabled = true
        settings.myLocationButton = true

        // Required to activate gestures in googleMapView
        settings.consumesGesturesInView = false
        self.delegate = delegate
        setMinZoom(Constants.minZoom, maxZoom: Constants.maxZoom)
    }

    /// Add an image to the map. Required to plot start and end flag.
    ///
    /// - Parameters:
    ///   - image: Image of marker.
    ///   - position: position to plot the image.
    internal func addMarker(_ image: String, position: CLLocationCoordinate2D) {
        let marker = GMSMarker(position: position)
        marker.map = self
        marker.icon = UIImage(named: image)
    }

    /// Add a position to the route and render it
    ///
    /// - Parameter position: the position to add to the route.
    func addPositionToRoute(_ position: CLLocationCoordinate2D) {
        path.add(position)
        currentMapPath?.map = nil
        drawRoute(path)
    }

    /// Function to prepare view to start the run.
    ///
    /// - Parameter position: the starting position of the run.
    func startRun(at position: CLLocationCoordinate2D) {
        clearRoutes()
        clear()
        path.add(position)
        addMarker(Constants.startFlag, position: position)
    }

    /// Function to prepare view to end the run.
    func completeRun() {
        clearRoutes()
        clear() // Required for clearing flags
    }

    /// Render the given route onto map view
    ///
    /// - Parameter route: the route that will be rendered.
    func renderRoute(_ route: Route) {
        clearRoutes()
        guard let locations = route.creatorRun?.locations else {
            print("No points exist in the route")
            return
        }
        for point in locations {
            path.add(point.coordinate)
        }
        drawRoute(path)
    }

    /// Helper function to draw the route onto the view.
    ///
    /// - Parameter path: the path to draw.
    private func drawRoute(_ path: GMSMutablePath) {
        let drawing = GMSPolyline(path: path)

        drawing.strokeColor = .blue
        drawing.strokeWidth = 5
        drawing.map = self

        currentMapPath = drawing
    }

    /// Clear the route's drawing from the map view.
    private func clearRoutes() {
        path.removeAllCoordinates()
        currentMapPath?.map = nil
        currentMapPath = nil
    }

    var viewingGrids: [GridNumber] {
        guard zoom > Constants.minZoomToShowRoutes else {
            return []
        }
        return gridMapManager.getBoundedGrid(projectedMapBound)
    }

    var zoom: Float {
        return camera.zoom
    }

    var projectedMapBound: GridBound {
        let topLeft = projection.visibleRegion().farLeft
        let topRight = projection.visibleRegion().farRight
        let bottomLeft = projection.visibleRegion().nearLeft
        let bottomRight = projection.visibleRegion().nearRight
        return GridBound(topLeft: topLeft, topRight: topRight, bottomLeft: bottomLeft, bottomRight: bottomRight)
    }
}
