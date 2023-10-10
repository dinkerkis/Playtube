//
//  TwoFactorVC.swift
//  Playtube
//
//  Created by Muhammad Haris Butt on 17/08/2021.
//  Copyright © 2021 Muhammad Haris Butt. All rights reserved.
//

import UIKit
import PlaytubeSDK
import Async

class TwoFactorVC: BaseVC {
    
    @IBOutlet weak var verifyCodeTextField: UITextField!
    @IBOutlet weak var verifyBtn: UIButton!
    @IBOutlet weak var secondLabel: UILabel!
    @IBOutlet weak var firstLabel: UILabel!
    var code:Int? = 0
    var userID : Int? = 0
    var error = ""
    var password:String? = ""
    var email = ""
    var is_check = "0"
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    private func setupUI(){
//        self.verifyBtn.setTitleColor(.Button_StartColor, for: .normal)
        self.firstLabel.text = NSLocalizedString("To log in, you need to verify  your identity.", comment: "To log in, you need to verify  your identity.")
        self.secondLabel.text = NSLocalizedString("We have sent you the confirmation code to your email address.", comment: "We have sent you the confirmation code to your email address.")
        self.verifyCodeTextField.placeholder =  NSLocalizedString("Add code number", comment: "Add code number")
        self.verifyBtn.setTitle(NSLocalizedString("VERIFY", comment: "VERIFY"), for: .normal)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        self.resendEmail()
        self.navigationController?.isNavigationBarHidden = false
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    @IBAction func verifyPressed(_ sender: Any) {
        if self.verifyCodeTextField.text!.isEmpty{
            self.view.makeToast(NSLocalizedString("Please enter Code.", comment: "Please enter Code."))
        }else{
            self.verifyTwoFactor()
        }
    }
    

    private func verifyTwoFactor(){
        
        if appDelegate.isInternetConnected{
            if (self.verifyCodeTextField.text!.isEmpty){
                let securityAlertVC = R.storyboard.popups.securityPopupVC()
                securityAlertVC?.titleText  = "Security"
                securityAlertVC?.errorText = NSLocalizedString("Please enter Code.", comment: "Please enter Code.")
                self.present(securityAlertVC!, animated: true, completion: nil)
            }else{
                self.showProgressDialog(text: "Loading...")
                let userID = self.userID ?? 0
                let code = self.verifyCodeTextField.text ?? ""
                
                Async.background({
                    UserManager.instance.twoFactor(userID: userID, code: Int(code)!) { (success, sessionError, error) in
                        if success != nil{
                            Async.main{
                                self.dismissProgressDialog{
                                    log.verbose("Success = \(success?.data?.sessionID ?? "")")
                                    log.verbose("Success = \(success?.data?.userID ?? 0)")
                                    AppInstance.instance.getUserSession()
                                    AppInstance.instance.fetchUserProfile { (success) in
                                        if (success){
                                            AppInstance.instance.userType = 1
                                            let vc = R.storyboard.loggedUser.tabBarNav()
                                            self.appDelegate.window?.rootViewController = vc
                                        }
                                        else{
                                            print(false)
                                        }
                                    }
                                }
                            }
                        }else if sessionError != nil{
                            Async.main{
                                self.dismissProgressDialog {
                                    log.verbose("session Error = \(sessionError?.errors?.error_text)")
                                    
                                    let securityAlertVC = R.storyboard.popups.securityPopupVC()
                                    securityAlertVC?.titleText  = "Security"
                                    securityAlertVC?.errorText = sessionError?.errors?.error_text ?? ""
                                    self.present(securityAlertVC!, animated: true, completion: nil)
                                    
                                }
                            }
                        }else {
                            Async.main({
                                self.dismissProgressDialog {
                                    log.verbose("error = \(error?.localizedDescription)")
                                    let securityAlertVC = R.storyboard.popups.securityPopupVC()
                                    securityAlertVC?.titleText  = "Security"
                                    securityAlertVC?.errorText = error?.localizedDescription ?? ""
                                    self.present(securityAlertVC!, animated: true, completion: nil)
                                }
                            })
                        }
                    }
                    
                })
            }
        }else{
            self.dismissProgressDialog {
                let securityAlertVC = R.storyboard.popups.securityPopupVC()
                securityAlertVC?.titleText  = "Internet Error"
                securityAlertVC?.errorText = InterNetError ?? ""
                self.present(securityAlertVC!, animated: true, completion: nil)
                log.error("internetError - \(InterNetError)")
            }
        }
    }
}
