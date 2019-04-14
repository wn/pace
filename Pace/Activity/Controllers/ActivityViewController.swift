import UIKit
import GoogleMaps
import GooglePlaces
import AVFoundation
import RealmSwift

class ActivityViewController: UIViewController {
    // MARK: Realm variables
    let userSession = RealmUserSessionManager.forDefaultRealm
    let routesManager = CachingStorageManager.default
    let routes = CachingStorageManager.default.inMemoryRealm.objects(Route.self)
    var notificationToken: NotificationToken?
    var isConnectedToInternet = true

    // MARK: Drawer variable
    var originalPullUpControllerViewSize: CGSize = .zero

    // MARK: UIVariable
    @IBAction private func endRunButton(_ sender: UIButton) {
        endRun(sender)
    }

    @IBOutlet private var distanceLabel: UILabel!
    @IBOutlet private var paceLabel: UILabel!
    @IBOutlet private var timeLabel: UILabel!
    @IBOutlet private var gpsIndicator: GpsStrengthIndicator!
    @IBOutlet private var statsPanel: UIStackView!
    let mapButton = UIButton(frame: CGRect(x: 0, y: 0, width: 75, height: 75))

    // MARK: Running variables
    var lastMarkedPosition: CLLocation?
    var distance: CLLocationDistance = 0 // TODO: REMOVE
    let stopwatch = StopwatchTimer() // TODO: REMOVE
    var ongoingRun: OngoingRun?
    var runStarted: Bool {
        return ongoingRun != nil
    }

    // Location Manager
    let coreLocationManager = CLLocationManager()

    // MARK: Map variables
    @IBOutlet var googleMapView: MapView!
    var gridNumberAtZoomLevel: [Int: [GridNumber: RouteMarkerHandler]] = Constants.zoomLevels.reduce(into: [:]) { $0[$1] = [:] }
    var renderedRouteMarkers: [RouteMarkerHandler] = []
    var getRouteMarkers: [GridNumber: RouteMarkers] {
        guard let result = gridNumberAtZoomLevel[maxZoom] as? [GridNumber: RouteMarkers] else {
            return [:]
        }
        return result
    }
    var maxZoom = Constants.maxZoom






    private func insertRoute(route: Route) {
        // we insert the route to every zoom level for aggregated viewing of routes.
        Array(gridNumberAtZoomLevel.keys).forEach { insertRouteToZoomLevel(route: route, zoomLevel: $0) }
    }

