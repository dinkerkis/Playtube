

import UIKit
import Async
import PlaytubeSDK
class UnblockUserPopupVC: BaseVC {
    
    @IBOutlet weak var noButton: UIButton!
    @IBOutlet weak var yesButton: UIButton!
    var blockID:Int? = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.yesButton.setTitle(NSLocalizedString("YES", comment: "YES"), for: .normal)
        
        self.noButton.setTitle(NSLocalizedString("NO", comment: "NO"), for: .normal)
    }
    
    @IBAction func yesPressed(_ sender: Any) {
        self.unblockUser()
        
    }
    @IBAction func noPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    private func unblockUser() {
        if Connectivity.isConnectedToNetwork(){
            self.showProgressDialog(text: NSLocalizedString("Loading...", comment: "Loading..."))
            let userID = AppInstance.instance.userId ?? 0
            let sessionID = AppInstance.instance.sessionId ?? ""
            let blockId = self.blockID ?? 0
            Async.background({
                BlockedUserManager.instance.blockUnBlockUser(User_id: userID, Session_Token: sessionID, type: "block", blockId: blockId, completionBlock: { (success, sessionError, error) in
                    if success != nil{
                        Async.main({
                            self.dismissProgressDialog {
                                log.verbose("SUCCESS")
                                NotificationCenter.default.post(name: NSNotification.Name("reloadBlockUserData"), object: nil)
                                self.dismiss(animated: true, completion: nil)
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
