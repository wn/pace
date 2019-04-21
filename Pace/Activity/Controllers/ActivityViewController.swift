import UIKit
import GoogleMaps
import GooglePlaces
import AVFoundation
import RealmSwift

class ActivityViewController: UIViewController {
    // MARK: Realm variables
    let userSession = RealmUserSessionManager.default
    let routesManager: RealmStorageManager = CachingStorageManager.default
    let runStateManager: RunStateManager = RealmRunStateManager.default
    lazy var routes = routesManager.inMemoryRealm.objects(Route.self)
    var notificationToken: NotificationToken?

    // MARK: Drawer variable
    var originalPullUpControllerViewSize: CGSize = .zero

    // MARK: UIVariable
    @IBOutlet var runStats: RunStatsView!
    @IBOutlet private var gpsIndicator: GpsStrengthIndicator!
    @IBOutlet private var statsPanel: UIStackView!
    let mapButton = UIButton(frame: CGRect(x: 0, y: 0, width: 75, height: 75))
    @IBAction private func endRunButton(_ sender: UIButton) {
        endRun(sender)
    }
    @IBAction func lockMap(_ sender: UIButton) {
        isMapLock = !isMapLock
        if googleMapView.isMapLock, let position = coreLocationManager.location?.coordinate {
            googleMapView.setCameraPosition(position)
        }
    }

    // MARK: Internet variable
    @IBOutlet private var internetIndicator: WifiIcon!
    var isConnectedToInternet = true {
        didSet {
            if isConnectedToInternet {
                internetIndicator.connected()
            } else {
                internetIndicator.disconnected()
            }
        }
    }

    // MARK: Running variables
    var lastMarkedPosition: CLLocation?
    let stopwatch = StopwatchTimer()
    var ongoingRun: OngoingRun?
    var runStarted: Bool {
        return ongoingRun != nil
    }

    // Location Manager
    let coreLocationManager = CLLocationManager()

