//
//  LoginWithWoWonderVC.swift
//  Playtube
//
//  Created by Muhammad Haris Butt on 3/30/21.
//  Copyright © 2021 Muhammad Haris Butt. All rights reserved.
//

import Foundation
import PlaytubeSDK
import Async
import UIKit

class LoginWithWoWonderVC: BaseVC {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var userNameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    // MARK: - Properties
    
    var error = ""
    
    // MARK: - View Life Cycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initialConfig()
    }
    
    // MARK: - Selectors
    
    // Back Button Action
    @IBAction func backButtonAction(_ sender: UIButton) {
        self.view.endEditing(true)
        self.navigationController?.popViewController(animated: true)
    }
    
    // SignIn Button Action
    @IBAction func SignInButtonAction(_ sender: UIButton) {
        if self.userNameField.text?.isEmpty == true {
            self.view.makeToast("Error, Required Username")
        } else if self.passwordField.text?.isEmpty == true {
            self.view.makeToast("Error, Required Password")
        } else {
            self.loginAuthentication()
        }
    }
    
    // MARK: - Helper Functions
    
    // Initial Config
    func initialConfig() {
        self.setupUI()
    }
    
    // Setup UI
    func setupUI() {
        self.userNameField.attributedPlaceholder = NSAttributedString(
            string: "Username",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.white]
        )
        self.passwordField.attributedPlaceholder = NSAttributedString(
            string: "Passsword",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.white]
        )
    }
    
    private func loginAuthentication () {
        self.showProgressDialog(text: "Loading...")
        let username = self.userNameField.text ?? ""
        let password = self.passwordField.text ?? ""
        Async.background {
            UserManager.instance.loginWithWoWonder(userName: username, password: password) { (success, sessionError, error) in
                if success != nil {
                    self.dismissProgressDialog {
                        log.verbose("Login Succesfull =\(success?.accessToken ?? "")")
                        self.WowonderSignIn(userID: success?.userID ?? "", accessToken: success?.accessToken ?? "")
                    }
                } else if sessionError != nil {
                    self.dismissProgressDialog {
                        self.error = sessionError?.errors?.error_text ?? ""
                        log.verbose(sessionError?.errors?.error_text ?? "")
                        self.view.makeToast(sessionError?.errors?.error_text ?? "")
                    }
                } else if error != nil {
                    self.dismissProgressDialog {
                        print("error - \(error?.localizedDescription ?? "")")
                        self.view.makeToast(error?.localizedDescription)
                    }
                }
            }
        }
    }
    
    private func WowonderSignIn (userID: String, accessToken: String) {
        self.showProgressDialog(text: "Loading...")
        let username = self.userNameField.text ?? ""
        let password = self.passwordField.text ?? ""
        let deviceID = UserDefaults.standard.getDeviceId(Key: Local.DEVICE_ID.DeviceId)
        Async.background {
            WoWProfileManager.instance.WoWonderUserData(userId: userID, access_token: accessToken) { (success, sessionError, error) in
                if success != nil {
                    self.dismissProgressDialog {
                        log.verbose("Success = \(success?.data?.sessionID ?? "")")
                        AppInstance.instance.getUserSession()
                        AppInstance.instance.fetchUserProfile { (success) in
                            if (success) {
                                print("true")
                                AppInstance.instance.userType = 1
                                UserDefaults.standard.setPassword(value: password, ForKey: Local.USER_SESSION.Current_Password)
                                let vc = R.storyboard.loggedUser.tabBarNav()
                                self.appDelegate.window?.rootViewController = vc
                            } else {
                                print("false")
                            }
                        }
                    }
                } else if sessionError != nil {
                    self.dismissProgressDialog {
                        self.error = sessionError?.errors?.error_text ?? ""
                        log.verbose(sessionError?.errors?.error_text ?? "")
                        self.view.makeToast(sessionError?.errors?.error_text ?? "")
                    }
                } else if error != nil {
                    self.dismissProgressDialog {
                        print("error - \(error?.localizedDescription ?? "")")
                        self.view.makeToast(error?.localizedDescription)
                    }
                }
            }
        }
    }
    
}

