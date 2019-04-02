//
//  LoginViewController.swift
//  Pace
//
//  Created by Julius Sander on 27/3/19.
//  Copyright © 2019 nus.cs3217.pace. All rights reserved.
//

import UIKit
import RealmSwift

class LoginViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        func presentMainView() {
            let mainViewController = storyboard?.instantiateViewController(withIdentifier: "Main View")
            guard let viewController = mainViewController else {
                return
            }
            present(viewController, animated: true, completion: nil)
        }

        if let _ = SyncUser.current {
            presentMainView()
        } else {
            let alertController = UIAlertController(title: "Login to Realm Cloud", message: "Supply a nice nickname!", preferredStyle: .alert)

            alertController.addAction(UIAlertAction(title: "Login", style: .default, handler: {
                _ -> Void in
                let textField = alertController.textFields![0] as UITextField
                let creds = SyncCredentials.nickname(textField.text!)

                SyncUser.logIn(with: creds, server: URL(string: Constants.AuthURL)!, onCompletion: { user, err in
                    if let _ = user {
                        presentMainView()
                    } else if let error = err {
                        fatalError(error.localizedDescription)
                    }
                })
            }))
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            alertController.addTextField(configurationHandler: {(textField: UITextField!) -> Void in
                textField.placeholder = "A Name for your user"
            })
            self.present(alertController, animated: true, completion: nil)
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
