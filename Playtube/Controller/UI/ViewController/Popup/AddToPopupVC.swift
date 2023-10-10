//
//  AddToPopupVC.swift
//  Playtube
//
//  Created by iMac on 29/06/23.
//  Copyright © 2023 ScriptSun. All rights reserved.
//

import UIKit

protocol AddToPopupVCDelegate {
    func handleSaveToPlaylistTap(_ sender: UIButton)
    func handleSaveToWatchLaterTap(_ sender: UIButton)
}

class AddToPopupVC: UIViewController {
    
    // MARK: - Properties
    
    var delegate: AddToPopupVCDelegate?
    
    // MARK: - View Life Cycles

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.initialConfig()
    }
    
    // MARK: - Selectors
    
    // Close Button Action
    @IBAction func closeButtonAction(_ sender: UIButton) {
        self.view.endEditing(true)
        self.dismiss(animated: true)
    }
    
    // Save to Playlist Button Action
    @IBAction func saveToPlaylistButtonAction(_ sender: UIButton) {
        self.view.endEditing(true)
        self.dismiss(animated: true) {
            self.delegate?.handleSaveToPlaylistTap(sender)
        }
    }
    
    // Save to Watch Later Button Action
    @IBAction func saveToWatchLaterButtonAction(_ sender: UIButton) {
        self.view.endEditing(true)
        self.dismiss(animated: true) {
            self.delegate?.handleSaveToWatchLaterTap(sender)
        }
    }
    
    // MARK: - Helper Functions
    
    // Initial Config
    func initialConfig() {
        self.view.backgroundColor = .black.withAlphaComponent(0.4)
    }

}
