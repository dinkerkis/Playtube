

import UIKit
import Async
import PlaytubeSDK

class ChangePasswordVC: BaseVC {
    
    @IBOutlet weak var repeatPasswordTF: UITextField!
    @IBOutlet weak var newPasswordTF: UITextField!
    @IBOutlet weak var currentPasswordTF: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
        self.view.backgroundColor = UIColor.bgcolor1
    }
    
    /*private func setupUI(){
        self.title = NSLocalizedString("Change Password", comment: "Change Password")
        self.repeatPasswordTF.placeholder = NSLocalizedString("Repeat Password", comment: "Repeat Password")
        self.newPasswordTF.placeholder = NSLocalizedString("New Password", comment: "New Password")
        self.currentPasswordTF.placeholder = NSLocalizedString("Current Password", comment: "Current Password")
        self.view.backgroundColor = AppSettings.appColor
        let SaveBtn = UIBarButtonItem(title: NSLocalizedString("Save", comment: "Save"), style: .done, target: self, action: #selector(logoutUser))
        self.navigationItem.rightBarButtonItem  = SaveBtn
    }*/
    
    @IBAction func btnUpdate(_ sender: Any) {
        if (self.currentPasswordTF.text?.isEmpty)!{
            let securityAlertVC = R.storyboard.popups.securityPopupVC()
            securityAlertVC?.titleText  = NSLocalizedString("Security", comment: "Security")
            securityAlertVC?.errorText = NSLocalizedString("Please enter current password.", comment: "Please enter current password.")
            self.present(securityAlertVC!, animated: true, completion: nil)
        }else if (newPasswordTF.text?.isEmpty)!{
            let securityAlertVC = R.storyboard.popups.securityPopupVC()
            securityAlertVC?.titleText  = NSLocalizedString("Security", comment: "Security")
            securityAlertVC?.errorText = NSLocalizedString("Please enter new password.", comment: "Please enter new password.")
            self.present(securityAlertVC!, animated: true, completion: nil)
        }else if (repeatPasswordTF.text?.isEmpty)!{
            let securityAlertVC = R.storyboard.popups.securityPopupVC()
            securityAlertVC?.titleText  = NSLocalizedString("Security", comment: "Security")
            securityAlertVC?.errorText = NSLocalizedString("Please enter confirm password.", comment: "Please enter confirm password.")
            self.present(securityAlertVC!, animated: true, completion: nil)
        }else{
            self.showProgressDialog(text: NSLocalizedString("Loading...", comment: "Loading..."))
            let currentPass = self.currentPasswordTF.text ?? ""
            let newPass = self.newPasswordTF.text ?? ""
            let repeatPass = self.repeatPasswordTF.text  ?? ""
            let userID = AppInstance.instance.userId ?? 0
            let sessionID = AppInstance.instance.sessionId ?? ""
            Async.background({
                MyChannelManager.instance.changePassword(User_id: userID, Session_Token: sessionID, CurrentPassword: currentPass, NewPassword: newPass, RepeatPassword: repeatPass, completionBlock: { (success, sessionError, error) in
                    if success != nil{
                        Async.main({
                            self.dismissProgressDialog {
                                log.debug("success = \(success?.message)")
                                self.view.makeToast(success?.message)
                            }
                        })
                    }else if sessionError != nil {
                        Async.main({
                            self.dismissProgressDialog {
                                log.error("error = \(sessionError?.errors!.error_text)")
                                self.view.makeToast(sessionError?.errors!.error_text)
                            }
                        })
                        
                    }else {
                        Async.main({
                            self.dismissProgressDialog {
                                log.error("error = \(error?.localizedDescription)")
                                self.view.makeToast(error?.localizedDescription)
                            }
                        })
                    }
                })
            })
        }
    }
    
    @IBAction func btnBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}
