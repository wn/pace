//
//  RunAnalysisController.swift
//  Pace
//
//  Created by Tan Zheng Wei on 30/3/19.
//  Copyright © 2019 nus.cs3217.pace. All rights reserved.
//

import UIKit
import RealmSwift
import GoogleMaps

class RunAnalysisController: UIViewController, GMSMapViewDelegate {
    var run: Run?
    var line: GMSPolyline?
    var compareRun: Run?
    var compareLine: GMSPolyline?
    @IBOutlet private var runGraph: RunGraphView!
    @IBOutlet private var googleMapView: MapView!
    private var marker = GMSMarker()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = Titles.run
        googleMapView.setup(self)
        setupGestureRecognizers()
        setupPullupController()
        guard let run = run else {
            return
        }
        marker.map = googleMapView
        line = googleMapView.drawRun(run, runGraph.currentRunColor)
        runGraph.currentRun = run
        runGraph.setNeedsDisplay()
    }

    private func setupGestureRecognizers() {
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        runGraph.addGestureRecognizer(panGestureRecognizer)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let startPoint = run?.startingLocation?.coordinate else {
            return
        }
        googleMapView.showLocation(startPoint)
    }

    /// Moves the yLine horizontally to the point of the pan
    /// Updates the map based on the location of the runner (based on the percentage progress of the run)
    @objc
    func handlePan(_ recognizer: UIPanGestureRecognizer) {
        let xVal = recognizer.location(in: runGraph).x
        let xMultiplier = (xVal == 0) ? CGFloat.leastNormalMagnitude : (xVal / runGraph.bounds.width)
        let runDistance = Double(xMultiplier) * runGraph.maxDistance
        guard let run = run,
            let currentCheckpoint = run.getCheckpointAt(distance: runDistance) else {
                return
        }
        let compareCheckpoint = compareRun?.getCheckpointAt(distance: runDistance)
        runGraph.moveYLine(to: xMultiplier, currentCheckpoint: currentCheckpoint, compareCheckpoint: compareCheckpoint)
        guard let coordinate = currentCheckpoint.location?.coordinate else {
            return
        }
        marker.position = coordinate
    }

    private func setupPullupController() {
        let rcc: RunCollectionController = UIStoryboard(name: Identifiers.storyboard, bundle: nil)
            .instantiateViewController(withIdentifier: Identifiers.runCollectionController) as! RunCollectionController
        guard let routeId = run?.routeId else {
            return
        }
        rcc.currentRunId = run?.objectId
        rcc.routeId = routeId
        _ = rcc.view
        let tabBarHeight = self.tabBarController?.tabBar.frame.height ?? 0
        rcc.height = UIScreen.main.bounds.height - self.googleMapView.frame.height
        rcc.delegate = self
        self.addPullUpController(rcc, initialStickyPointOffset: rcc.initialHeight + tabBarHeight, animated: true)
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
            // Draw the original line again over the line to compare
            line?.map = nil
            line?.map = googleMapView
        }
        runGraph.setNeedsDisplay()
    }
}
