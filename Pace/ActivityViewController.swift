//
//  RunningViewController.swift
//  Pace
//
//  Created by Ang Wei Neng on 27/3/19.
//  Copyright © 2019 nus.cs3217.pace. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import AVFoundation
import RealmSwift

class ActivityViewController: UIViewController {
    // MARK: Realm variables
    var userSession: UserSessionManager?
    var routesManager: RealmStorageManager?
    var routes: Results<Route>?
    var notificationToken: NotificationToken?
    var isConnectedToInternet = true

    // MARK: Drawer variable
    var originalPullUpControllerViewSize: CGSize = .zero

    // MARK: UIVariable
    @IBAction func endRunButton(_ sender: UIButton) {
        endRun(sender)
    }
    @IBOutlet var distanceLabel: UILabel!
    @IBOutlet var pace: UILabel!
    @IBOutlet var time: UILabel!
    let mapButton = UIButton(frame: CGRect(x: 0, y: 0, width: 75, height: 75))

    // MARK: Running variables
    var path = GMSMutablePath()
    var currentMapPath: GMSPolyline?
    var lastMarkedPosition: CLLocation?
    var distance: CLLocationDistance = 0
    let stopwatch = StopwatchTimer()
    var ongoingRun: OngoingRun?
    var runStarted: Bool {
        return stopwatch.isPlaying
    }

    private var _isConnected = true
    var isConnected: Bool {
        // Make into a GPS symbol instead
        get {
            return _isConnected
        }
        set (value) {
            let connected = _isConnected == false && value == true
            let disconnected = _isConnected == true && value == false

            if connected {
                VoiceAssistant.say("Reconnected to GPS!")
                print("CONNECTED")
            } else if disconnected {
                VoiceAssistant.say("GPS signal lost!")
                print("DISCONNECTED")
            }
            _isConnected = value
        }
    }

    // MARK: Map variables
    let coreLocationManager = CLLocationManager()
    var gridMapManager = Constants.defaultGridManager
    @IBOutlet private var googleMapView: GMSMapView!
    // routesInGrid keeps track of all routes in a grid
    // markers keeps track of all created markers. Each markers represent
    // a certain number of routes that it represents, depending on how the routes are aggregated.
    // When there is new routes created in a grid, we recalculate the GMSMarker
    // locations.
    // TODO: Abstract it to GMSView
    var routesInGrid: [GridNumber: RouteMarkers] = [:]
    var markers: [GMSMarker: Int] = [:]
    // Put in map
    var viewingGrids: [GridNumber] {
        guard googleMapView.camera.zoom > Constants.minZoomToShowRoutes else {
            return []
        }
        return gridMapManager?.getBoundedGrid(projectedMapBound) ?? []
    }

