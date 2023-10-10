import UIKit
import Async
import PlaytubeSDK

class ForgetPasswordVC: BaseVC {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var emailImageView: UIImageView!
    @IBOutlet weak var emailTextFieldTF: TJTextField!
    @IBOutlet weak var forhetLabel: UILabel!
    @IBOutlet weak var textLAbel: UILabel!
    @IBOutlet weak var sendBtn: UIButton!
    
    // MARK: - Properties
    
    var status = false
    
    // MARK: - View Life Cycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.emailTextFieldTF.placeholder = NSLocalizedString("Enter your Email", comment: "nter your Email")
        self.forhetLabel.text = NSLocalizedString("Forgot your password", comment: "Forgot your password")
        self.textLAbel.text = NSLocalizedString("Dont worry type your email here and we will recover it for you.", comment: "Dont worry type your email here and we will recover it for you.")
        self.sendBtn.setTitle(NSLocalizedString("Send", comment: "Send"), for: .normal)
        self.view.backgroundColor = .buttonColor
        self.emailTextFieldTF.textColor = .fontcolor
        self.emailTextFieldTF.lineColor = .fontcolor
        self.textLAbel.textColor = .fontcolor
        self.forhetLabel.textColor = .fontcolor
        self.sendBtn.backgroundColor = .fontcolor
        self.sendBtn.setTitleColor(.buttonColor, for: .normal)
        self.emailImageView.tintColor = .fontcolor
    }
    
    // MARK: - Selectors
    
    // Back Button Action
    @IBAction func backButtonAction(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    // Send Button Action
    @IBAction func sendButtonAction(_ sender: UIButton) {
        if (emailTextFieldTF.text?.isEmpty)! {
            let securityAlertVC = R.storyboard.popups.securityPopupVC()
            securityAlertVC?.titleText  = NSLocalizedString("Security", comment: "Security")
            securityAlertVC?.errorText = NSLocalizedString("Please enter email.", comment: "Please enter email.")
            self.present(securityAlertVC!, animated: true, completion: nil)
        } else if (self.emailTextFieldTF.text?.isEmail)! {
            let securityAlertVC = R.storyboard.popups.securityPopupVC()
            securityAlertVC?.titleText  = NSLocalizedString("Security", comment: "Security")
            securityAlertVC?.errorText = NSLocalizedString("Email is badly formatted.", comment: "Email is badly formatted.")
            self.present(securityAlertVC!, animated: true, completion: nil)
        } else {
            self.forgetPassword()
        }
    }
    
    // MARK: - Helper Functions
    
    private func forgetPassword() {
        if Connectivity.isConnectedToNetwork() {
            self.showProgressDialog(text: NSLocalizedString("Loading...", comment: "Loading..."))
            let email = self.emailTextFieldTF.text ?? ""
            Async.background {
                UserManager.instance.ForgetPassword(Email: email, completionBlock: { (success, sessionError, error) in
                    if success != nil {
                        Async.main {
                            self.dismissProgressDialog {
                                log.verbose("Success = \(success?.data!.message ?? "")")
                                self.view.makeToast(success?.data!.message)
                            }
                        }
                    } else if sessionError != nil {
                        Async.main {
                            self.dismissProgressDialog {
                                log.verbose("AuthError = \(sessionError?.errors!.error_text ?? "")")
                                self.view.makeToast(sessionError?.errors!.error_text)
                            }
                        }
                    } else {
                        Async.main {
                            self.dismissProgressDialog {
                                log.verbose("Error = \(error?.localizedDescription ?? "")")
                            }
                        }
                    }
                })
            }
        } else {
            self.view.makeToast(InterNetError)
        }
    }
    
}
