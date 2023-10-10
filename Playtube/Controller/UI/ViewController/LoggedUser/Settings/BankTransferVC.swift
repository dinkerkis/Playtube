//
//  BankTransferVC.swift
//  Playtube
//
//  Created by Muhammad Haris Butt on 3/25/21.
//  Copyright © 2021 Muhammad Haris Butt. All rights reserved.
//

import UIKit
import Async
import PlaytubeSDK
import SwiftSoup
import Toast_Swift

class BankTransferVC: BaseVC {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var accountNumberLabel: UILabel!
    @IBOutlet weak var routineCodeLabel: UILabel!
    @IBOutlet weak var countryLabel: UILabel!
    @IBOutlet weak var accountNameLabel: UILabel!
    @IBOutlet weak var noteLabel: UILabel!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var receiptImage: UIImageView!
    
    // MARK: - Properties
    
    var amount = 0
    var isMediaStatus = false
    var mediaData: Data? = nil
    private let imagePickerController = UIImagePickerController()
    let site_settings = UserDefaults.standard.getSettings()
    
    // MARK: - View Life Cycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initialConfig()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    // MARK: - Selectors
    
    //Back Button Action
    @IBAction func backButtonAction(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    // Cancel Button Action
    @IBAction func cancelButtonAction(_ sender: UIButton) {
        self.receiptImage.image = UIImage(named: "maxresdefault")
        self.cancelBtn.isHidden = true
        self.mediaData = nil
        self.isMediaStatus = false
    }
    
    // Send Button Action
    @IBAction func sendButtonAction(_ sender: UIButton) {
        if !self.isMediaStatus {
            self.view.makeToast("Please add receipt")
        } else {
            self.uploadReceipt()
        }
    }
    
    // Select Picture Button Action
    @IBAction func selectPictureButtonAction(_ sender: UIButton) {
        log.verbose("Tapped ")
        let alert = UIAlertController(title: "", message: "Select Source", preferredStyle: .actionSheet)
        let camera = UIAlertAction(title: "Camera", style: .default) { (action) in
            self.imagePickerController.delegate = self
            self.imagePickerController.allowsEditing = true
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                self.imagePickerController.sourceType = .camera
            } else {
                self.view.makeToast("Camera is not availabel...")
                return
            }
            self.present(self.imagePickerController, animated: true, completion: nil)
        }
        let gallery = UIAlertAction(title: "Gallery", style: .default) { (action) in
            self.imagePickerController.delegate = self
            self.imagePickerController.allowsEditing = true
            self.imagePickerController.sourceType = .photoLibrary
            self.present(self.imagePickerController, animated: true, completion: nil)
        }
        let cancel = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        alert.addAction(camera)
        alert.addAction(gallery)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Helper Functions
    
    // Initial Config
    func initialConfig() {
        self.setData()
        self.cancelBtn.isHidden = true
    }
    
    // Set Data
    private func setData() {
        let bank_description = (self.site_settings?["bank_description"] as? String ?? "").htmlAttributedString?.replacingOccurrences(of: "\\", with: "") ?? ""
        self.accountNumberLabel.text = self.extractStringFromHTML(htmlString: bank_description, cssSelector: "div.bank_account p")
        self.routineCodeLabel.text = self.extractStringFromHTML(htmlString: bank_description, cssSelector: "div.bank_account_code p")
        self.countryLabel.text = self.extractStringFromHTML(htmlString: bank_description, cssSelector: "div.bank_account_country p")
        self.accountNameLabel.text = self.extractStringFromHTML(htmlString: bank_description, cssSelector: "div.bank_account_holder p")
        self.noteLabel.text = self.site_settings?["bank_transfer_note"] as? String ?? ""
    }
    
    // Extract String From HTML
    func extractStringFromHTML(htmlString: String, cssSelector: String) -> String? {
        do {
            let doc = try SwiftSoup.parse(htmlString)
            let elements = try doc.select(cssSelector)
            if let element = elements.first() {
                return try element.text()
            }
        } catch {
            print("Error parsing HTML: \(error)")
        }
        return nil
    }
    
}

// MARK: - Extensions

// MARK: Api Call
extension BankTransferVC {
    
    private func uploadReceipt() {
        if Connectivity.isConnectedToNetwork() {
            self.showProgressDialog(text: "Loading...")
            let session_token = AppInstance.instance.sessionId ?? ""
            let userId = AppInstance.instance.userId ?? 0
            let media = self.mediaData ?? Data()
            Async.background {
                BankTransferManager.instance.bankWalletApi(session_token: session_token, userID: userId, amount: self.amount, mediaData: media) { (success, sessionError, error) in
                    if success != nil{
                        Async.main({
                            self.dismissProgressDialog {
                                self.view.makeToast(success?.message ?? "")
                                self.navigationController?.popViewController(animated: true)
                            }
                        })
                    } else if sessionError != nil {
                        Async.main {
                            self.dismissProgressDialog {
                                self.view.makeToast(sessionError?.errors?.error_text ?? "")
                                log.error("sessionError = \(sessionError?.errors?.error_text ?? "")")
                            }
                        }
                    } else {
                        Async.main {
                            self.dismissProgressDialog {
                                self.view.makeToast(error?.localizedDescription ?? "")
                                log.error("error = \(error?.localizedDescription ?? "")")
                            }
                        }
                    }
                }
            }
        } else {
            log.error("internetError = \(InterNetError)")
            self.view.makeToast(InterNetError)
        }
    }
    
}

// MARK: UIImagePickerControllerDelegate
extension BankTransferVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        self.receiptImage.image = image
        self.mediaData = image.pngData()
        self.isMediaStatus = true
        self.cancelBtn.isHidden = false
        self.dismiss(animated: true, completion: nil)
    }
    
}
