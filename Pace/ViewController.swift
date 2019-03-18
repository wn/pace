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
import FirebaseAuth
import GoogleMaps

class ViewController: UIViewController, LoginButtonDelegate {
    func loginButtonDidCompleteLogin(_ loginButton: LoginButton, result: LoginResult) {
        switch result {
        case .success(_, _, let token):
            print(token.authenticationToken)
            guard let accessToken = AccessToken.current else {
                print("some shit happened")
                return
            }
            let credential = FacebookAuthProvider.credential(withAccessToken: accessToken.authenticationToken)
            Auth.auth().signInAndRetrieveData(with: credential) { (_, err) in
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

    private var indicator: UILabel = {
        let label = UILabel(frame: CGRect(x: 0.0, y: 0.0, width: 300, height: 50))
        label.backgroundColor = .clear
        label.textAlignment = .center
        return label
    }()

    private func updateIndicator() {
        guard let user = Auth.auth().currentUser else {
            indicator.text = "Please log in"
            return
        }
        indicator.text = "Welcome back \(user.displayName ?? "")"
    }
    
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
        updateIndicator()
        
        view.addSubview(indicator)
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

