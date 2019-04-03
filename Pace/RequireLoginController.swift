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

class RequireLoginController: UIViewController {
    var userSession: UserSessionManager?
    
    override func viewDidLoad() {
        userSession = RealmUserSessionManager.forDefaultRealm
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if userSession?.currentUser == nil {
            presentUserPrompt()
        }
    }
    
    private func presentUserPrompt() {
        let alertController = UIAlertController(title: "Login", message: "Supply a nice nickname!", preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "Login", style: .default, handler: { [unowned self] _ -> Void in
            let textField = alertController.textFields![0]
            let newUser = self.userSession?.findUserWith(name: textField.text!, orSignUp: true)
            self.userSession?.signInAs(user: newUser)
//            self.favouriteRoutes = newUser?.favouriteRoutes
//            self.notificationToken?.invalidate()
//            guard let favouriteRoutes = self.favouriteRoutes else {
//                return
//            }
//            self.notificationToken = favouriteRoutes.observe { [unowned self] _ in self.favourites.reloadData() }
//            self.userDidLogin()
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alertController.addTextField(configurationHandler: {(textField: UITextField!) -> Void in
            textField.placeholder = "A Name for your user"
        })
        self.present(alertController, animated: true, completion: nil)
    }

    // To override in superclass, used to load data on login
    func userDidLogin() {
    }
}
