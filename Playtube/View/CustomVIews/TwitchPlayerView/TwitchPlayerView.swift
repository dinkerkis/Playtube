//
//  TwitchPlayerView.swift
//  Playtube
//
//  Created by iMac on 14/06/23.
//  Copyright © 2023 ScriptSun. All rights reserved.
//

import UIKit

class TwitchPlayerView: UIView {

    // MARK: - IBOutlets
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var twitchPlayerView: TwitchPlayer!
    
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
        Bundle.main.loadNibNamed("TwitchPlayerView", owner: self, options: nil)
        self.contentView.isOpaque = false
        self.contentView.backgroundColor = .clear
        self.contentView.frame = self.bounds
        self.addSubview(self.contentView)
    }
    
    // MARK: - Helper Functions
    
    func initializeTwitchPlayer(for twitch: String) {
        self.twitchPlayerView.setVideo(to: twitch, timestamp: 0)
        self.twitchPlayerView.play()
        self.parentView.activityIndicator.stopAnimating()
        self.twitchPlayerView.scrollView.insetsLayoutMarginsFromSafeArea = false
        self.twitchPlayerView.scrollView.contentInsetAdjustmentBehavior = .never
        self.twitchPlayerView.scrollView.showsVerticalScrollIndicator = false
        self.twitchPlayerView.scrollView.showsHorizontalScrollIndicator = false
    }
    
}
