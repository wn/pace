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
    var routesManager: StorageManager?
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
    var currentRoute: Route? = nil
    var currentRun: Run? = nil
    var path = GMSMutablePath()
    var lastMarkedPosition: CLLocation?
    var distance: CLLocationDistance = 0
    let stopwatch = StopwatchTimer()
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
    var gridMapManager = GridMap(width: 300, height: 300)
    @IBOutlet private var googleMapView: GMSMapView!
    // routesInGrid keeps track of all routes in a grid
    // markers keeps track of all created markers. Each markers represent
    // a certain number of routes that it represents, depending on how the routes are aggregated.
    // When there is new routes created in a grid, we recalculate the GMSMarker
    // locations.
    // TODO: Abstract it to GMSView
    var routesInGrid: [GridNumber: Set<Route>] = [:]
    var markersInGrid: [GridNumber: Set<GMSMarker>] = [:]
    var markers: [GMSMarker: Int] = [:]
    // Put in map
    var viewingGrids: [GridNumber] {
        return gridMapManager?.getBoundedGrid(projectedMapView) ?? []
    }

    var projectedMapView: GridBound {
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
        routesManager = RealmStorageManager.default
        userSession = RealmUserSessionManager.forDefaultRealm
        routes = Realm.inMemory.objects(Route.self)
        notificationToken = routes?.observe { [weak self](changes) in
            switch changes {
            case .initial(_):
                //self?.requestForRoutes(self?.viewingGrids ?? [])
                break
            case .update(_, let deletions, let insertions, let modifications):
                var newRoutes = [Route]()
                for routeIndex in insertions {
                    guard let newRoute = self?.routes?[routeIndex] else {
                        continue
                    }
                    newRoutes.append(newRoute)
                }
                print(newRoutes)
                print(deletions)
                print(modifications)
            case .error(_):
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
//        while locationManager.location == nil {
//            // Wait 1 second and check if location has been loaded.
//            // If location cannot be loaded, code here will never terminate
//            // TODO: FIX ABOVE
//            sleep(1)
//        }
//        guard let location = locationManager.location else {
//            fatalError("While loop should have captured nil value!")
//        }
//        googleMapView.setCameraPosition(location.coordinate)
    }

    func fetchNearbyRoutes() {
        let topLeft = googleMapView.projection.visibleRegion().farLeft
        let bottomRight = googleMapView.projection.visibleRegion().nearRight

        // Bounds of maps to retrieve
        let top = topLeft.latitude
        let bottom = bottomRight.latitude
        let left = topLeft.longitude
        let right = bottomRight.longitude

        // TODO: Fake data. To draw real data here instead
        /*
        let one = CLLocation(latitude: bottom + 0.001, longitude: left)
        let two = CLLocation(latitude: bottom + 0.000_5, longitude: left)
        let three = CLLocation(latitude: top - 0.001, longitude: right)
        let four = CLLocation(latitude: top - 0.000_5, longitude: right)
        return [one, two, three, four]
         */

        routesManager?.fetchRoutesWithin(latitudeMin: top, latitudeMax: bottom, longitudeMin: left, longitudeMax: right) {
            if let error = $0 {
                print(error.localizedDescription)
            }
        }
    }

    func redrawMarkers() {
        guard !runStarted else {
            return
        }
        googleMapView.clear()
        markers = [:]
        guard googleMapView.camera.zoom > Constants.minZoomToShowRoutes else {
            return
        }

        // TODO: Get all potential markers and generate them.
        // Get marker nearby location

        // BELOW IS THE REAL CODE FOR GET NEARBY ROUTES.
        //        routesManager.getRoutesNear(location: location) { (routes, error) -> Void in
        //            self?.markers = [:]
        //            for index in 0..<routes.count {
        //                // Count is the number of routes that the marker represents
        //                // Set as 17 as that is the name of the image
        //                let count = 17
        //                let marker = self.generateRouteMarker(location: routes[index], count: count)
        //                self.markers[marker] = index
        //            }
        //        }

        // TODO: STUB - TO REMOVE
        guard let routes = routes else {
            return
        }
        let count = 17
        let routeMarkers = Array(routes.compactMap { route in
            self.generateRouteMarker(location: route.startingLocation, count: count)
        })
        markers = Dictionary(uniqueKeysWithValues: zip(routeMarkers, [Int](0..<routeMarkers.count)))
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
        guard let markerID = markers[marker] else {
            redrawMarkers()
            return false
        }
        // TODO: send correct stats to drawer
        print("MARKER PRESSED: \(markerID)")
        // TODO: GET ROUTE associated to marker
        renderDrawer()
        return true
    }

    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        fetchNearbyRoutes()
    }

    func didTapMyLocationButton(for mapView: GMSMapView) -> Bool {
        guard let location = coreLocationManager.location else {
            return false
        }
        mapView.setCameraPosition(location.coordinate)
        mapView.animate(toZoom: Constants.initialZoom)
        return true
    }

    func addMarker(_ image: String, position: CLLocationCoordinate2D) {
        let marker = GMSMarker(position: position)
        marker.map = googleMapView
        marker.icon = UIImage(named: image)
    }

    func clearMap() {
        googleMapView.clear()
    }

    func generateRouteMarker(location: CLLocation?, count: Int) -> GMSMarker? {
        guard let location = location else {
            return nil
        }
        let marker = GMSMarker(position: location.coordinate)
        marker.map = googleMapView
        marker.icon = UIImage(named: "\(count)")
        return marker
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
        guard runStarted else {
            return
        }
        guard let location = locations.last else {
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
        } else {
            // First time getting a location
            addMarker(Constants.startFlag, position: location.coordinate)
        }
        lastMarkedPosition = location

        let coordinate = location.coordinate
        path.add(CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude))

        // TODO: We redraw the whole map again. is this good?
        // Or can we dynamically generate the map without mutablepath
        //googleMapView.clear()
        let mapPaths = GMSPolyline(path: path)
        mapPaths.strokeColor = .blue
        mapPaths.strokeWidth = 5
        mapPaths.map = googleMapView

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
