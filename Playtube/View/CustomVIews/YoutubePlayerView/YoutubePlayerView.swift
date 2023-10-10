//
//  YoutubePlayerView.swift
//  Playtube
//
//  Created by iMac on 09/06/23.
//  Copyright © 2023 ScriptSun. All rights reserved.
//

import UIKit
import youtube_ios_player_helper

class YoutubePlayerView: UIView {
    
    // MARK: - IBOutlets
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var youtubePlayerView: YTPlayerView!
    
    // MARK: - Properties
    
    var playerVars = [
        "autoplay": 1,
        "controls": 1,
        "playsinline": 1,
        "autohide": 1,
        "showinfo": 0,
        "modestbranding": 1
    ]
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
        Bundle.main.loadNibNamed("YoutubePlayerView", owner: self, options: nil)
        self.contentView.isOpaque = false
        self.contentView.backgroundColor = .clear
        self.contentView.frame = self.bounds
        self.addSubview(self.contentView)
        self.youtubePlayerView.delegate = self
    }
    
    // MARK: - Helper Functions
    
    func initializeYoutubePlayer(for video_id: String) {
        self.youtubePlayerView.load(withVideoId: video_id, playerVars: self.playerVars)
        self.youtubePlayerView.webView?.scrollView.insetsLayoutMarginsFromSafeArea = false
        self.youtubePlayerView.webView?.scrollView.contentInsetAdjustmentBehavior = .never
        self.youtubePlayerView.webView?.scrollView.showsVerticalScrollIndicator = false
        self.youtubePlayerView.webView?.scrollView.showsHorizontalScrollIndicator = false
        self.youtubePlayerView.webView?.scrollView.isScrollEnabled = false
    }
    
}

// MARK: - Extensions
extension YoutubePlayerView: YTPlayerViewDelegate {
    
    func playerViewDidBecomeReady(_ playerView: YTPlayerView) {
        self.parentView.activityIndicator.stopAnimating()
    }
    
}
