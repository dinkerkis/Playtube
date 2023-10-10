

import UIKit
import PlaytubeSDK
import Async
class WithdrawalsVC: BaseVC {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var amountText: UITextField!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var myBalanceLabel: UILabel!
   
    var email:String? = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        /*self.navigationController?.isNavigationBarHidden = false
        self.tabBarController?.tabBar.isHidden = true
        let yourBackImage = UIImage(named: "left-arrows")
           self.navigationController?.navigationBar.backIndicatorImage = yourBackImage
           self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = yourBackImage
           self.navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
        navigationController?.navigationBar.titleTextAttributes = textAttributes*/
    }
    private func setupUI(){
        //self.title =  NSLocalizedString("Withdrawals", comment: "Withdrawals")
        self.myBalanceLabel.text = NSLocalizedString("MY BALANCE", comment: "MY BALANCE")
        //self.amountText.text = NSLocalizedString("Amount", comment: "Amount")
        //self.emailTextField.text = NSLocalizedString("PayPal E-mail", comment: "PayPal E-mail")
        self.amountLabel.text = "$"+(AppInstance.instance.userProfile?.data?.balance ?? "") 
        //let sendBtn = UIBarButtonItem(title: NSLocalizedString("Save", comment: "Save"), style: .done, target: self, action: #selector(sendPressed))
        //self.navigationItem.rightBarButtonItem  = sendBtn
    }
    @IBAction func btnWithdrawal(_ sender: Any) {
        let amountValue = self.amountText.text?.toInt(defaultValue: 0)
        let userID = AppInstance.instance.userId ?? 0
        let sessionID = AppInstance.instance.sessionId ?? ""
        if amountValue ?? 0 >= 50 && !self.emailTextField.text!.isEmpty{
            self.showProgressDialog(text: NSLocalizedString("Loading...", comment: "Loading..."))
            let email = self.emailTextField.text ?? ""
            Async.background({
                MonetizationManager.instance.monetizeUser(User_id: userID, Session_Token: sessionID, Email: email, Ammount: amountValue ?? 0, completionBlock: { (success, sessionError, error) in
                    if success != nil{
                        Async.main({
                            self.dismissProgressDialog {
                                log.debug("success = \(success?.message)")
                                self.view.makeToast(success?.message)
                            }
                        })
                    }else if sessionError != nil{
                        Async.main({
                            self.dismissProgressDialog {
                                log.error("sessionError = \(sessionError?.errors.error_text)")
                                self.view.makeToast(sessionError?.errors.error_text)
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
        }else if amountValue == nil {
            self.view.makeToast(NSLocalizedString("Please enter amount.", comment: "Please enter amount."))
        }else if self.emailTextField.text!.isEmpty{
            self.view.makeToast(NSLocalizedString("Please enter email.", comment: "Please enter email."))
        }else if !self.emailTextField.text!.isEmail{
            self.view.makeToast(NSLocalizedString("Email is badly formatted.", comment: "Email is badly formatted."))
        }
        else{
            self.view.makeToast(NSLocalizedString("Amount shouldn't be less than 50.", comment: "Amount shouldn't be less than 50."))
        }
    }
    
    @IBAction func btnBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func sendPressed(){
        let amountValue = self.amountText.text?.toInt(defaultValue: 0)
        let userID = AppInstance.instance.userId ?? 0
        let sessionID = AppInstance.instance.sessionId ?? ""
        if amountValue ?? 0 >= 50 && !self.emailTextField.text!.isEmpty{
            self.showProgressDialog(text: NSLocalizedString("Loading...", comment: "Loading..."))
            let email = self.emailTextField.text ?? ""
            Async.background({
                MonetizationManager.instance.monetizeUser(User_id: userID, Session_Token: sessionID, Email: email, Ammount: amountValue ?? 0, completionBlock: { (success, sessionError, error) in
                    if success != nil{
                        Async.main({
                            self.dismissProgressDialog {
                                log.debug("success = \(success?.message)")
                                self.view.makeToast(success?.message)
                            }
                        })
                    }else if sessionError != nil{
                        Async.main({
                            self.dismissProgressDialog {
                                log.error("sessionError = \(sessionError?.errors.error_text)")
                                self.view.makeToast(sessionError?.errors.error_text)
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
        }else if amountValue == nil {
            self.view.makeToast(NSLocalizedString("Please enter amount.", comment: "Please enter amount."))
        }else if self.emailTextField.text!.isEmpty{
            self.view.makeToast(NSLocalizedString("Please enter email.", comment: "Please enter email."))
        }else if !self.emailTextField.text!.isEmail{
            self.view.makeToast(NSLocalizedString("Email is badly formatted.", comment: "Email is badly formatted."))
        }
        else{
            self.view.makeToast(NSLocalizedString("Amount shouldn't be less than 50.", comment: "Amount shouldn't be less than 50."))
        }
    }
    
    
    private func NavigationbarConfiguration(){
        self.tabBarController?.tabBar.isHidden = true
        self.title = "Monetization"
        let color = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: color ]
        self.navigationController?.navigationBar.tintColor = color
    }
    
}
