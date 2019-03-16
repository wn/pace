//
//  ViewController.swift
//  Pace
//
//  Created by Ang Wei Neng on 12/3/19.
//  Copyright © 2019 nus.cs3217.pace. All rights reserved.
//

import UIKit
import GoogleMaps

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let map = generateMap(width: view.frame.width, height: view.frame.height / 2)
        view.addSubview(map)
    }

    func generateMap(width: CGFloat, height: CGFloat) -> UIView {
        // Create a GMSCameraPosition that tells the map to display the
        // coordinate -33.86,151.20 at zoom level 6.
        let camera = GMSCameraPosition.camera(withLatitude: -33.86, longitude: 151.20, zoom: 6.0)
        let mapsViewFrame = CGRect(x: 0, y: 0, width: width, height: height)
        let mapView = GMSMapView.map(withFrame: mapsViewFrame, camera: camera)

        // Creates a marker in the center of the map.
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: -33.86, longitude: 151.20)
        marker.title = "asdf"
        marker.snippet = "xxx"
        marker.map = mapView

        return mapView
    }
}

