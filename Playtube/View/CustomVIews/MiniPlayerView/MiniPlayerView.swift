//
//  MiniPlayerView.swift
//  Playtube
//
//  Created by iMac on 24/04/23.
//  Copyright © 2023 ScriptSun. All rights reserved.
//

import UIKit

protocol MiniPlayerViewDelegate: AnyObject {
    func handleExpandVideoPlayer()
    func handleDismissVideoPlayer()
    func handleChangePlayStatus(play: Bool)
}

class MiniPlayerView: UIView {
    
    // MARK: - IBOutlets

    @IBOutlet var contentView: UIView!
    @IBOutlet weak var videoTitleLabel: UILabel!
    @IBOutlet weak var channelNameLabel: UILabel!
    @IBOutlet weak var pausePlayButton: UIButton!
    
    // MARK: - Properties
    
    weak var delegate: MiniPlayerViewDelegate?
    var isPlaying: Bool = false
    
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
        Bundle.main.loadNibNamed("MiniPlayerView", owner: self, options: nil)
        self.contentView.frame = self.bounds
        self.addSubview(self.contentView)
        self.setUpGestureRecognizer()
    }
    
    // MARK: - Selectors
    
    // Play Pause Button Action
    @IBAction func playPauseButtonAction(_ sender: UIButton) {
        self.delegate?.handleChangePlayStatus(play: self.isPlaying)
    }
    
    // Close Button Action
    @IBAction func closeButtonAction(_ sender: UIButton) {
        self.delegate?.handleDismissVideoPlayer()
    }
    
    // MARK: - Helper Functions
    
    func configure(with data: VideoDetail) {
        self.videoTitleLabel.text = data.title
        self.channelNameLabel.text = data.owner?.username
    }
    
    func updatePlayButton(with imageName: String, isPlaying: Bool) {
        self.pausePlayButton.setImage(UIImage(named: imageName), for: .normal)
        self.isPlaying = isPlaying
    }
    
    fileprivate func setUpGestureRecognizer() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapExpandVideoPlayer))
        self.addGestureRecognizer(tapGesture)
    }
    
    @objc fileprivate func didTapExpandVideoPlayer() {
        delegate?.handleExpandVideoPlayer()
    }
    
    func isHidden( _ hide: Bool) {
        alpha = hide ? 0 : 1
    }

}
