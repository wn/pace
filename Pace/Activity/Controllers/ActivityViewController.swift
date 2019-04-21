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
    lazy var areaCounters = routesManager.inMemoryRealm.objects(AreaCounter.self)
    var notificationToken: NotificationToken?
    var areaCounternotificationToken: NotificationToken?

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
        areaCounternotificationToken = areaCounters.observe { [unowned self]changes in
            switch changes {
            case .initial:
                break
            case .update(_, _, let insertions, _):
                insertions.forEach { self.addAreaCounter(self.areaCounters[$0]) }
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
        soundButton.awakeFromNib()
        self.soundButton = soundButton
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

    var isMapLock: Bool = false {
        willSet {
            if newValue {
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

        DispatchQueue.global(qos: .background).async { [weak self] in
            while self?.coreLocationManager.location == nil {
                sleep(1)
            }
            guard let location = self?.coreLocationManager.location else {
                fatalError("While loop should have captured nil value!")
            }
            DispatchQueue.main.async {
                self?.googleMapView.showLocation(location.coordinate)
                alert.dismiss(animated: false, completion: nil)
            }
        }
    }

    func addAreaCounter(_ areaCounter: AreaCounter) {
        guard let zoomLevel = areaCounter.zoomLevel, let areaCode = areaCounter.geoCode else {
            return
        }

        let count = areaCounter.count
        let gridNumber = GridNumber(areaCode)
        if let routeCountMarker = gridNumberAtZoomLevel[zoomLevel]?[gridNumber] {
            routeCountMarker.derender()
        }
        let manager = GridMapManager.default.getGridManager(Float(zoomLevel))
        let center = manager.center(bottomLeft: gridNumber.point)
        gridNumberAtZoomLevel[zoomLevel]?[gridNumber] = RouteCounterMarkers(position: center, map: googleMapView, count: count)
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
        if isMapLock {
            googleMapView.setCameraPosition(location.coordinate)
        }
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
    func insertRoute(route: Route) {
        guard let startPoint = route.startingLocation?.coordinate else {
            return
        }
        routesManager.getRunsFor(route: route)
        let gridManager = gridMapManager.getGridManager(Float(Constants.maxZoom))
        let gridId = gridManager.getGridId(startPoint)
        if gridNumberAtZoomLevel[Constants.maxZoom]?[gridId] == nil {
            gridNumberAtZoomLevel[Constants.maxZoom]?[gridId] = RouteMarkers(map: googleMapView)
        }
        guard let routeMarker = gridNumberAtZoomLevel[Constants.maxZoom]?[gridId] else {
            fatalError("gridId must exist in routesInZoomGrids, based on above if-statement!")
        }
        routeMarker.insertRoute(route)
    }

    func redrawMarkers(_ grids: [GridNumber], zoomLevel: Float) {
        let nearestZoom = gridMapManager.getNearestZoom(zoomLevel)
        if nearestZoom == Constants.maxZoom {
            fetchRoutes(grids)
        } else {
            fetchRouteCounter(grids, zoomLevel: nearestZoom)
        }
        renderRouteMarkers(grids, zoomLevel: nearestZoom)
    }

    private func renderRouteMarkers(_ gridNumbers: [GridNumber], zoomLevel: Int) {
        renderedRouteMarkers.forEach { $0.derender() }
        renderedRouteMarkers.removeAll()
        guard let allGridNumbers = gridNumberAtZoomLevel[zoomLevel] else {
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

    private func fetchRoutes(_ gridNumbers: [GridNumber]) {
        let gridManager = gridMapManager.getGridManager(Float(Constants.maxZoom))
        for gridNumber in gridNumbers {
            let bound = gridManager.getBounds(gridId: gridNumber)
            routesManager.fetchRoutesWithin(
                latitudeMin: bound.minLat,
                latitudeMax: bound.maxLat,
                longitudeMin: bound.minLong,
                longitudeMax: bound.maxLong) {
                    if $0 != nil {
                    self.isConnectedToInternet = false
                }
            }
        }
    }

    private func fetchRouteCounter(_ gridNumbers: [GridNumber], zoomLevel: Int) {
        let areaCodes = gridNumbers.map { ($0.code, zoomLevel) }
        routesManager.retrieveAreaCount(areaCodes: areaCodes, nil)

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
