//
//  LoginView.swift
//  Pace
//
//  Created by Tan Zheng Wei on 14/4/19.
//  Copyright © 2019 nus.cs3217.pace. All rights reserved.
//

import UIKit
import FacebookLogin

class LoginView: UIView {

    @IBOutlet private var content: UIView!
    @IBOutlet private var loginLabel: UILabel!
    private var loginButton: LoginButton?

    var delegate: LoginButtonDelegate? {
        get {
            return loginButton?.delegate
        }
        set {
            loginButton?.delegate = newValue
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        loadXib()
        self.layer.masksToBounds = true
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadXib()
        self.layer.masksToBounds = true
    }

    func enableButton() {
        loginButton?.tooltipBehavior = .automatic
    }

    func disableButton() {
        loginButton?.tooltipBehavior = .disable
    }

    private func loadXib() {
        Bundle.main.loadNibNamed(Xibs.loginView, owner: self, options: nil)
        addSubview(content)
        content.frame = self.bounds
        content.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        loginLabel.text = "Please login to view this page."
        loginButton = LoginButton(readPermissions: [.publicProfile])
        guard let loginButton = loginButton else {
            return
        }
        content.addSubview(loginButton)
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        let xBuffer = (content.frame.width - loginButton.frame.width) / 2

        let leadingConstraint = NSLayoutConstraint(item: loginButton,
                                                   attribute: .leading,
                                                   relatedBy: .equal,
                                                   toItem: content,
                                                   attribute: .leading,
                                                   multiplier: 1,
                                                   constant: xBuffer)
        let trailingConstraint = NSLayoutConstraint(item: loginButton,
                                                    attribute: .trailing,
                                                    relatedBy: .equal,
                                                    toItem: content,
                                                    attribute: .trailing,
                                                    multiplier: 1,
                                                    constant: -xBuffer)
        let verticalSpaceConstraint = NSLayoutConstraint(item: loginButton,
                                                         attribute: .top,
                                                         relatedBy: .equal,
                                                         toItem: loginLabel,
                                                         attribute: .bottom,
                                                         multiplier: 1,
                                                         constant: 8)
        content.addConstraint(leadingConstraint)
        content.addConstraint(trailingConstraint)
        content.addConstraint(verticalSpaceConstraint)
    }
}
