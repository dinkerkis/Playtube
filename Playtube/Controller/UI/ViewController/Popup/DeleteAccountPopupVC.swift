

import UIKit
import Async
import PlaytubeSDK
class DeleteAccountPopupVC: BaseVC {
    
    
    @IBOutlet weak var noButton: UIButton!
    @IBOutlet weak var yesButton: UIButton!
    @IBOutlet weak var deleteLAbel: UILabel!
    
    
    @IBOutlet weak var sureLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.yesButton.setTitle(NSLocalizedString("YES", comment: "YES"), for: .normal)
        
        self.noButton.setTitle(NSLocalizedString("NO", comment: "No"), for: .normal)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.deleteLAbel.text = NSLocalizedString("Delete Account", comment: "Delete Account")
        self.sureLabel.text = NSLocalizedString("Are you sure you want to delete Account?", comment: "Are you sure you want to delete Account?")
    }
    @IBAction func yesPressed(_ sender: Any) {
        self.deleteAccount(pswd: "")
    }
    @IBAction func noPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    private func deleteAccount(pswd: String){
        if Connectivity.isConnectedToNetwork(){
            self.showProgressDialog(text: NSLocalizedString("Loading...", comment: "Loading..."))
            let userID = AppInstance.instance.userId ?? 0
            let sessionID = AppInstance.instance.sessionId ?? ""
            Async.background({
                UserManager.instance.deleteUser(User_id: userID, Session_Token: sessionID, currentPassword: pswd, completionBlock: { (success, sessionError, error) in
                    if success != nil{
                        Async.main({
                            self.dismissProgressDialog {
                                log.verbose("SUCCESS")
                                UserDefaults.standard.clearUserDefaults()
                                let vc = R.storyboard.auth.login()
                                self.appDelegate.window?.rootViewController = vc!
                            }
                        })
                    }else if sessionError != nil{
                        self.dismissProgressDialog {
                            self.view.makeToast(sessionError?.errors!.error_text)
                            log.verbose("SessionError = \(sessionError?.errors!.error_text)")
                        }
                        
                    }else{
                        self.dismissProgressDialog {
                            self.view.makeToast(error?.localizedDescription)
                            log.verbose("error = \(error?.localizedDescription ?? "")")
                            
                        }
                    }
                })
            })
        }else{
            self.view.makeToast(InterNetError)
        }
    }
}
