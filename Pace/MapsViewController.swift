//
//  ViewController.swift
//  Pace
//
//  Created by Ang Wei Neng on 12/3/19.
//  Copyright © 2019 nus.cs3217.pace. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import AVFoundation

class MapsViewController: UIViewController {
    @IBOutlet var position: UILabel!
    @IBOutlet private var mapView: GMSMapView!

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
extension MapsViewController: CLLocationManagerDelegate {
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
        isConnected = true
        if let lastMarkedPosition = lastMarkedPosition {
            // TODO: Print statement is to find the optimal guardDistance. To delete
            // once we found the optimal distance.
            // Can also combine the 2 if-statements above and below this line.
            print("Distance =  \(location.distance(from: lastMarkedPosition))")
            if location.distance(from: lastMarkedPosition) < Constants.guardDistance {
                // Do not consider new location if new location is
                // less than guardDistance. This guard against poor
                // GPS accuracy.
                return
            }
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
extension MapsViewController {
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

extension MapsViewController {
    /// TEST FUNCTIONS. NOT TO BE USED IN PRODUCTION.

    @IBAction func start_ping(_ sender: UIButton) {
        VoiceAssistant.say("CONNECTED")
        print("CONNECTED")
        locationManager.startUpdatingLocation()
    }

    @IBAction func stop_ping(_ sender: UIButton) {
        VoiceAssistant.say("Activity paused!")
        locationManager.stopUpdatingHeading()
    }

    @IBAction func clearMapDrawing(_ sender: UIButton) {
        mapView.clear()
        path = GMSMutablePath()
        position.text = "CLEARED DRAWING"
    }

    @IBAction func testbutton(_ sender: UIButton) {
        print("PINGED BUTTON")

        // This function takes time to load, hence may not load immediately. Takes time for
        // app to determine location, especially when location accuracy is set to high.
        locationManager.requestLocation()
    }
}
