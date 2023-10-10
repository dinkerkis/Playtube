//
//  DeleteAccountVC.swift
//  Playtube
//
//  Created by iMac on 02/06/23.
//  Copyright © 2023 ScriptSun. All rights reserved.
//

import UIKit
import Async
import PlaytubeSDK

class DeleteAccountVC: BaseVC {

    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var btnDelete: UIButton!
    @IBOutlet weak var btnCheckBox: UIButton!
    
    var isChecked = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
    }
    
    @IBAction func backButtonAction(_ sender: UIButton) {
        self.view.endEditing(true)
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func checkBoxButtonAction(_ sender: UIButton) {
        isChecked = !isChecked
        sender.setImage(UIImage(named: isChecked ? "Tick_Square" : "un_Tick_Square"), for: .normal)
    }
    
    @IBAction func deleteButtonAction(_ sender: UIButton) {
        if passwordTF.text?.trimmingCharacters(in: .whitespaces).count == 0 {
            self.view.makeToast("Please Enter Password")
            return
        }
        
        if !isChecked {
            self.view.makeToast("Please check")
            return
        }
        if let pswd = passwordTF.text {
            self.deleteAccount(pswd: pswd)
        }
    }
    
    func setupUI() {
        self.passwordTF.delegate = self
        self.btnDelete.alpha = 0.3
        self.btnDelete.isEnabled = false
        self.lblDescription.attributedText = NSMutableAttributedString().attributeStringWithFont("Yes, I want to delete ", font: R.font.ttCommonsRegular.callAsFunction(size: 18.0)!, color: UIColor(named: "Label_Colors_Secondary") ?? .lightGray).attributeStringWithFont((AppInstance.instance.userProfile?.data?.username ?? ""), font: R.font.ttCommonsRegular.callAsFunction(size: 18.0)!, color: UIColor(named: "Primary_UI_Primary") ?? .lightGray).attributeStringWithFont(" permanently from Playtube Account", font: R.font.ttCommonsRegular.callAsFunction(size: 18.0)!, color: UIColor(named: "Label_Colors_Secondary") ?? .lightGray)
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

extension DeleteAccountVC: UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        self.btnDelete.isEnabled = textField.text != ""
        self.btnDelete.alpha = textField.text != "" ? 1.0 : 0.3
    }
}
