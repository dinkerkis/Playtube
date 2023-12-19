//
//  VideoPlayerView.swift
//  Playtube
//
//  Created by iMac on 21/04/23.
//  Copyright © 2023 ScriptSun. All rights reserved.
//


import UIKit
import AVKit
import PlaytubeSDK

//MARK: - VideoPlayerView Delegate

protocol VideoPlayerViewDelegate: AnyObject {
    func handleMinimizeVideoPlayer()
    func handleMaximizeVideoPlayer()
    func videoPlayStatusChanged(isPlaying: Bool)
    func didTapSettingButton(sender: UIButton)
    func playNextVideo()
    func playPreviousVideo()
    func autoPlayNextVideo()
    func handleFullScreenVideoPlayer()
}

// MARK: - Video Player Mode
enum VideoPlayerMode: Int {
    case expanded, minimized
}

class VideoPlayerView: UIView {
    
    // MARK: - IBOutlets

    @IBOutlet var contentView: UIView!
    @IBOutlet weak var playerContainerView: UIView!
    @IBOutlet weak var elapsedTimeLabel: UILabel!
    @IBOutlet weak var playbackSlider: CustomSlider!    
    @IBOutlet weak var pausePlayButton: UIButton!
    @IBOutlet weak var skipBackwardButton: UIButton!
    @IBOutlet weak var skipForwardButton: UIButton!
    @IBOutlet weak var backwardButton: UIButton!
    @IBOutlet weak var forwardButton: UIButton!
    @IBOutlet weak var fullScreenModeButton: UIButton!
    @IBOutlet weak var minimizeVideoPlayerButton: UIButton!
    @IBOutlet weak var pictureInPictureButton: UIButton!
    @IBOutlet weak var settingButton: UIButton!
    @IBOutlet weak var settingButtonTopConst: NSLayoutConstraint!
    
    // MARK: - Properties
    
