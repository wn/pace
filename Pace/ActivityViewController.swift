import UIKit
import GoogleMaps
import GooglePlaces
import AVFoundation
import RealmSwift

class ActivityViewController: UIViewController, MapViewiable {
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
    @IBOutlet var gpsIndicator: GpsStrengthIndicator!
    @IBOutlet var statsPanel: UIStackView!
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
    var gridMapManager = Constants.defaultGridManager
    var routesInGrid: [GridNumber: RouteMarkers] = [:]

    // MARK: Map variables
    @IBOutlet var googleMapView: MapView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupLocationManager()
        let mapViewDelegate = MapViewDelegate()
        mapViewDelegate.delegate = self
        googleMapView.setup(mapViewDelegate)
        googleMapView.delegate = mapViewDelegate
        print("FUCK")
        print(googleMapView.delegate)
        print(mapViewDelegate.delegate)
        notificationToken = routes.observe { [weak self]changes in
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
                        let newRoute = self?.routes[routeIndex],
                        let startLocation = newRoute.startingLocation?.coordinate,
                        let gridNumberForRoute = self?.gridMapManager.getGridId(startLocation)
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

    /// Set up location manager from CoreLocation.
    private func setupLocationManager() {
        coreLocationManager.delegate = self
        coreLocationManager.requestAlwaysAuthorization()
        coreLocationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        coreLocationManager.requestLocation()
//        while coreLocationManager.location == nil {
//            // Wait 1 second and check if location has been loaded.
//            // If location cannot be loaded, code here will never terminate
//            // TODO: FIX ABOVE
//            sleep(1)
//        }
//        guard let location = coreLocationManager.location else {
//            fatalError("While loop should have captured nil value!")
//        }
//        googleMapView.setCameraPosition(location.coordinate)
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

    func redrawMarkers() {
        let grids = googleMapView.viewingGrids
        renderRouteMarkers(grids)
        fetchRoutes(grids)
    }

    private func fetchRoutes(_ gridNumbers: [GridNumber]) {
        for gridNumber in gridNumbers where routesInGrid[gridNumber] == nil {
            let bound = gridMapManager.getBounds(gridId: gridNumber)
            routesManager.fetchRoutesWithin(
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

    private func renderRouteMarkers(_ gridNumbers: [GridNumber]) {
        for gridNumber in gridNumbers {
            guard let routeMarker = routesInGrid[gridNumber] else {
                print("NO markers rendered in gridNumber")
                continue
            }
            routeMarker.renderMarkers()
        }
    }
}

// MARK: - GMSMapViewDelegate
extension ActivityViewController {
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
