//
//  FacebookPlayerView.swift
//  Playtube
//
//  Created by iMac on 15/06/23.
//  Copyright © 2023 ScriptSun. All rights reserved.
//

import UIKit
import WebKit

class FacebookPlayerView: UIView {

    // MARK: - IBOutlets
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var facebookPlayerView: WKWebView!
    
    // MARK: - Properties
    
    var parentView: VideoPlayerContainerView!
    
    // MARK: - View Initialize Methods
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    private func commonInit() {
        self.initialConfig()
    }
    
    func initialConfig() {
        Bundle.main.loadNibNamed("FacebookPlayerView", owner: self, options: nil)
        self.contentView.isOpaque = false
        self.contentView.backgroundColor = .clear
        self.contentView.frame = self.bounds
        self.addSubview(self.contentView)
    }
    
    // MARK: - Helper Functions
    
    func initializeFaceBookPlayer(for facebook: String) {
        let embedCode = """
        <!DOCTYPE html>
        <html>
        <head>
            <title></title>
            <style type="text/css">
                body { margin: 0; }
            </style>
        </head>
        <body>
            <div id="fb-root"></div>
            <script>(function(d, s, id) {
                var js, fjs = d.getElementsByTagName(s)[0];
                if (d.getElementById(id)) return;
                js = d.createElement(s); js.id = id;
                js.src = "https://connect.facebook.net/en_US/sdk.js#xfbml=1&version=v13.0";
                fjs.parentNode.insertBefore(js, fjs);
            }(document, 'script', 'facebook-jssdk'));</script>
            <div class="fb-video" data-href="\(facebook)" data-width="100%" data-show-text="false" data-autoplay="true" data-allowfullscreen="true"></div>
        </body>
        </html>
        """
        self.facebookPlayerView.loadHTMLString(embedCode, baseURL: nil)
        self.parentView.activityIndicator.stopAnimating()
        self.facebookPlayerView.scrollView.insetsLayoutMarginsFromSafeArea = false
        self.facebookPlayerView.scrollView.contentInsetAdjustmentBehavior = .never
        self.facebookPlayerView.scrollView.showsVerticalScrollIndicator = false
        self.facebookPlayerView.scrollView.showsHorizontalScrollIndicator = false
    }
}