    private func insertRouteToZoomLevel(route: Route, zoomLevel: Int) {
        guard let startPoint = route.startingLocation?.coordinate else {
            return
        }
        let gridManager = googleMapView.getGridManager(Float(zoomLevel))
        let gridId = gridManager.getGridId(startPoint)
        if gridNumberAtZoomLevel[zoomLevel]?[gridId] == nil {
            if zoomLevel == maxZoom {
                gridNumberAtZoomLevel[zoomLevel]?[gridId] = RouteMarkers(map: googleMapView)
            } else {
                gridNumberAtZoomLevel[zoomLevel]?[gridId] = RouteCounterMarkers(position: startPoint, map: googleMapView)
            }
        }
        guard let routeCountMarker = gridNumberAtZoomLevel[zoomLevel]?[gridId] else {
            fatalError("gridId must exist in routesInZoomGrids, based on above if-statement!")
        }
        routeCountMarker.insertRoute(route)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = Titles.activity
        setupLocationManager()
        googleMapView.setup(self)
        notificationToken = routes.observe { [weak self]changes in
            switch changes {
            case .initial:
                break
            case .update(_, _, let insertions, _):
                for routeIndex in insertions {
                    guard let newRoute = self?.routes[routeIndex] else {
                        continue
                    }
                    self?.insertRoute(route: newRoute)
                }
            case .error:
                print("FUCKING ERROR")
            }
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        renderMapButton()
        setMapButton(imageUrl: Constants.startButton, action: #selector(startRun(_:)))
    }

    private func renderRoutes(_ routes: Set<Route>) {
        // TODO: Render routes as a tableview
        let route = routes.first!
        renderRoute(route)
    }

    private func renderRoute(_ route: Route) {
        googleMapView.renderRoute(route)
        showPullUpController()
        pullUpDrawer.routeStats(route)
    }

    /// Set up location manager from CoreLocation.
    private func setupLocationManager() {
        coreLocationManager.delegate = self
        coreLocationManager.requestAlwaysAuthorization()
        coreLocationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        coreLocationManager.requestLocation()
        while coreLocationManager.location == nil {
            // Wait 1 second and check if location has been loaded.
            // If location cannot be loaded, code here will never terminate
            // TODO: FIX ABOVE
            sleep(1)
        }
        guard let location = coreLocationManager.location else {
            fatalError("While loop should have captured nil value!")
        }
        googleMapView.setCameraPosition(location.coordinate)
    }

    func updateDistanceTravelled() {
        distanceLabel.text = "Distance: \(Int(distance)) metres"
    }

    func updateTimer() {
        self.timeLabel.text = "time elapsed: \(self.stopwatch.timeElapsed) secs"
    }

    func updatePace() {
        let paceValue = distance != 0 ? 1_000 * stopwatch.timeElapsed / distance : 0
        paceLabel.text = "Pace: \(paceValue) seconds /km"
    }

    private func redrawMarkers() {
        let grids = googleMapView.viewingGrids
        print(grids.count)
        renderRouteMarkers(grids)
        fetchRoutes(grids)
    }

    /// We only request for routes above our zoom level!
    /// We should not request for routes below our zoom level as it will bloat our
    /// memory when we zoom out to the whole world.
    private func fetchRoutes(_ gridNumbers: [GridNumber]) {
        routesManager.fetchRoutesWithin(
            latitudeMin: -90,
            latitudeMax: 90,
            longitudeMin: -180,
            longitudeMax: 180) {
            if let error = $0 {
                print(error.localizedDescription)
            }
        }

//        for gridNumber in gridNumbers where routesInGrid[gridNumber] == nil {
//            let bound = gridMapManager.getBounds(gridId: gridNumber)
//            routesManager.fetchRoutesWithin(
//                latitudeMin: bound.minLat,
//                latitudeMax: bound.maxLat,
//                longitudeMin: bound.minLong,
//                longitudeMax: bound.maxLong) {
//                if let error = $0 {
//                    print(error.localizedDescription)
//                }
//            }
//        }
    }

    private func renderRouteMarkers(_ gridNumbers: [GridNumber]) {
        renderedRouteMarkers.forEach { $0.derender() }
        renderedRouteMarkers = []
        let allGridNumbers = gridNumberAtZoomLevel[googleMapView.nearestZoom]!
        for gridNumber in gridNumbers {
            guard let routeMarker = allGridNumbers[gridNumber] else {
                continue
            }
            routeMarker.render()
            renderedRouteMarkers.append(routeMarker)
        }












//        for gridNumber in gridNumbers {
//            guard let routeMarker = routesInGrid[gridNumber] else {
//                print("NO markers rendered in gridNumber")
//                continue
//            }
//            routeMarker.render()
//        }
    }
}

// MARK: - GMSMapViewDelegate
extension ActivityViewController: GMSMapViewDelegate {
    private func renderMapButton() {
        let startXPos = googleMapView.layer.frame.midX
        let startYPos = googleMapView.frame.height - mapButton.frame.height
        mapButton.center = CGPoint(x: startXPos, y: startYPos)
        googleMapView.addSubview(mapButton)
        googleMapView.bringSubviewToFront(mapButton)
    }

    func setMapButton(imageUrl: String, action: Selector) {
        mapButton.removeTarget(nil, action: nil, for: .allEvents)
        let startImage = UIImage(named: imageUrl)
        mapButton.setImage(startImage, for: .normal)
        mapButton.addTarget(self, action: action, for: .touchUpInside)
    }

    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        let gridManager = googleMapView.getGridManager(mapView.zoom)
        let gridNumber = gridManager.getGridId(marker.position)
        guard
            let routeMarkers = getRouteMarkers[gridNumber]
            else {
                print(getRouteMarkers)
                fatalError("Created marker should be associated to a route.")
        }
        guard let routes = routeMarkers.getRoutes(marker) else {
            googleMapView.zoomIn()
            return false
        }
        renderRoutes(routes)
        return true
    }

    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        guard !runStarted else {
            return
        }
        print("zoom level: \(mapView.zoom)")
        redrawMarkers()
    }

    func didTapMyLocationButton(for mapView: GMSMapView) -> Bool {
        guard let location = coreLocationManager.location else {
            return false
        }
        showPosition(location.coordinate)
        return true
    }

    func showPosition(_ position: CLLocationCoordinate2D) {
        googleMapView.setCameraPosition(position)
        googleMapView.animate(toZoom: Constants.initialZoom)
    }
}

// MARK: - CLLocationManagerDelegate
extension ActivityViewController: CLLocationManagerDelegate {
    /// Function from CLLocationManagerDelegate.
    /// Check if there was any change to the authorization level
    /// for location and handle the change.
    ///
    /// - Parameters:
    ///   - manager: The location manager for the view-controller.
    ///   - status: The newly set location authorization level.
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            return
        }
        coreLocationManager.requestWhenInUseAuthorization()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard runStarted, let location = locations.last else {
            return
        }
        //        if isMapLock {
        //            // Set to current location
        //            googleMapView.setCameraPosition(location.coordinate)
        //            googleMapView.animate(toZoom: Constants.initialZoom)
        //        }
        let accuracy = location.horizontalAccuracy
        gpsIndicator.setStrength(accuracy)
        guard accuracy < Constants.guardAccuracy else {
            return
        }
        ongoingRun?.addNewLocation(location, atTime: stopwatch.timeElapsed)
        googleMapView.addPositionToRoute(location.coordinate)
    }

    /// Function from CLLocationManagerDelegate.
    /// Function to handle failure in retrieving location.
    ///
    /// - Parameters:
    ///   - manager: The location manager for the view-controller.
    ///   - error: Error message.
    func locationManager(_ manager: CLLocationManager,
                         didFailWithError error: Error) {
        gpsIndicator.setStrength(-1)
    }
}
