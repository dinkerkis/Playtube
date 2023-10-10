//
//  TwitchClipPlayerView.swift
//  Playtube
//
//  Created by iMac on 14/06/23.
//  Copyright © 2023 ScriptSun. All rights reserved.
//

import UIKit

class TwitchClipPlayerView: UIView {

    // MARK: - IBOutlets
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var twitchClipPlayerView: TwitchClipPlayer!
    
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
        Bundle.main.loadNibNamed("TwitchClipPlayerView", owner: self, options: nil)
        self.contentView.isOpaque = false
        self.contentView.backgroundColor = .clear
        self.contentView.frame = self.bounds
        self.addSubview(self.contentView)
    }
    
    // MARK: - Helper Functions
    
    func initializeTwitchClipPlayer(for twitch: String) {
        self.twitchClipPlayerView.clipId = twitch
        self.twitchClipPlayerView.scrollView.insetsLayoutMarginsFromSafeArea = false
        self.twitchClipPlayerView.scrollView.contentInsetAdjustmentBehavior = .never
        self.twitchClipPlayerView.scrollView.showsVerticalScrollIndicator = false
        self.twitchClipPlayerView.scrollView.showsHorizontalScrollIndicator = false
        self.twitchClipPlayerView.scrollView.isScrollEnabled = false
        self.parentView.activityIndicator.stopAnimating()
    }
    
}
