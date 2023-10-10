//
//  WebViewVC.swift
//  Playtube
//
//  Created by Macbook Pro on 04/04/2019.
//  Copyright © 2019 Muhammad Haris Butt. All rights reserved.
//

import UIKit
import WebKit
import PlaytubeSDK

class WebViewVC: BaseVC {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var headerTitle: UILabel!
    @IBOutlet weak var webView: WKWebView!
    
    // MARK: - Properties
    
    var boolStatus: Bool? = false
    var article: String? = ""
    var delegate: UploadVideoDelegate?
    
    // MARK: - View Life Cycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.showProgressDialog(text: NSLocalizedString("Loading...", comment: "Loading..."))
        self.webView.navigationDelegate = self
        self.webView.addObserver(self, forKeyPath: "URL", options: .new, context: nil)
        print("Cookie", AppInstance.instance.cookie ?? "")
        self.headerTitle.text = self.article
        if article == "Import" {
            webView.load(URLRequest(url: URL(string: API.Articles_Methods.IMPORT_VIDEO_API + "\(AppInstance.instance.cookie ?? "")&mode=day")!))
        } else if article == "Upload" || article == "Create a short" {
            webView.load(URLRequest(url: URL(string: API.Articles_Methods.UPLOAD_API + "\(AppInstance.instance.userId ?? 0)&cookie=\(AppInstance.instance.cookie ?? "")&mode=day")!))
        } else {
            webView.load(URLRequest(url: URL(string: API.Articles_Methods.CREATE_ARTICLE_API + "\(AppInstance.instance.cookie ?? "")&user_id=\(AppInstance.instance.userId ?? 0)&mode=day")!))
        }
    }
    
    // MARK: - Selectors
    
    // Back Button Action
    @IBAction func backButtonAction(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Helper Functions
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == #keyPath(WKWebView.url) {
            print("### URL:", self.webView.url!)
            let urL = (self.webView.url?.absoluteString)
            if ((urL?.contains("watch")) == true) {
                // self.delegate?.videoUploaded()
                NotificationCenter.default.post(name: Notification.Name("VideoUploded"), object: nil)
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
        
}

// MARK: - Extensions

// MARK: WKNavigationDelegate
extension WebViewVC: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.dismissProgressDialog {
            log.verbose("Dismissed")
            self.webView.evaluateJavaScript("var elements = document.getElementsByClassName('navbar navbar-findcond navbar-fixed-top header-layout');" + "$('.btn-fab-floating').hide();", completionHandler: nil)
        }
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        self.dismissProgressDialog {
            log.verbose("Dismissed")
        }
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        decisionHandler(.allow)
        guard let urlAsString = navigationAction.request.url?.absoluteString.lowercased() else {
            return
        }
        if urlAsString.range(of: "the url that the button redirects the webpage to") != nil {
            print(urlAsString)
        }
    }
    
}

//"var elements = document.getElementsByClassName('navbar navbar-findcond navbar-fixed-top header-layout');" +
//    " elements[0].style.display = 'none'; " +
//    "$('.header').hide();" +
//    "$('.pt_footer').hide();" +
//    "$('.btn-fab-floating').hide();" +
//    "$('.content-container').css('margin-top', '0');" +
//"$('.wo_about_wrapper_parent').css('top', '0');";