    var player: AVPlayer?
    var playerLayer: AVPlayerLayer?
    var pictureInPictureController: AVPictureInPictureController!
    fileprivate var isScrubAble = false
    weak var delegate: VideoPlayerViewDelegate?
    var videoPlayerMode: VideoPlayerMode = .expanded
    fileprivate var timeObserverToken: Any?    
    var parentView: VideoPlayerContainerView!
    var picture_In_Picture = false
    
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
        Bundle.main.loadNibNamed("VideoPlayerView", owner: self, options: nil)
        self.contentView.isOpaque = false
        self.contentView.backgroundColor = .clear
        self.contentView.frame = self.bounds
        self.addSubview(self.contentView)
        self.setUpViews()
        self.setUpTapGesture()
    }
    
    // MARK: - Selectors
    
    // Minimize Player Button Action
    @IBAction func minimizePlayerButtonAction(_ sender: UIButton) {
        delegate?.handleMinimizeVideoPlayer()
    }
    
    // Picture In Picture Button Action
    @IBAction func pictureInPictureButtonAction(_ sender: UIButton) {
        if AVPictureInPictureController.isPictureInPictureSupported() && !pictureInPictureController.isPictureInPictureActive {
            pictureInPictureController.startPictureInPicture()
        }
    }
    
    // Setting Button Action
    @IBAction func settingButtonAction(_ sender: UIButton) {
        delegate?.didTapSettingButton(sender: sender)
    }
    
    // Play Pause Button Action
    @IBAction func playPauseButtonAction(_ sender: UIButton) {
        guard let player = player else {return}
        if player.isPlaying {
            player.pause()
            delegate?.videoPlayStatusChanged(isPlaying: false)
        } else {
            player.play()
            delegate?.videoPlayStatusChanged(isPlaying: true)
        }
        self.pausePlayButton.setImage(player.icon, for: .normal)
    }
    
    // Skip Backward Button Action
    @IBAction func skipBackwardButtonAction(_ sender: UIButton) {
        guard let currentTime = player?.currentTime(), isScrubAble else { return }
        let currentTimeInSecondsMinus10 =  CMTimeGetSeconds(currentTime).advanced(by: -10)
        let seekTime = CMTime(value: CMTimeValue(currentTimeInSecondsMinus10), timescale: 1)
        player?.seek(to: seekTime)
    }
    
    // Skip Forward Button Action
    @IBAction func skipForwardButtonAction(_ sender: UIButton) {
        guard let currentTime = player?.currentTime(), isScrubAble else { return }
        let currentTimeInSecondsPlus10 =  CMTimeGetSeconds(currentTime).advanced(by: 10)
        let seekTime = CMTime(value: CMTimeValue(currentTimeInSecondsPlus10), timescale: 1)
        player?.seek(to: seekTime)
    }
    
    // Backward Button Action
    @IBAction func backwardButtonAction(_ sender: UIButton) {
        self.delegate?.playPreviousVideo()
    }
    
    // Forward Button Action
    @IBAction func forwardButtonAction(_ sender: UIButton) {
        self.delegate?.playNextVideo()
    }
    
    // Full Screen Mode Button Action
    @IBAction func fullScreenModeButtonAction(_ sender: UIButton) {
        self.delegate?.handleFullScreenVideoPlayer()
    }
    
    // Playback Slider Action
    @IBAction func playbackSliderAction(_ sender: CustomSlider) {
        guard let duration = player?.currentItem?.duration, isScrubAble else { return }
        let value = Float64(playbackSlider.value) * CMTimeGetSeconds(duration)
        let seekTime = CMTime(value: CMTimeValue(value), timescale: 1)
        player?.seek(to: seekTime)
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
        [pausePlayButton, skipBackwardButton, backwardButton, skipForwardButton, forwardButton, elapsedTimeLabel, fullScreenModeButton, minimizeVideoPlayerButton, playbackSlider, settingButton, pictureInPictureButton].forEach { view in
            UIView.animate(withDuration: 0.4, delay: 0) {[weak view] in
                guard let view = view else { return }
                view.alpha = view.alpha == 0 ? 1 : 0
                self.isHidden(view.alpha == 0)
            }
        }
    }
    
    //MARK: - Methods
    
    fileprivate func setUpViews() {
        self.playbackSlider.setThumbImage(#imageLiteral(resourceName: "thumb").withRenderingMode(.alwaysOriginal), for: .normal)
        self.playbackSlider.setThumbImage(#imageLiteral(resourceName: "thumb").withRenderingMode(.alwaysOriginal), for: .highlighted)
    }
    
    fileprivate func setUpTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGestureAction))
        self.playerContainerView.isUserInteractionEnabled = true
        self.playerContainerView.addGestureRecognizer(tapGesture)
    }
    
    func initializePlayer(for url: URL) {
        DispatchQueue.main.async {
            self.setUpPlayer(with: url)
        }
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
        self.picture_In_Picture = UserDefaults.standard.getPictureInPicture(Key: Local.GET_SETTINGS.picture_In_Picture)
        if picture_In_Picture {
            pictureInPictureController = AVPictureInPictureController(playerLayer: playerLayer ?? AVPlayerLayer())
            pictureInPictureController.delegate = self
        } else {
            self.pictureInPictureButton.isHidden = true
        }
        delegate?.videoPlayStatusChanged(isPlaying: true)
        setUpPeriodicTimeObserver()
        self.parentView.activityIndicator.stopAnimating()
        player.addObserver(self, forKeyPath: "currentItem.loadedTimeRanges", options: .new, context: nil)
        //alerts that video completed playing
        NotificationCenter.default.addObserver(self, selector: #selector(playerDidPlayToEndTime(notification:)),
                                               name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player.currentItem)
    }
    
    private func setUpPeriodicTimeObserver() {
        let interval = CMTime(seconds: 0.001, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        timeObserverToken = self.player?.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main, using: { [weak self] (elapsedTime) in
            self?.updateVideoPlayerState(with: elapsedTime)
        })
    }
    
    private func updateVideoPlayerState(with elapsedTime: CMTime) {
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
    }
    
    @objc fileprivate func playerDidPlayToEndTime(notification: Notification) {
        if UserDefaults.standard.getAutoPlay() {
            self.delegate?.autoPlayNextVideo()
        } else {
            player?.seek(to: CMTime.zero)
            player?.play()
        }
    }

    fileprivate func prepareViewForReuse() {
        let imageName = "bold_ic_round_pause"
        pausePlayButton.setImage(UIImage(named: imageName), for: .normal)
        elapsedTimeLabel.text = ""
        self.isHidden(true)
    }
    
    func isHidden(_ hide: Bool) {
        var view = [pausePlayButton, skipBackwardButton, backwardButton, skipForwardButton, forwardButton, elapsedTimeLabel]
        view.append(contentsOf: [fullScreenModeButton, minimizeVideoPlayerButton, playbackSlider, settingButton, pictureInPictureButton])
        view.forEach { view in
            if view == pictureInPictureButton {
                if self.picture_In_Picture {
                    view?.isHidden = hide
                }
            } else {
                view?.isHidden = hide
            }
        }
    }
    
    func isEnableForwardButton(_ enable: Bool) {
        self.forwardButton.isEnabled = enable
    }
    
    func isEnableBackwardButton(_ enable: Bool) {
        self.backwardButton.isEnabled = enable
    }
    
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
    
    // MARK: - Player Observer
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        //This is when the player is ready and rendering frames
        if keyPath == "currentItem.loadedTimeRanges" {
            isScrubAble = true
        }
    }
    
}

extension VideoPlayerView: AVPictureInPictureControllerDelegate {
    
    func pictureInPictureControllerDidStartPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        // Picture in Picture started
        // You can update your UI or perform any additional tasks
    }
    
    func pictureInPictureControllerDidStopPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        // Picture in Picture stopped
        // You can update your UI or perform any additional tasks
    }
    
    func pictureInPictureControllerWillStopPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        // Picture in Picture will stop
        // You can update your UI or perform any additional tasks
    }
    
}
