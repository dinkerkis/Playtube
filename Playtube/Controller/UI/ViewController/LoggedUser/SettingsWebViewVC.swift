//
//  SettingsWebViewVC.swift
//  Playtube
//
//  Created by iMac on 03/07/23.
//  Copyright © 2023 ScriptSun. All rights reserved.
//

import UIKit
import WebKit
import PlaytubeSDK

class SettingsWebViewVC: UIViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var webView: WKWebView!
    
    // MARK: - Properties
    
    var headerText = ""
    
    // MARK: - View Life Cycles

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.initialConfig()
    }
    
    // MARK: - Selectors
    
    // Back Button Action
    @IBAction func backButtonAction(_ sender: UIButton) {
        self.view.endEditing(true)
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Helper Functions
    
    // Initial Config
    func initialConfig() {
        self.headerLabel.text = self.headerText
        self.setUpWebView()
    }
    
    // Setup WebView
    func setUpWebView() {
        var urlString = ""
        switch self.headerText {
        case "About":
            urlString = API.WEBSITE_URL.AboutUs
        case "Terms of use":
            urlString = API.WEBSITE_URL.TermsOfUse
        case "Privacy Policy":
            urlString = API.WEBSITE_URL.privacyPolicy
        case "Help":
            urlString = API.WEBSITE_URL.Help
        default:
            break
        }
        if let url = URL(string: urlString) {
            let urlRequest = URLRequest(url: url)
            self.webView.load(urlRequest)
        }
    }

}
