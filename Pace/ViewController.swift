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

class ViewController: UIViewController {
    @IBOutlet var position: UILabel!

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

    @IBOutlet private var mapView: GMSMapView!
    private let locationManager = CLLocationManager()
    var path = GMSMutablePath()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupLocationManager()
        setupMapView()
    }

    /// Set up mapView view.
    private func setupMapView() {
        mapView.animate(toZoom: 15)
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
    }
}

// MARK: - CLLocationManagerDelegate
extension ViewController: CLLocationManagerDelegate {
    /// Function from CLLocationManagerDelegate.
    /// Check if there was any change to the authorization level
    /// for location and handle the change.
    ///
    /// - Parameters:
    ///   - manager: The location manager for the view-controller.
    ///   - status: The newly set location authorization level.
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        guard status == .authorizedWhenInUse else {
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
        guard let location = locations.first else {
            print("WTF?")
            return
        }
        print("LOL \(locations)")

        let coordinate = location.coordinate
        path.add(CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude))

        // TODO: We redraw the whole map again. is this good?
        // Or can we dynamically generate the map without mutablepath
        mapView.clear()
        let mapPaths = GMSPolyline(path: path)
        mapPaths.strokeColor = .black
        mapPaths.strokeWidth = 5
        mapPaths.map = mapView

        // The following is to ensure that we do not change users viewing
        // specification while updating location
        let mapZoom = mapView.camera.zoom
        let mapBearing = mapView.camera.bearing
        let mapViewAngle = mapView.camera.viewingAngle

        mapView.camera = GMSCameraPosition(target: coordinate, zoom: mapZoom, bearing: mapBearing, viewingAngle: mapViewAngle)

        position.text = "lat: \(coordinate.latitude), long: \(coordinate.longitude)"
    }


    /// Drop a marker on the specified location
    ///
    /// - Parameter position: location to drop marker
    private func dropMarker(_ position: CLLocationCoordinate2D) {
        let posMarker = GMSMarker(position: position)
        posMarker.isFlat = true
        posMarker.title = "LMAO"
        posMarker.map = mapView
    }

    /// Function from CLLocationManagerDelegate.
    /// Function to handle failure in retrieving location.
    ///
    /// - Parameters:
    ///   - manager: The location manager for the view-controller.
    ///   - error: Error message.
    func locationManager(_ manager: CLLocationManager,
                         didFailWithError error: Error) {
        print("FAILED GETTING LOCATION \(error)")
        // TODO: ADD VOICE: "GPS SIGNAL LOST"
        // Add a flag to indicate that GPS signal is lost
        // so that when reconnected, a new voice indicator can be
        // executed to let user know that they have reconnected.
    }
}
