//
//  LinkTvVC.swift
//  Playtube
//
//  Copyright © 2022 Muhammad Haris Butt. All rights reserved.
//

import UIKit
import PlaytubeSDK

class LinkTvVC: UIViewController {
    
    //MARK: - Properties -
    @IBOutlet weak var btnCode: UIButton!
    
    //MARK: - Life Cycle Functions -
    override func viewDidLoad() {
        super.viewDidLoad()
        self.btnCode.isHidden = true
        self.generateCodeAPI()
    }    
    
    //MARK: - Selectors -
    @IBAction func btnBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: - API Services -
    func generateCodeAPI() {
        if Connectivity.isConnectedToNetwork() {
            GenerateTVCodeManager.instance.generateTVCodeAPI { success, sessionError, error in
                if success != nil {
                    log.debug("success")
                    let code = success?.code
                    self.btnCode.isHidden = false
                    self.btnCode.setTitle(code, for: .normal)
                } else if sessionError != nil {
                    log.error("responseError = \(sessionError?.errors!.error_text ?? "")")
                    self.view.makeToast(sessionError?.errors!.error_text)
                } else {
                    log.error("error = \(error?.localizedDescription ?? "")")
                    self.view.makeToast(error?.localizedDescription ?? "")
                }
            }
        } else {
            self.view.makeToast(InterNetError)
        }
    }
    
}
