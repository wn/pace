//
//  RequireLoginController.swift
//  Pace
//
//  Created by Tan Zheng Wei on 26/3/19.
//  Copyright © 2019 nus.cs3217.pace. All rights reserved.
//

import Foundation
import UIKit
import FacebookCore
import FacebookLogin

class RequireLoginController: UIViewController {
    var user: User?
    var loginButton = LoginButton(readPermissions: [.publicProfile])
    var indicator = UILabel(frame: CGRect(x: 0.0, y: 0.0, width: 300, height: 50))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Facebook login button setup
        loginButton.center = view.center
        loginButton.delegate = self
        
        indicator.text = "Please log in."
        indicator.backgroundColor = .clear
        indicator.textAlignment = .center
        indicator.center = view.center.applying(CGAffineTransform(translationX: 0, y: -100))
        
        checkLoggedIn()
        user = Dummy.user
    }
    
    /// Updates the log in indicator.
    private func checkLoggedIn() {
        let group = DispatchGroup()
        group.enter()
        UserManager.currentUser { user in
            guard let user = user else {
                self.view.addSubview(self.loginButton)
                self.view.addSubview(self.indicator)
                print("not logged in")
                group.leave()
                return
            }
            self.user = user
            self.loginButton.removeFromSuperview()
            self.indicator.removeFromSuperview()
            group.leave()
        }
    }
}

extension RequireLoginController: LoginButtonDelegate {
    func loginButtonDidCompleteLogin(_ loginButton: LoginButton, result: LoginResult) {
        switch result {
        case .success(_, _, let token):
            UserManager.logIn(withFacebookToken: token) {
                if $0 {
                    print("success!")
                } else {
                    print("error signing in")
                }
                self.checkLoggedIn()
            }
        case .failed(let err):
            print(err.localizedDescription)
        case .cancelled:
            print("cancelled by user")
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: LoginButton) {
        do {
            try UserManager.logOut { self.checkLoggedIn() }
        } catch {
            print(error.localizedDescription)
        }
    }
}
