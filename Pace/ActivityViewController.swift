//  Created by Ang Wei Neng on 12/3/19.
//  Copyright © 2019 nus.cs3217.pace. All rights reserved.
//
import UIKit
import GoogleMaps
import GooglePlaces
import AVFoundation

class ActivityViewController: UIViewController {
    @IBOutlet var position: UILabel!
    @IBOutlet private var mapView: GMSMapView!

    // TODO: Remove the following.
    // Used for testing only
    @IBOutlet var horizontalAccuracy: UILabel!
    @IBOutlet var distanceTravelled: UILabel!
    @IBOutlet var pace: UILabel!
    @IBOutlet var time: UILabel!

    @IBAction func restartRun(_ sender: UIButton) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let summaryVC =
            storyBoard.instantiateViewController(
                withIdentifier: "summaryVC")
                as! ActivitySummaryViewController
        summaryVC.setStats(distance: distance, time: stopwatch.timeElapsed())
        renderChildController(summaryVC)
        stopwatch.reset()
        distance = 0
        locationManager.stopUpdatingLocation()
        updateLabels()
    }
    var distance: CLLocationDistance = 0
    let stopwatch = StopwatchTimer()

    func startRun() {
        guard stopwatch.isPlaying == false else {
            return
        }
        VoiceAssistant.say("Starting run")
        locationManager.startUpdatingLocation()
        stopwatch.start()
        updateValues()
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
        guard stopwatch.isPlaying == true else {
            return
        }
        self.time.text = "time elapsed: \(self.stopwatch.timeElapsed()) secs"
    }

    func updatePace() {
        let paceValue = distance != 0 ? 1000 * stopwatch.timeElapsed() / Int(distance) : 0
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

    // ------------- ------------- ------------- -------------

    private let locationManager = CLLocationManager()
    private var path = GMSMutablePath()
    var lastMarkedPosition: CLLocation?

    private var _isConnected = true
    var isConnected: Bool {
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
    }

    /// Set up mapView view.
    private func setupMapView() {
        mapView.animate(toZoom: Constants.initialZoom)
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
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
            sleep(1)
        }
        guard let location = locationManager.location else {
            fatalError("While loop should have captured nil value!")
        }
        setCameraPosition(location.coordinate)
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
        guard status == .authorizedWhenInUse else {
            locationManager.requestWhenInUseAuthorization()
            return
        }
        // TODO: Add authorizartion handling.
    }

    /// Function from CLLocationManagerDelegate.
    /// Function to handle update in location.
    ///
    /// - Parameters:
    ///   - manager: The location manager for the view-controller.
    ///   - locations: The array of location updates that is not handled yet.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            return
        }
        guard let acc = locationManager.location?.horizontalAccuracy, acc < 25 else {
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
        path.add(CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude))

        // TODO: We redraw the whole map again. is this good?
        // Or can we dynamically generate the map without mutablepath
        mapView.clear()
        let mapPaths = GMSPolyline(path: path)
        mapPaths.strokeColor = .black
        mapPaths.strokeWidth = 5
        mapPaths.map = mapView

        position.text = "lat: \(coordinate.latitude), long: \(coordinate.longitude)"
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

// MARK: - Helper functions for mapView
extension ActivityViewController {
    /// Set the camera position of mapView
    ///
    /// - Parameter coordinate: The coordinate that mapView will be centered on.
    func setCameraPosition(_ coordinate: CLLocationCoordinate2D) {
        // The following is to ensure that we do not change users viewing
        // specification while updating location. Done by reusing the old zoom,
        // bearing and angle.
        let mapZoom = mapView.camera.zoom
        let mapBearing = mapView.camera.bearing
        let mapViewAngle = mapView.camera.viewingAngle

        mapView.camera = GMSCameraPosition(target: coordinate, zoom: mapZoom, bearing: mapBearing, viewingAngle: mapViewAngle)
    }

    /// Drop a marker on the specified location.
    ///
    /// - Parameter position: location to drop marker.
    private func dropMarker(_ position: CLLocationCoordinate2D) {
        let posMarker = GMSMarker(position: position)
        posMarker.map = mapView
    }
}

extension ActivityViewController {
    /// TEST FUNCTIONS. NOT TO BE USED IN PRODUCTION.
    @IBAction func start_ping(_ sender: UIButton) {
        startRun()
    }

    @IBAction func stop_ping(_ sender: UIButton) {
        stopwatch.pause()
        VoiceAssistant.say("Activity paused!")
        locationManager.stopUpdatingLocation()
    }

    @IBAction func clearMapDrawing(_ sender: UIButton) {
        mapView.clear()
        path = GMSMutablePath()
        position.text = "CLEARED DRAWING"
    }

    @IBAction func testbutton(_ sender: UIButton) {
        // This function takes time to load, hence may not load immediately. Takes time for
        // app to determine location, especially when location accuracy is set to high.
        locationManager.requestLocation()
    }


}
