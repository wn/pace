//
//  RequireLoginController.swift
//  Pace
//
//  Created by Tan Zheng Wei on 4/4/19.
//  Copyright © 2019 nus.cs3217.pace. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift
import FacebookLogin
import FacebookCore

class RequireLoginController: UIViewController, LoginButtonDelegate {
    
    var fbLoginButton: LoginButton?
    var userSession: UserSessionManager?
    var user: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        userSession = RealmUserSessionManager.forDefaultRealm
        if !isUserLoggedIn() {
            renderLoginButton()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !isUserLoggedIn() {
            renderLoginButton()
        }
    }
    
    private var loginButtonFrame: CGRect {
        return CGRect(origin: view.center, size: CGSize(width: 100, height: 50))
    }

    func renderLoginButton() {
        if let existingButton = fbLoginButton {
            existingButton.removeFromSuperview()
        }
        fbLoginButton = LoginButton(frame: loginButtonFrame, readPermissions: [.publicProfile])
        fbLoginButton?.delegate = self
        guard let fbLoginButton = fbLoginButton else {
            return
        }
        view.addSubview(fbLoginButton)
    }

    func hideLoginButton() {
        guard let fbLoginButton = fbLoginButton else {
            return
        }
        fbLoginButton.removeFromSuperview()
    }

    func isUserLoggedIn() -> Bool {
        // If the token exists, load the user
        guard let token = AccessToken.current,
            let facebookId = token.userId else {
            return false
        }
        loadUser(facebookId: facebookId)
        return true
    }

    
    func loginButtonDidCompleteLogin(_ loginButton: LoginButton, result: LoginResult) {
        switch result {
        case let .success(_, _, token):
            guard let facebookId = token.userId else {
                return
            }
            loadUser(facebookId: facebookId)
        default:
            break
        }
    }

    /// - TODO: Find-or-create firebase for existing user and load Realm user reference.
    func loadUser(facebookId: String) {
        guard !findUser(facebookId: facebookId) else {
            viewDidLoad()
            hideLoginButton()
            return
        }
        // If user does not exist, request FB for user data (name)
        GraphRequest(graphPath: "me", parameters: ["fields": "id, name"]).start({ _, result in
            switch result {
            case .success(let response):
                guard let name = response.dictionaryValue?["name"] as? String else {
                    return
                }
                self.createUser(facebookId: facebookId, name: name)
                self.hideLoginButton()
                self.viewDidLoad()
            case .failed(let error):
                print("Graph Request failed: \(error)")
            }
        })
    }

    /// - TODO: Replace with API call
    /// Create user in firebase and load user reference into this controller
    func createUser(facebookId: String, name: String) {
        
    }

    /// - TODO: Replace with API call
    /// Find user in firebase and load user reference into this controller
    func findUser(facebookId: String) -> Bool {
        return false
    }
    
    func loginButtonDidLogOut(_ loginButton: LoginButton) {
    }
}
