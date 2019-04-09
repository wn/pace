//
//  RunAnalysisController.swift
//  Pace
//
//  Created by Tan Zheng Wei on 30/3/19.
//  Copyright © 2019 nus.cs3217.pace. All rights reserved.
//

import UIKit
import GoogleMaps

class RunAnalysisController: UIViewController, GMSMapViewDelegate {
    weak var run: Run?
    var compareRun: Run?
    var compareLine: GMSPolyline?
    @IBOutlet private var runGraph: RunGraphView!
    @IBOutlet private var googleMapView: MapView!
    private var marker: GMSMarker?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = Titles.run
        setupMapView()
        setupGestureRecognizers()
        setupPullupController()
        if let run = run {
            googleMapView.drawRun(run, runGraph.currentRunColor)
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
            let currentCheckpoint = run.getCheckpointAt(percentage: Double(runPercentage)) else {
                return
        }
        let compareCheckpoint = compareRun?.getCheckpointAt(percentage: Double(runPercentage))
        runGraph.moveYLine(to: runPercentage, currentCheckpoint: currentCheckpoint, compareCheckpoint: compareCheckpoint)

        guard let coordinate = currentCheckpoint.location?.coordinate else {
            return
        }
        marker?.map = nil
        marker = GMSMarker(position: coordinate)
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

    private func setupPullupController() {
        let puvc: RunCollectionController = UIStoryboard(name: Identifiers.storyboard, bundle: nil)
            .instantiateViewController(withIdentifier: Identifiers.runCollectionController) as! RunCollectionController
//        puvc.route = run?.route
//        puvc.currentRun = run
        _ = puvc.view
        let tabBarHeight = tabBarController?.tabBar.frame.height ?? 0
        puvc.height = UIScreen.main.bounds.height - googleMapView.frame.height
        puvc.delegate = self
        addPullUpController(puvc, initialStickyPointOffset: puvc.initialHeight + tabBarHeight, animated: true)
    }
}

extension RunAnalysisController: RunCollectionControllerDelegate {
    func onClickCallback(run: Run) {
        if runGraph.compareRun == run {
            runGraph.compareRun = nil
            compareRun = nil
            compareLine?.map = nil
        } else {
            runGraph.compareRun = run
            compareRun = run
            compareLine = googleMapView.drawRun(compareRun, runGraph.compareRunColor)
        }
        runGraph.setNeedsDisplay()
    }
}
