//  Created by Ang Wei Neng on 12/3/19.
//  Copyright © 2019 nus.cs3217.pace. All rights reserved.
//
import UIKit
import GoogleMaps
import GooglePlaces
import AVFoundation

class RunningViewController: UIViewController, UIGestureRecognizerDelegate, GMSMapViewDelegate {
    @IBOutlet private var position: UILabel!
    @IBOutlet private var mapView: GMSMapView!

    var isMapLock = false

    func lockMap(_ lock: Bool) {

//        isMapLock = lock
//        mapView.settings.setAllGesturesEnabled(!lock)
    }

    // TODO: Remove the following.
    // Used for testing only
    @IBOutlet private var horizontalAccuracy: UILabel!
    @IBOutlet private var distanceTravelled: UILabel!
    @IBOutlet private var pace: UILabel!
    @IBOutlet private var time: UILabel!

    var distance: CLLocationDistance = 0
    let stopwatch = StopwatchTimer()
    var runStarted: Bool {
        return stopwatch.isPlaying
    }

    // ------------- ------------- ------------- -------------

    private let locationManager = CLLocationManager()
    private var path = GMSMutablePath()
    var lastMarkedPosition: CLLocation?

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

    override func viewDidLoad() {
        super.viewDidLoad()
        setupLocationManager()
        setupMapView()
        lockMap(false)
    }

    /// Set up mapView view.
    private func setupMapView() {
        mapView.animate(toZoom: Constants.initialZoom)
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true

        // Required to activate gestures in mapView
        mapView.settings.consumesGesturesInView = false
        mapView.delegate = self
        mapView.setMinZoom(Constants.minZoom, maxZoom: Constants.maxZoom)
    }

    /// Set up location manager from CoreLocation.
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        // THIS GONNA FUCK UP THE BATTERY
        // Can we alternate between lower battery usage and high battery usage?
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.requestLocation()
        while locationManager.location == nil {
            // Wait 1 second and check if location has been loaded.
            // If location cannot be loaded, code here will never terminate
            // TODO: FIX ABOVE
            sleep(1)
        }
        guard let location = locationManager.location else {
            fatalError("While loop should have captured nil value!")
        }
        mapView.setCameraPosition(location.coordinate)
    }

    @IBAction private func backToActivity(_ sender: Any) {
        derenderChildController()
    }
}

// MARK: - CLLocationManagerDelegate
extension RunningViewController: CLLocationManagerDelegate {
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
        locationManager.requestWhenInUseAuthorization()
    }

    /// Function from CLLocationManagerDelegate.
    /// Function to handle update in location.
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
        if isMapLock {
            // Set to current location
            mapView.setCameraPosition(location.coordinate)
            mapView.animate(toZoom: Constants.initialZoom)
        }
        guard let acc = locationManager.location?.horizontalAccuracy, acc < Constants.guardAccuracy else {
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
        //mapView.clear()
        let mapPaths = GMSPolyline(path: path)
        mapPaths.strokeColor = .blue
        mapPaths.strokeWidth = 5
        mapPaths.map = self.mapView

        position.text = "lat: \(coordinate.latitude), long: \(coordinate.longitude)"
    }

    func addMarker(_ image: String, position: CLLocationCoordinate2D) {
        let marker = GMSMarker(position: position)
        marker.map = mapView
        marker.icon = UIImage(named: image)

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

/// TODO: TEST FUNCTIONS. NOT TO BE USED IN PRODUCTION.
extension RunningViewController {
    @IBAction private func start_ping(_ sender: UIButton) {
        startRun()
    }

    @IBAction private func stop_ping(_ sender: UIButton) {
        stopwatch.pause()
        VoiceAssistant.say("Activity paused!")
        locationManager.stopUpdatingLocation()
    }

    @IBAction private func clearMapDrawing(_ sender: UIButton) {
        mapView.clear()
        path = GMSMutablePath()
        position.text = "CLEARED DRAWING"
    }

    @IBAction private func testbutton(_ sender: UIButton) {
        // This function takes time to load, hence may not load immediately. Takes time for
        // app to determine location, especially when location accuracy is set to high.
        locationManager.requestLocation()
        updateGPS()
    }

    @IBAction private func endRun(_ sender: UIButton) {
        guard runStarted else {
            return
        }
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let summaryVC =
            storyBoard.instantiateViewController(
                withIdentifier: "summaryVC")
                as! ActivitySummaryViewController
        summaryVC.setStats(distance: distance, time: stopwatch.timeElapsed())
        endRun()
        renderChildController(summaryVC)
    }
    
    func startRun() {
        guard !runStarted else {
            return
        }
        VoiceAssistant.say("Starting run")
        locationManager.startUpdatingLocation()
        stopwatch.start()
        updateValues()
    }

    func endRun() {
        VoiceAssistant.say("Run completed")
        stopwatch.reset()
        distance = 0
        locationManager.stopUpdatingLocation()
        updateLabels()
        guard let endPos = lastMarkedPosition?.coordinate else {
            return
        }
        addMarker(Constants.endFlag, position: endPos)
    }

    func updateGPS() {
        guard let accuracy = locationManager.location?.horizontalAccuracy else {
            horizontalAccuracy.text = "Disconnected"
            return
        }
        horizontalAccuracy.text = "Horizontal accuracy: \(accuracy) meters"
    }

    func updateDistanceTravelled() {
        distanceTravelled.text = "Distance: \(Int(distance)) metres"
    }

    func updateTimer() {
        self.time.text = "time elapsed: \(self.stopwatch.timeElapsed()) secs"
    }

    func updatePace() {
        let paceValue = distance != 0 ? 1_000 * stopwatch.timeElapsed() / Int(distance) : 0
        pace.text = "Pace: \(paceValue) seconds /km"
    }

    func updateValues() {
        guard stopwatch.isPlaying == true else {
            return
        }
        updateLabels()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.updateValues()
        }
    }

    func updateLabels() {
        updatePace()
        updateTimer()
        updateGPS()
        updateDistanceTravelled()
    }
}
