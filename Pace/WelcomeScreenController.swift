//
//  ViewController.swift
//  Pace
//
//  Created by Ang Wei Neng on 12/3/19.
//  Copyright © 2019 nus.cs3217.pace. All rights reserved.
//

import UIKit
import FacebookCore
import FacebookLogin
import Firebase
import FirebaseAuth
import GoogleMaps

class WelcomeScreenController: UIViewController, LoginButtonDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()

        // Facebook login button setup
        let loginButton = LoginButton(readPermissions: [ .publicProfile ])
        loginButton.center = view.center
        loginButton.delegate = self

        // Do any additional setup after loading the view, typically from a nib.
        // let map = generateMap(width: view.frame.width, height: view.frame.height / 2)

        // view.addSubview(map)
        view.addSubview(loginButton)

        indicator.center = view.center.applying(CGAffineTransform(translationX: 0, y: -100))
        routeInfo.center = view.center.applying(CGAffineTransform(translationX: 0, y: 100))
        updateIndicator()

        // Setup fire store and display routes available
        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        firestore = Firestore.firestore()
        refreshRoutes()
        let refreshButton = UIButton(type: .system)
        refreshButton.setTitle("Refresh", for: .normal)
        refreshButton.center = view.center.applying(CGAffineTransform(translationX: 0, y: 300))
        refreshButton.addTarget(self, action: #selector(refresh), for: .touchUpInside)

        view.addSubview(indicator)
        view.addSubview(routeInfo)
        view.addSubview(refreshButton)
    }

    /// Callback for the refresh button.
    @objc func refresh(sender: UIButton!) {
        refreshRoutes()
    }

    /// Refreshes the routes displayed in view.
    func refreshRoutes() {
        Route.all(firestore: firestore) { routes in
            self.routeInfo.text = routes.flatMap { $0.map { $0.name }.joined(separator: "\n") }
        }
    }

    /// Generates a map view via the Google Maps API
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

    // MARK: - Login & Firestore methods

    func loginButtonDidCompleteLogin(_ loginButton: LoginButton, result: LoginResult) {
        switch result {
        case .success(_, _, let token):
            print(token.authenticationToken)
            guard let accessToken = AccessToken.current else {
                print("some shit happened")
                return
            }
            let credential = FacebookAuthProvider.credential(withAccessToken: accessToken.authenticationToken)
            Auth.auth().signInAndRetrieveData(with: credential) { _, err in
                guard err == nil else {
                    print("error: \( err.debugDescription)")
                    return
                }
                print("success!")
                self.updateIndicator()
            }
        case .failed(let err):
            print(err.localizedDescription)
        case .cancelled:
            print("cancelled by user")
        }
    }

    func loginButtonDidLogOut(_ loginButton: LoginButton) {
        do {
            try Auth.auth().signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
        updateIndicator()
    }

    /// An indicator for whether the user is logged in.
    private var indicator: UILabel = {
        let label = UILabel(frame: CGRect(x: 0.0, y: 0.0, width: 300, height: 50))
        label.backgroundColor = .clear
        label.textAlignment = .center
        return label
    }()

    /// Information about routes (show how the api is working)
    private var routeInfo: UILabel = {
        let label = UILabel(frame: CGRect(x: 0.0, y: 0.0, width: 300, height: 50))
        label.backgroundColor = .clear
        label.textAlignment = .center
        label.font = UIFont(name: "System", size: 10.0)
        return label
    }()

    // (Should store an instance in each controller I think?)
    /// Firestore to retrieve information from.
    private var firestore: Firestore!

    /// Updates the log in indicator.
    private func updateIndicator() {
        guard let user = Auth.auth().currentUser else {
            indicator.text = "Please log in"
            return
        }
        indicator.text = "Welcome back \(user.displayName ?? "")"
    }

}