    // MARK: Map variables
    @IBOutlet var googleMapView: MapView!
    let gridMapManager = GridMapManager.default
    var gridNumberAtZoomLevel: [Int: [GridNumber: RouteMarkerHandler]] =
        Constants.zoomLevels.reduce(into: [:]) { $0[$1] = [:] }
    var renderedRouteMarkers: [RouteMarkerHandler] = []
    @IBOutlet var lockMapButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupSoundButton()
        renderMapButton()
        statsPanel.bringSubviewToFront(gpsIndicator)
        googleMapView.bringSubviewToFront(lockMapButton)
        // Set the gpx file for MockCLLocationManager
        MockLocationConfiguration.GpxFileName = "bedok-reservior"
        setupLocationManager()
        setupPersistDelegate()
        setupWifiImage()
        lockMapButton.setTitle("", for: .disabled)
        googleMapView.setup(self)
        notificationToken = routes.observe { [unowned self]changes in
            switch changes {
            case .initial:
                break
            case .update(_, _, let insertions, _):
                insertions.forEach { self.insertRoute(route: self.routes[$0]) }
                self.isConnectedToInternet = true
            case .error:
                self.isConnectedToInternet = false
            }
        }
    }

    var soundButton: SoundButton?

    private func setupSoundButton() {
        let soundButton = SoundButton()
        soundButton.addTarget(self, action: #selector(soundButtonPressed), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: soundButton)
        self.soundButton = soundButton
        self.soundButton?.awakeFromNib()
    }

    @objc
    private func soundButtonPressed() {
        VoiceAssistant.muted = !VoiceAssistant.muted
        if VoiceAssistant.muted {
            soundButton?.mute()
        } else {
            soundButton?.unmute()
        }
    }

    var isMapLock: Bool = true {
        willSet {
            if isMapLock {
                googleMapView.isMapLock = true
                lockMapButton.setTitle("Map locked", for: .normal)
            } else {
                googleMapView.isMapLock = false
                lockMapButton.setTitle("Map unlocked", for: .normal)
            }
        }
    }

    func setupWifiImage() {
        let origImage = UIImage(named: "wifi.png")
        let tintedImage = origImage?.withRenderingMode(.alwaysTemplate)
        internetIndicator.image = tintedImage
        internetIndicator.tintColor = UIColor.green
        statsPanel.bringSubviewToFront(internetIndicator)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationItem.title = Titles.activity
        renderMapButton()
        setMapButton(imageUrl: Constants.startButton, action: #selector(startRun(_:)))
        navigationItem.rightBarButtonItem = nil
        checkForPersistedState()
    }

    /// Set up location manager from CoreLocation.
    private func setupLocationManager() {
        coreLocationManager.delegate = self
        coreLocationManager.requestAlwaysAuthorization()
        coreLocationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        coreLocationManager.requestLocation()

        let alert = UIAlertController(
            title: nil,
            message: "Fetching location. Please wait.",
            preferredStyle: .alert)

        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.style = UIActivityIndicatorView.Style.gray
        loadingIndicator.startAnimating()

        alert.view.addSubview(loadingIndicator)
        present(alert, animated: true, completion: nil)

        DispatchQueue.global(qos: .background).async { [unowned self] in
            while self.coreLocationManager.location == nil {
                sleep(1)
            }
            guard let location = self.coreLocationManager.location else {
                fatalError("While loop should have captured nil value!")
            }
            DispatchQueue.main.async {
                self.googleMapView.showLocation(location.coordinate)
                alert.dismiss(animated: false, completion: nil)
            }
        }
    }

    private func renderMapButton() {
        let startXPos = googleMapView.layer.frame.midX
        let startYPos = googleMapView.frame.height - mapButton.frame.height
        mapButton.center = CGPoint(x: startXPos, y: startYPos)
        googleMapView.addSubview(mapButton)
        googleMapView.bringSubviewToFront(mapButton)
        setMapButton(imageUrl: Constants.startButton, action: #selector(startRun(_:)))
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
        coreLocationManager.requestAlwaysAuthorization()
    }

    /// Function from CLLocationManagerDelegate.
    /// Used to update run location for ongoingRun
    ///
    /// - Parameters:
    ///   - manager: The location manager for the view-controller.
    ///   - locations: The new location.
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

extension ActivityViewController: RouteRenderer {
    private func insertRoute(route: Route) {
        routesManager.getRunsFor(route: route)
        // we insert the route to every zoom level for aggregated viewing of routes.
        // TODO: *****We should just insert to the lowest layer.*****
        // For all the other layers, we should fetch in a different observer token.
        Array(gridNumberAtZoomLevel.keys).forEach { insertRouteToZoomLevel(route: route, zoomLevel: $0) }
    }

    private func insertRouteToZoomLevel(route: Route, zoomLevel: Int) {
        guard let startPoint = route.startingLocation?.coordinate else {
            return
        }
        let gridManager = gridMapManager.getGridManager(Float(zoomLevel))
        let gridId = gridManager.getGridId(startPoint)
        if gridNumberAtZoomLevel[zoomLevel]?[gridId] == nil {
            if zoomLevel == Constants.maxZoom {
                gridNumberAtZoomLevel[zoomLevel]?[gridId] = RouteMarkers(map: googleMapView)
            } else {
                gridNumberAtZoomLevel[zoomLevel]?[gridId] =
                    RouteCounterMarkers(position: startPoint, map: googleMapView)
            }
        }
        guard let routeCountMarker = gridNumberAtZoomLevel[zoomLevel]?[gridId] else {
            fatalError("gridId must exist in routesInZoomGrids, based on above if-statement!")
        }
        routeCountMarker.insertRoute(route)
    }

    func redrawMarkers(_ grids: [GridNumber]) {
        renderRouteMarkers(grids)
        fetchRoutes(grids)
    }

    private func renderRouteMarkers(_ gridNumbers: [GridNumber]) {
        renderedRouteMarkers.forEach { $0.derender() }
        renderedRouteMarkers.removeAll()
        guard let allGridNumbers = gridNumberAtZoomLevel[googleMapView.nearestZoom] else {
            return
        }
        for gridNumber in gridNumbers {
            guard let routeMarker = allGridNumbers[gridNumber] else {
                continue
            }
            routeMarker.render()
            renderedRouteMarkers.append(routeMarker)
        }
    }

    /// We only request for routes above our zoom level!
    /// We should not request for routes below our zoom level as it will bloat our
    /// memory when we zoom out to the whole world.
    private func fetchRoutes(_ gridNumbers: [GridNumber]) {
        // TODO:
        // 1. If zoom level < routes threshold, we fetch the 'nearest zoom' table.
        // 2. Else, we fetch the routes based on the bounds of the gridnumbers.
        //
        // However, when we create a new route, we need to save the gridNumber and zoomLevel to the database.
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

    func renderRoutes(_ routes: Set<Route>) {
        showPullUpController()
        pullUpDrawer.setupDrawer(routes)
    }

    func renderRoute(_ route: Route) {
        googleMapView.renderRoute(route)
    }
}

protocol RouteRenderer {
    func renderRoute(_ route: Route)
}
