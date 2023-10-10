//
//  AdPlayerView.swift
//  Playtube
//
//  Created by iMac on 09/06/23.
//  Copyright © 2023 ScriptSun. All rights reserved.
//

import UIKit
import AVKit

protocol AdPlayerViewDelegate {
    func handleMaximizeVideoPlayer()
    func handlePlayerDidPlayToEndTime()
    func handleFullScreenVideoPlayer()
}

class AdPlayerView: UIView {
    
    // MARK: - IBOutlets

    @IBOutlet var contentView: UIView!
    @IBOutlet weak var playerContainerView: UIView!
    @IBOutlet weak var elapsedTimeLabel: UILabel!
    @IBOutlet weak var playbackSlider: CustomSlider!
    @IBOutlet weak var fullScreenModeButton: UIButton!
    @IBOutlet weak var visitAdvertiserButton: UIButton!
    @IBOutlet weak var skipAdsButton: UIButton!
    
    // MARK: - Properties
    
    var player: AVPlayer?
    var playerLayer: AVPlayerLayer?
    fileprivate var timeObserverToken: Any?
    fileprivate var isScrubAble = false
    var videoPlayerMode: VideoPlayerMode = .expanded
    var delegate: AdPlayerViewDelegate?
    var video_ad: Video_ad?
    
    // MARK: - View Initialize Methods
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    deinit {
        self.cleanUpPlayerForReuse()
    }
    
    private func commonInit() {
        self.initialConfig()
    }
    
    func initialConfig() {
        Bundle.main.loadNibNamed("AdPlayerView", owner: self, options: nil)
        self.contentView.isOpaque = false
        self.contentView.backgroundColor = .clear
        self.contentView.frame = self.bounds
        self.addSubview(self.contentView)
        self.setUpViews()
        self.setUpTapGesture()
    }
    
    // MARK: - Selectors
    
    // Skip Button Action
    @IBAction func skipButtonAction(_ sender: UIButton) {
        self.delegate?.handlePlayerDidPlayToEndTime()
    }
    
    // Visit Advertiser Button Action
    @IBAction func visitAdvertiserButtonAction(_ sender: UIButton) {
        if let url = URL(string: (self.video_ad?.ad_link ?? "")) {
            UIApplication.shared.open(url)
        }
    }
    
    // Full Screen Mode Button Action
    @IBAction func fullScreenModeButtonAction(_ sender: UIButton) {
        self.delegate?.handleFullScreenVideoPlayer()
    }
    
    // MARK: - Helper Functions

    func cleanUpPlayerForReuse() {
        prepareViewForReuse()
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player?.currentItem)
        if let timeObserverToken = timeObserverToken {
            player?.removeTimeObserver(timeObserverToken)
            self.timeObserverToken = nil
            player?.replaceCurrentItem(with: nil)
            player = nil
            playerLayer = nil
            playbackSlider.value = 0
            isScrubAble = false
        }
    }
    
    fileprivate func prepareViewForReuse() {
        elapsedTimeLabel.text = ""
        self.isHidden(false)
    }
    
    fileprivate func setUpViews() {
        self.playbackSlider.setThumbImage(#imageLiteral(resourceName: "thumb").withRenderingMode(.alwaysOriginal), for: .normal)
        self.playbackSlider.setThumbImage(#imageLiteral(resourceName: "thumb").withRenderingMode(.alwaysOriginal), for: .highlighted)
    }
    
    fileprivate func setUpTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGestureAction))
        self.playerContainerView.isUserInteractionEnabled = true
        self.playerContainerView.addGestureRecognizer(tapGesture)
    }
    
    @objc fileprivate func handleTapGestureAction() {
        switch videoPlayerMode {
        case .expanded:
            guard isScrubAble else {return}
            handleToggleControls()
        case .minimized:
            delegate?.handleMaximizeVideoPlayer()
        }
    }
    
    fileprivate func handleToggleControls() {
        [elapsedTimeLabel, fullScreenModeButton, playbackSlider, skipAdsButton, visitAdvertiserButton].forEach { view in
            UIView.animate(withDuration: 0.4, delay: 0) {[weak view] in
                guard let view = view else {return}
                view.alpha = view.alpha == 0 ? 1 : 0
                self.isHidden(view.alpha == 0)
            }
        }
    }
    
    func initializePlayer(for url: URL, video_ad: Video_ad) {
        self.video_ad = video_ad
        self.setUpPlayer(with: url)
    }
    
    fileprivate func setUpPlayer(with url: URL) {
        cleanUpPlayerForReuse()
        let player = AVPlayer(url: url)
        playerLayer = AVPlayerLayer(player: player)
        playerLayer?.frame = self.playerContainerView.frame
        playerLayer?.videoGravity = AVLayerVideoGravity.resizeAspect
        self.player = player
        self.playerContainerView.layer.addSublayer(playerLayer!)
        self.player?.play()
        setUpPeriodicTimeObserver()
        player.addObserver(self, forKeyPath: "currentItem.loadedTimeRanges", options: .new, context: nil)
        // alerts that video completed playing
        NotificationCenter.default.addObserver(self, selector: #selector(playerDidPlayToEndTime(notification:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player.currentItem)
    }
    
    private func setUpPeriodicTimeObserver() {
        let interval = CMTime(seconds: 0.001, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        timeObserverToken = self.player?.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main, using: { [weak self] (elapsedTime) in
            self?.updateVideoPlayerState(with: elapsedTime)
        })
    }
    
    private  func updateVideoPlayerState(with elapsedTime: CMTime) {
        let seconds = CMTimeGetSeconds(elapsedTime)
        //lets move slider thumb
        guard let duration = player?.currentItem?.duration else {return}
        let durationSeconds = CMTimeGetSeconds(duration)
        let progress = Float(seconds / durationSeconds)
        playbackSlider.value = progress
        // Updating Elapsed Time
        let totalDurationInSeconds = CMTimeGetSeconds(duration)
        let secondsString = String(format: "%02d", Int(seconds .truncatingRemainder(dividingBy: 60)))
        let minutesString = String(format: "%02d", Int(seconds) / 60)
        let currentTime = "\(minutesString):\(secondsString)"
        guard totalDurationInSeconds.isFinite else {return}
        let videoLength = String(format: "%02d:%02d",Int((totalDurationInSeconds / 60)),Int(totalDurationInSeconds) % 60)
        elapsedTimeLabel.text = currentTime + " / " + videoLength
        let skipSecond = (Int(secondsString) ?? 0)
        if (self.video_ad?.skip_seconds ?? 0) >= skipSecond {
            let second = (self.video_ad?.skip_seconds ?? 0) - skipSecond
            self.skipAdsButton.setTitle("\(second)", for: .normal)
        } else {
            self.skipAdsButton.setTitle("Skip Ads > ", for: .normal)
        }
    }
    
    @objc fileprivate func playerDidPlayToEndTime(notification: Notification) {
        self.delegate?.handlePlayerDidPlayToEndTime()
    }
    
    func isHidden(_ hide: Bool) {
        [elapsedTimeLabel, fullScreenModeButton, playbackSlider, skipAdsButton, visitAdvertiserButton].forEach { view in
            view.isHidden = hide
        }
    }
    
    // MARK: - Player Observer
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        //This is when the player is ready and rendering frames
        if keyPath == "currentItem.loadedTimeRanges" {
            isScrubAble = true
        }
    }
    
}
