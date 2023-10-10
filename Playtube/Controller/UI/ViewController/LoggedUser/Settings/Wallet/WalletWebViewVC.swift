//
//  WalletWebViewVC.swift
//  Playtube
//
//  Created by iMac on 17/06/23.
//  Copyright © 2023 ScriptSun. All rights reserved.
//

import UIKit
import WebKit

protocol PaystackWalletWebViewDelegate {
    func webView(_ isSuccess: Bool, referanceID: String)
}

protocol IyzipayWalletWebViewDelegate {
    
}

class WalletWebViewVC: UIViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var lblHeaderText: UILabel!
    @IBOutlet weak var webView: WKWebView! {
        didSet {
            self.webView.scrollView.alwaysBounceVertical = false
            self.webView.scrollView.alwaysBounceHorizontal = false
        }
    }
    
    // MARK: - Properties
    
    var paymentType = ""
    var urlString = ""
    var iyzipayJS = ""
    var paystackDelegate: PaystackWalletWebViewDelegate?
    var iyzipayDelegate: IyzipayWalletWebViewDelegate?
    
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
        self.dismiss(animated: true)
    }
    
    // MARK: - Helper Functions
    
    // Initial Config
    func initialConfig() {
        self.lblHeaderText.text = "Pay With " + self.paymentType
        if self.paymentType == "paystack" || self.paymentType == "paysera" {
            if let url = URL(string: self.urlString) {
                self.webView.load(URLRequest(url: url))
            }
        }
        if self.paymentType == "iyzipay" {
            let htmlString = """
<!DOCTYPE html>
    <html>
        <head>
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
        </head>
        <body>
            \(self.iyzipayJS)
        </body>
    </html>
"""
            self.iyzipayJS = htmlString
            if #available(iOS 11.0, *) {
                webView.configuration.preferences.setValue(true, forKey: "developerExtrasEnabled")
            }
            self.webView.loadHTMLString(self.iyzipayJS, baseURL: nil)
        }
        self.webView.navigationDelegate = self
    }
    
}

// MARK: -  Extensions

// MARK: WKNavigationDelegate Methods
extension WalletWebViewVC: WKNavigationDelegate {
    
    func getQueryStringParameter(url: String, param: String) -> String? {
        guard let url = URLComponents(string: url) else { return nil }
        return url.queryItems?.first(where: { $0.name == param })?.value
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let url = navigationAction.request.url {
            if url.absoluteString == "http://cancelurl.com/"{
                decisionHandler(.cancel)
            } else {
                decisionHandler(.allow)
            }
            if url.absoluteString.hasPrefix("https://demo.playtubescript.com") {
                let reference = getQueryStringParameter(url: url.absoluteString, param: "reference")
                if let reference = reference {
                    print("reference ID :--- \(reference)")
                    self.dismiss(animated: true) {
                        self.paystackDelegate?.webView(true, referanceID: reference)
                    }                    
                }
            }
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print(self.iyzipayJS)
    }
    
}