    var projectedMapBound: GridBound {
        let topLeft = googleMapView.projection.visibleRegion().farLeft
        let topRight = googleMapView.projection.visibleRegion().farRight
        let bottomLeft = googleMapView.projection.visibleRegion().nearLeft
        let bottomRight = googleMapView.projection.visibleRegion().nearRight
        return GridBound(topLeft: topLeft, topRight: topRight, bottomLeft: bottomLeft, bottomRight: bottomRight)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupLocationManager()
        setupMapView()
        // Init in variable? @julius
        routesManager = CachingStorageManager.default
        userSession = RealmUserSessionManager.forDefaultRealm
        routes = routesManager?.inMemoryRealm.objects(Route.self)
        notificationToken = routes?.observe { [weak self]changes in
            guard let map = self?.googleMapView else {
                print("MAP NOT RENDERED YET")
                return
            }
            switch changes {
            case .initial:
                break
            case .update(_, _, let insertions, _):
                // For each new route
                // 1. Get route from the index in `insertions`.
                // 2. Insert route into the specific gridNumber
                // 3. Create a marker for the route and insert into the specific gridNumber
                for routeIndex in insertions {
                    guard
                        let newRoute = self?.routes?[routeIndex],
                        let startLocation = newRoute.startingLocation?.coordinate,
                        let gridNumberForRoute = self?.gridMapManager?.getGridId(startLocation)
                        else {
                            continue
                    }
                    if self?.routesInGrid[gridNumberForRoute] == nil {
                        self?.routesInGrid[gridNumberForRoute] = RouteMarkers(map: map)
                    }
                    guard let routeMarkers = self?.routesInGrid[gridNumberForRoute] else {
                        return
                    }
                    routeMarkers.insertRoute(newRoute)
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

    /// Set up mapView view.
    private func setupMapView() {
        googleMapView.animate(toZoom: Constants.initialZoom)
        googleMapView.isMyLocationEnabled = true
        googleMapView.settings.myLocationButton = true

        // Required to activate gestures in googleMapView
        googleMapView.settings.consumesGesturesInView = false
        googleMapView.delegate = self
        googleMapView.setMinZoom(Constants.minZoom, maxZoom: Constants.maxZoom)
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

    func renderMarkers(_ gridNumbers: [GridNumber]) {
        for gridNumber in gridNumbers {
            guard let routeMarker = routesInGrid[gridNumber] else {
                print("NO markers rendered in gridNumber")
                continue
            }
            routeMarker.renderMarkers()
        }
    }

    func fetchNearbyRoutes(_ gridNumbers: [GridNumber]) {
        for gridNumber in gridNumbers where routesInGrid[gridNumber] == nil {
            guard let bound = gridMapManager?.getBounds(gridId: gridNumber) else {
                continue
            }
            routesManager?.fetchRoutesWithin(
                latitudeMin: bound.minLat,
                latitudeMax: bound.maxLat,
                longitudeMin: bound.minLong,
                longitudeMax: bound.maxLong) {
                if let error = $0 {
                    print(error.localizedDescription)
                }
            }
        }
    }

    func redrawMarkers() {
        renderMarkers(viewingGrids)
        fetchNearbyRoutes(viewingGrids)
    }
}

// MARK: - GMSMapViewDelegate
extension ActivityViewController: GMSMapViewDelegate {
    private func renderMapButton() {
        let startXPos = googleMapView.layer.frame.midX
        let startYPos = googleMapView.frame.height - mapButton.frame.height
        // mapButton.bounds = googleMapView.frame
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
        // TODO: On tap with marker, pop up route description
        guard
            let gridNumber = gridMapManager?.getGridId(marker.position),
            let routeMarkers = routesInGrid[gridNumber],
            let route = routeMarkers.getRoutes(marker)
            else {
                fatalError("Created marker should be associated to a route.")
        }
        // TODO: send correct stats to drawer
        print("MARKER PRESSED: \(route.first)")
        // TODO: GET ROUTE associated to marker
        renderDrawer()
        return true
    }

    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        print("ZOOM LEVEL: \(googleMapView.camera.zoom)")
        guard !runStarted else {
            // If run has started, we do not perform any action.
            return
        }
        // googleMapView.clear()
        guard googleMapView.camera.zoom > Constants.minZoomToShowRoutes else {
            print("ZOOM LEVEL: \(googleMapView.camera.zoom) | ZOOM IN TO VIEW MARKERS")
            return
        }
        redrawMarkers()
    }

    func didTapMyLocationButton(for mapView: GMSMapView) -> Bool {
        guard let location = coreLocationManager.location else {
            return false
        }
        mapView.setCameraPosition(location.coordinate)
        mapView.animate(toZoom: Constants.initialZoom)
        return true
    }

    func clearMap() {
        googleMapView.clear()
    }

    /// Add an image to the map. Required to plot start and end flag.
    ///
    /// - Parameters:
    ///   - image: Image of marker.
    ///   - position: position to plot the image.
    func addMarker(_ image: String, position: CLLocationCoordinate2D) {
        let marker = GMSMarker(position: position)
        marker.map = googleMapView
        marker.icon = UIImage(named: image)
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

    /// Function from CLLocationManagerDelegate.
    /// Empty function as we do not do anything about the
    /// location result.
    ///
    /// - Parameters:
    ///   - manager: The location manager for the view-controller.
    ///   - locations: The array of location updates that is not handled yet.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard runStarted, let location = locations.last else {
            return
        }
        //        if isMapLock {
        //            // Set to current location
        //            googleMapView.setCameraPosition(location.coordinate)
        //            googleMapView.animate(toZoom: Constants.initialZoom)
        //        }
        guard let acc = coreLocationManager.location?.horizontalAccuracy, acc < Constants.guardAccuracy else {
            // Our accuracy is too poor, assume connection has failed.
            isConnected = false
            return
        }
        isConnected = true
        if let lastMarkedPosition = lastMarkedPosition {
            let distanceMoved = location.distance(from: lastMarkedPosition)
            print("Distance =  \(distanceMoved)")
            distance += distanceMoved
        }
        lastMarkedPosition = location

        let coordinate = location.coordinate
        path.add(location.coordinate)

        // TODO: We redraw the whole map again. is this good?
        // Or can we dynamically generate the map without mutablepath
        //googleMapView.clear()
        currentMapPath?.map = nil
        currentMapPath = GMSPolyline(path: path)
        currentMapPath?.strokeColor = .blue
        currentMapPath?.strokeWidth = 5
        currentMapPath?.map = googleMapView

        // position.text = "lat: \(coordinate.latitude), long: \(coordinate.longitude)"
    }

    /// Function from CLLocationManagerDelegate.
    /// Function to handle failure in retrieving location.
    ///
    /// - Parameters:
    ///   - manager: The location manager for the view-controller.
    ///   - error: Error message.
    func locationManager(_ manager: CLLocationManager,
                         didFailWithError error: Error) {
        isConnected = false
    }
}

class RouteMarkers {
    var routes = Set<Route>()
    var markers = Set<GMSMarker>()
    var routesInMarker: [GMSMarker: Set<Route>] = [:]
    let map: GMSMapView

    init(map: GMSMapView) {
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
