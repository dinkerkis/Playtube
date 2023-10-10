//
//  TwoFactorController.swift
//  Playtube
//
//  Created by Ubaid Javaid on 9/8/20.
//  Copyright © 2020 Muhammad Haris Butt. All rights reserved.
//

import UIKit

class TwoFactorController: BaseVC {
    
    /*@IBOutlet weak var txtField: RoundTextField!
     
     @IBOutlet weak var twoFactorLabel: UILabel!
     @IBOutlet weak var twoFactorText: UILabel!
     
     @IBOutlet weak var saveBtn: UIButton!*/
    @IBOutlet weak var smsSwitch: UISwitch!
    
    
    var isEnabled = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.txtField.inputView = UIView()
        
        
    }
    
    @IBAction func btnBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func smsSwichChange(_ sender: Any) {
        if smsSwitch.isOn {
            smsSwitch.setOn(true, animated:true)
            self.twoFactorEnabled(two_factors: 1)
        } else {
            smsSwitch.setOn(false, animated:true)
            self.twoFactorEnabled(two_factors: 0)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        if let isOn = UserDefaults.standard.getSettings()?["two_factor_setting"] as? String {
            smsSwitch.setOn(isOn == "on", animated: true)
        }
        
        /*self.navigationController?.navigationBar.isHidden = false
        let yourBackImage = UIImage(named: "left-arrows")
        self.navigationController?.navigationBar.backIndicatorImage = yourBackImage
        self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = yourBackImage
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
        self.title = NSLocalizedString("Two Factor Authentication", comment: "Two Factor Authentication")
        self.twoFactorLabel.text = NSLocalizedString("Two-factor Authentication", comment: "Two-factor Authentication")
        self.twoFactorText.text = NSLocalizedString("Turn on 2 step login level-up your account's security. Once turned on. you'll use both your password and a 6-digit security code sent to your phone or email to log in.", comment: "Turn on 2 step login level-up your account's security. Once turned on. you'll use both your password and a 6-digit security code sent to your phone or email to log in.")
        self.saveBtn.setTitle(NSLocalizedString("SAVE", comment: "SAVE"), for: .normal)
        self.tabBarController?.tabBar.isHidden = true*/
    }
    
    
    
    func ActionSheet(controller: UIViewController) {
        let alert = UIAlertController(title: "", message: "", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Enable", comment: "Enable"), style: .default, handler: { (_) in
            //self.txtField.text = NSLocalizedString("Enabled", comment: "Enabled")
            self.isEnabled = 1
            print("User click Approve button")
        }))
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Disable", comment: "Disable"), style: .default, handler: { (_) in
            print("User click Edit button")
            self.isEnabled = 0
            //self.txtField.text = NSLocalizedString("Disable", comment: "Disable")
        }))
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Close", comment: "Close"), style: .cancel, handler: { (_) in
            print("User click Dismiss button")
        }))
        
        self.present(alert, animated: true, completion: {
            print("completion block")
        })
    }
    
    private func twoFactorEnabled(two_factors: Int){
        self.showProgressDialog(text: NSLocalizedString("Loading...", comment: "Loading..."))
        EnableTwoFactorManager.sharedInstance.enableTwoFactor(two_factor: two_factors) { (success, authError, error) in
            if (success != nil){
                self.dismissProgressDialog {
                    print(success?.message)
                }
            }
            else if (authError != nil){
                self.dismissProgressDialog {
                    self.view.makeToast(authError?.errors?.error_text)
                    
                }
            }
            else if (error != nil){
                self.dismissProgressDialog {
                    self.view.makeToast(error?.localizedDescription)
                }
            }
        }
    }
    
    
    /*@IBAction func Save(_ sender: Any) {
        self.twoFactorEnabled(two_factors: self.isEnabled)
    }
    
    @IBAction func TextAction(_ sender: Any) {
        //self.txtField.resignFirstResponder()
        self.ActionSheet(controller: self)
        
    }*/
}
