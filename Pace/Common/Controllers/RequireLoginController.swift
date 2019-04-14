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

    private lazy var loginView: LoginView? = {
        guard let view = view else {
            return nil
        }
        let loginViewFrame = view.frame
        return LoginView(frame: loginViewFrame)
    }()
    var user: User?

    /// Handles requirement for user to be logged in
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !isUserLoggedIn() {
            renderLoginView()
        } else {
            hideLoginView()
        }
    }

    private var loginButtonFrame: CGRect {
        return CGRect(origin: view.center, size: CGSize(width: 100, height: 50))
    }

    private func renderLoginView() {
        guard let loginView = loginView else {
            return
        }
        loginView.delegate = self
        view.addSubview(loginView)
    }

    private func hideLoginView() {
        guard let loginView = loginView else {
            return
        }
        loginView.removeFromSuperview()
    }

    /// Checks if the user is logged in by checking for the presence of the AccessToken
    /// Loads the user if the user exists
    func isUserLoggedIn() -> Bool {
        guard let token = AccessToken.current,
            let facebookId = token.userId else {
            user = nil
            return false
        }
        loadUser(with: facebookId)
        return true
    }

    /// Gets the current User from Realm and assigns it
    /// Makes a request to query Firebase to update
    func loadUser(with uid: String) {
        user = RealmUserSessionManager.default.getRealmUser(uid)
        RealmUserSessionManager.default.findOrCreateUser(with: uid) { user, error in
            self.user = user
            self.loadData()
        }
    }

    func loginButtonDidCompleteLogin(_ loginButton: LoginButton, result: LoginResult) {
        switch result {
        case let .success(_, _, token):
            guard let facebookId = token.userId else {
                return
            }
            loadUser(with: facebookId)
        default:
            break
        }
    }

    func loginButtonDidLogOut(_ loginButton: LoginButton) {
        renderLoginView()
    }

    /// To be overriden by subclass
    func loadData() {}
}
