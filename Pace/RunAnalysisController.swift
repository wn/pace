//
//  RunAnalysisController.swift
//  Pace
//
//  Created by Tan Zheng Wei on 30/3/19.
//  Copyright © 2019 nus.cs3217.pace. All rights reserved.
//

import UIKit
import GoogleMaps

class RunAnalysisController: UIViewController {
    weak var run: Run?
    @IBOutlet private var runGraph: RunGraphView!
    @IBOutlet private var googleMapView: GMSMapView!
    private var marker: GMSMarker?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = Titles.run
        setupMapView()
        setupGestureRecognizers()
        if let run = run {
            googleMapView.draw(run: run)
            runGraph.currentRun = run
            runGraph.setNeedsDisplay()
        }
    }

    private func setupGestureRecognizers() {
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        runGraph.addGestureRecognizer(panGestureRecognizer)
    }

    /// Moves the yLine horizontally to the point of the pan
    /// Updates the map based on the location of the runner (based on the percentage progress of the run)
    @objc
    func handlePan(_ recognizer: UIPanGestureRecognizer) {
        let xVal = recognizer.location(in: runGraph).x
        let runPercentage = (xVal == 0) ? CGFloat.leastNormalMagnitude : (xVal / runGraph.bounds.width)
        guard let run = run,
            let location = run.getLocationAt(percentage: Double(runPercentage)) else {
                return
        }
        runGraph.moveYLine(to: runPercentage, location: location)
        marker?.map = nil
        marker = GMSMarker(position: location.coordinate)
        marker?.map = googleMapView
    }

    private func setupMapView() {
        googleMapView.animate(toZoom: Constants.initialZoom)
        /// - TODO: Remove my location once we load the GMSCameraPosition of the run
        googleMapView.isMyLocationEnabled = true
        googleMapView.settings.myLocationButton = true

        // Required to activate gestures in googleMapView
        googleMapView.settings.consumesGesturesInView = false
        googleMapView.delegate = self
        googleMapView.setMinZoom(Constants.minZoom, maxZoom: Constants.maxZoom)
    }
}

extension RunAnalysisController: GMSMapViewDelegate {

}
