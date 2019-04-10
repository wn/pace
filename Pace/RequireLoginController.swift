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

class RequireLoginController: UIViewController {
    var userSession: UserSessionManager?
    var user: User?
    
    override func viewDidLoad() {
//        userSession = RealmUserSessionManager.forDefaultRealm
        if !isUserLoggedIn(false) {
            renderLoginButton()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    private var loginButtonFrame: CGRect {
        return CGRect(origin: view.center, size: CGSize(width: 100, height: 50))
    }
    
    func renderLoginButton() {
        let fbLoginButton = LoginButton(frame: loginButtonFrame, readPermissions: [.publicProfile])
        view.addSubview(fbLoginButton)
    }

    func isUserLoggedIn(_ temp: Bool) -> Bool {
        /// - TODO: integrate API
        return temp
    }

//    private func presentUserPrompt() {
//        let alertController = UIAlertController(title: "Login", message: "Supply a nice nickname!", preferredStyle: .alert)
//
//        alertController.addAction(UIAlertAction(title: "Login", style: .default, handler: { [unowned self] _ -> Void in
//            let textField = alertController.textFields![0]
//            let newUser = self.userSession?.findUserWith(name: textField.text!, orSignUp: true)
//            self.userSession?.signInAs(user: newUser)
////            self.favouriteRoutes = newUser?.favouriteRoutes
////            self.notificationToken?.invalidate()
////            guard let favouriteRoutes = self.favouriteRoutes else {
////                return
////            }
////            self.notificationToken = favouriteRoutes.observe { [unowned self] _ in self.favourites.reloadData() }
////            self.userDidLogin()
//        }))
//        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
//        alertController.addTextField(configurationHandler: {(textField: UITextField!) -> Void in
//            textField.placeholder = "A Name for your user"
//        })
//        self.present(alertController, animated: true, completion: nil)
//    }
}
