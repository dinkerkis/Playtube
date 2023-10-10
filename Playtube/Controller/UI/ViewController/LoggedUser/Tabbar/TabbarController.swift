//
//  TabbarController.swift
//  Playtube
//
//  Created by Ubaid Javaid on 5/20/20.
//  Copyright © 2020 Muhammad Haris Butt. All rights reserved.
//

import UIKit
import WebKit
import Combine
import JGProgressHUD
import SDWebImage
import AVKit
import Async
import Toast_Swift
import PlaytubeSDK

let MINI_PLAYER_HEIGHT: CGFloat = 80
let MINI_PLAYER_WIDTH: CGFloat = UIScreen.main.bounds.width / 3 + 10
let TOP_SAFE_AREA = UIApplication.shared.windows.first{$0.isKeyWindow}?.safeAreaInsets.top ?? 0
let BOTTOM_SAFE_AREA = UIApplication.shared.windows.first{$0.isKeyWindow}?.safeAreaInsets.bottom ?? 0
let obj_appDelegate = UIApplication.shared.delegate as! AppDelegate

protocol StatusBarHiddenDelegate: AnyObject {
    func handleUpdate(isStatusBarHidden: Bool)
}

class TabbarController: UITabBarController {
    
    // MARK: - Properties
    
    var selectedTabIndex = 0
    let videoPlayerContainerView: VideoPlayerContainerView = {
        let view = VideoPlayerContainerView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    fileprivate var videoPlayerContainerViewTopAnchor = NSLayoutConstraint()
    fileprivate lazy var playerSpacingAboveTabbar = tabBar.frame.height + MINI_PLAYER_HEIGHT
    fileprivate lazy var collapsedModePadding: CGFloat = UIScreen.main.bounds.height - playerSpacingAboveTabbar
    weak var statusBarHiddenDelegate: StatusBarHiddenDelegate?
    var videoPlayerMode: VideoPlayerMode = .expanded {
        didSet {
            if videoPlayerContainerView.videoPlayerView.isDescendant(of: videoPlayerContainerView.containerView) {
                videoPlayerContainerView.videoPlayerView.videoPlayerMode = videoPlayerMode
            }
            if videoPlayerContainerView.adPlayerView.isDescendant(of: videoPlayerContainerView.containerView) {
                videoPlayerContainerView.adPlayerView.videoPlayerMode = videoPlayerMode
            }
        }
    }
    fileprivate var isStatusBarHidden: Bool = false {
        didSet {
            if oldValue != self.isStatusBarHidden {
                statusBarHiddenDelegate?.handleUpdate(isStatusBarHidden: isStatusBarHidden)
            }
        }
    }
    fileprivate var isTabBarHidden = false {
        didSet {
            
        }
    }
    fileprivate let animationDuration: CGFloat = 0.4
    var hud : JGProgressHUD?
    var panGestureRecognizer = UIPanGestureRecognizer()
    var videoDataObject: VideoDetail?
    var purchaseId = 0
    var purchaseType = ""
    
    // MARK: - View Life Cycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self
        self.configureTabImageInset()
        self.setUpPlayerViews()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        if #available(iOS 16.0, *) {
            switch obj_appDelegate.window?.windowScene?.interfaceOrientation {
            case .portrait:
                self.panGestureRecognizer.isEnabled = true
                self.videoPlayerContainerView.containerViewMaxHeight = UIScreen.main.bounds.width * 9 / 16
                self.videoPlayerContainerView.containerViewMaxWidth = UIScreen.main.bounds.width
            case .landscapeRight, .portraitUpsideDown, .landscapeLeft:
                self.panGestureRecognizer.isEnabled = false
                self.videoPlayerContainerView.containerViewMaxWidth = UIScreen.main.bounds.width
                self.videoPlayerContainerView.containerViewMaxHeight = UIScreen.main.bounds.height
            default:
                break
            }
        } else {
            switch UIDevice.current.orientation {
            case .portrait:
                self.panGestureRecognizer.isEnabled = true
                self.videoPlayerContainerView.containerViewMaxWidth = UIScreen.main.bounds.height
                self.videoPlayerContainerView.containerViewMaxHeight = UIScreen.main.bounds.height * 9 / 16
            case .landscapeRight:
                self.panGestureRecognizer.isEnabled = false
                self.videoPlayerContainerView.containerViewMaxWidth = UIScreen.main.bounds.height
                self.videoPlayerContainerView.containerViewMaxHeight = UIScreen.main.bounds.width
            case .portraitUpsideDown:
                self.panGestureRecognizer.isEnabled = false
                self.videoPlayerContainerView.containerViewMaxWidth = UIScreen.main.bounds.width
                self.videoPlayerContainerView.containerViewMaxHeight = UIScreen.main.bounds.height
            case .landscapeLeft:
                self.panGestureRecognizer.isEnabled = false
                if obj_appDelegate.window?.windowScene?.interfaceOrientation.isPortrait ?? false {
                    self.videoPlayerContainerView.containerViewMaxWidth = UIScreen.main.bounds.height
                    self.videoPlayerContainerView.containerViewMaxHeight = UIScreen.main.bounds.width
                } else {
                    self.videoPlayerContainerView.containerViewMaxWidth = UIScreen.main.bounds.width
                    self.videoPlayerContainerView.containerViewMaxHeight = UIScreen.main.bounds.height
                }
            default:
                break
            }
        }
        self.videoPlayerContainerView.containerViewHeightAnchor.constant = self.videoPlayerContainerView.containerViewMaxHeight
        self.videoPlayerContainerView.containerViewWidthAnchor.constant = self.videoPlayerContainerView.containerViewMaxWidth
        if videoPlayerContainerView.videoPlayerView.isDescendant(of: videoPlayerContainerView.containerView) {
            self.videoPlayerContainerView.videoPlayerView.playerLayer?.frame = CGRect(x: 0, y: 0, width: self.videoPlayerContainerView.containerViewMaxWidth, height: self.videoPlayerContainerView.containerViewMaxHeight)
        }
        if videoPlayerContainerView.adPlayerView.isDescendant(of: videoPlayerContainerView.containerView) {
            self.videoPlayerContainerView.adPlayerView.playerLayer?.frame = CGRect(x: 0, y: 0, width: self.videoPlayerContainerView.containerViewMaxWidth, height: self.videoPlayerContainerView.containerViewMaxHeight)
        }
    }
    
    // MARK: - Helper Functions
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if isTabBarHidden {
            let offset = tabBar.frame.height
            let tabBar = tabBar
            tabBar.frame = tabBar.frame.offsetBy(dx: 0, dy: offset)
        }
    }
    
    fileprivate func configureTabImageInset() {
        guard let items = self.tabBar.items else { return }
        for (specificIndex, tabbarItem)  in items.enumerated() {
            if specificIndex == 2 {
                tabbarItem.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
            }
        }
    }
    
    @objc private func menuButtonAction() {
        let newVC = R.storyboard.popups.createPopupVC()
        newVC?.modalPresentationStyle = .custom
        newVC?.transitioningDelegate = self
        newVC?.delegate = self
        self.present(newVC!, animated: true)
    }
    
    fileprivate func setUpPlayerViews() {
        videoPlayerContainerView.tabBarController = self
        // videoPlayerContainerView
        view.insertSubview(videoPlayerContainerView, belowSubview: tabBar) // this is important because it allows us to be able to interact with the player in minimized mode
        videoPlayerContainerViewTopAnchor = videoPlayerContainerView.topAnchor.constraint(equalTo: view.topAnchor, constant: view.frame.height)
        videoPlayerContainerViewTopAnchor.isActive = true
        videoPlayerContainerView.anchor(top: nil, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, size: .init(width: 0, height: view.frame.height))
        videoPlayerContainerView.delegate = self
        videoPlayerContainerView.videoPlayerView.delegate = self
        videoPlayerContainerView.miniPlayerView.delegate = self
        videoPlayerContainerView.paidVideoView.delegate = self
        videoPlayerContainerView.adPlayerView.delegate = self
        setUpGestureRecognizers()
    }
    
    fileprivate func setUpGestureRecognizers() {
        self.panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture))
        videoPlayerContainerView.addGestureRecognizer(panGestureRecognizer)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(expandVideoPlayer))
        videoPlayerContainerView.containerView.addGestureRecognizer(tapGesture)
    }
    
    func handleOpenVideoPlayer(for content: VideoDetail, isPreviousVideo: Bool = false) {
        if content.is_short == 1 {
            let newVC = R.storyboard.loggedUser.shortsVC()
            newVC?.shortsVideosArray = [content]
            newVC?.isFromTabbar = false
            newVC?.currentIndexPath = IndexPath(row: 0, section: 0)
            self.navigationController?.pushViewController(newVC!, animated: true)
            return
        }
        self.videoDataObject = content
        var age = 0
        if AppInstance.instance.userType == 0 {
            age = 0
        } else {
            age = AppInstance.instance.userProfile?.data?.age ?? 0
        }
        let isBelow18 = age > 0 && age < 18
        self.videoPlayerContainerView.removeSubView()
        if isPreviousVideo == false {
            videoPlayerContainerView.previousVideosArray.append(content)
        }
        videoPlayerContainerView.videoPlayerView.isEnableBackwardButton(videoPlayerContainerView.previousVideosArray.count > 1)
        print("Previous Videos Array Count >>>>", videoPlayerContainerView.previousVideosArray.count)
        videoPlayerContainerView.fetchVideoDetails(object: content)
        videoPlayerContainerView.miniPlayerView.configure(with: content)
        // setup video thumbnail
        let imageUrl = URL(string: content.thumbnail ?? "")
        DispatchQueue.global(qos: .userInteractive).async {
            self.videoPlayerContainerView.thumbnailImageView.sd_setImage(with: imageUrl , placeholderImage: R.image.maxresdefault())
        }
        self.videoPlayerContainerView.activityIndicator.layer.zPosition = 1
        self.videoPlayerContainerView.activityIndicator.startAnimating()
        if content.is_owner != nil && content.is_owner == false && content.age_restriction == 2 && isBelow18 {
            if AppInstance.instance.userType == 0 {
                self.videoPlayerContainerView.initializeVideoPlayerErrorView(errorImage: UIImage(named: "ic_eighteen"), description: "This video is age restricted for viewers under +18\nCreate an account or login to confirm your age.")
            } else {
                self.videoPlayerContainerView.initializeVideoPlayerErrorView(errorImage: UIImage(named: "ic_eighteen"), description: "This video is age restricted for viewers under +18")
            }
        } else {
            var countryString = ""
            let countryLocale = NSLocale.current
            let countryCode = countryLocale.regionCode
            let country = (countryLocale as NSLocale).displayName(forKey: NSLocale.Key.countryCode, value: (countryCode ?? ""))
            print((countryCode ?? ""), (country ?? ""))
            countryString = country ?? ""
            if content.geo_blocking != nil && content.is_owner == false {
                var countryLockBool = false
                let stringArrayCleaned = content.geo_blocking?.replacingOccurrences(of: "\"", with: "").replacingOccurrences(of: ",", with: "\n").replacingOccurrences(of: "[", with: "").replacingOccurrences(of: "]", with: "").replacingOccurrences(of: " ", with: "")
                let geoRestrictionString = stringArrayCleaned!.split(separator: "\n")
                log.verbose("Geoblockingfortest = " + (stringArrayCleaned ?? ""))
                geoRestrictionString.forEach({ (it) in
                    log.verbose("ItCheck = \(it.description.htmlAttributedString ?? "")")
                    if it.description.contains(countryString) {
                        countryLockBool = true
                        return
                    } else {
                        countryLockBool = false
                    }
                })
                if countryLockBool {
                    self.videoPlayerContainerView.initializeVideoPlayerErrorView(errorImage: UIImage(named: "ic_location"), description: "This video is not available in your location")
                } else {
                    self.playVideoFromContent(content: content)
                }
            } else {
                self.playVideoFromContent(content: content)
            }
        }
        self.expandVideoPlayer()
    }
    
    func playVideoFromContent(content: VideoDetail) {
        var sell_video = 0.0
        switch content.sell_video {
        case .integer(let value as NSNumber):
            sell_video = value.doubleValue
        case .string(let value as NSString):
            sell_video = value.doubleValue
        case .double(let value):
            sell_video = value
        default:
            break
        }
        if (content.owner?.am_i_subscribed == 0 && content.owner?.subscriber_price != "0") || sell_video > 0 {
            self.videoPlayerContainerView.initializePaidVideoView(for: content)
        } else {
            if content.source == "YouTube" || content.source == "youtu" || content.video_type == "VideoObject/youtube" {
                self.videoPlayerContainerView.initializeYoutubePlayer(for: content.youtube ?? "")
            } else if content.source == "Vimeo" {
                self.videoPlayerContainerView.initializeVimeoPlayer(for: content.vimeo ?? "")
            } else if content.source == "Dailymotion" {
                self.videoPlayerContainerView.setupDailyMotionPlayer(videoId: content.daily ?? "", controller: self)
            } else if content.source == "Twitch" {
                if content.twitch_type == "clip" {
                    self.videoPlayerContainerView.initializeTwitchClipPlayer(for: content.twitch ?? "")
                } else {
                    self.videoPlayerContainerView.initializeTwitchPlayer(for: content.twitch ?? "")
                }
            } else if content.source == "Facebook" {
                self.videoPlayerContainerView.initializeFaceBookPlayer(for: content.facebook ?? "")
            } else {
                if let url = URL(string: (content.video_location ?? "")) {
                    self.videoPlayerContainerView.initializePlayer(for: url)
                }
            }
        }
    }
    
    @objc fileprivate func expandVideoPlayer() {
        if self.videoPlayerContainerView.videoPlayerView.isDescendant(of: self.videoPlayerContainerView.containerView) {
            videoPlayerContainerView.videoPlayerView.isHidden(false)
        }
        if self.videoPlayerContainerView.adPlayerView.isDescendant(of: self.videoPlayerContainerView.containerView) {
            videoPlayerContainerView.adPlayerView.isHidden(false)
        }
        isTabBarHidden = true
        videoPlayerContainerViewTopAnchor.constant = 0
        videoPlayerContainerView.containerViewHeightAnchor.constant = videoPlayerContainerView.containerViewMaxHeight
        maximizeVideoPlayerViewWidth()
        isStatusBarHidden = true
        videoPlayerMode = .expanded
        UIView.animate(withDuration: animationDuration, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseIn) {[weak self] in
            self?.view.layoutIfNeeded()
        }
    }
    
    fileprivate func maximizeVideoPlayerViewWidth() {
        videoPlayerContainerView.miniPlayerView.isHidden(true)
        // animate video player width back to expanded mode
        if videoPlayerContainerView.containerViewWidthAnchor.constant < videoPlayerContainerView.containerViewMaxWidth {
            videoPlayerContainerView.containerViewWidthAnchor.constant = videoPlayerContainerView.containerViewMaxWidth
            if self.videoPlayerContainerView.videoPlayerView.isDescendant(of: self.videoPlayerContainerView.containerView) {
                videoPlayerContainerView.videoPlayerView.playerLayer?.frame.origin.x = 0
                videoPlayerContainerView.videoPlayerView.playerLayer?.frame.origin.y = 0
                videoPlayerContainerView.videoPlayerView.playerLayer?.frame.size.width = UIScreen.main.bounds.width
                videoPlayerContainerView.videoPlayerView.playerLayer?.frame.size.height = videoPlayerContainerView.containerViewMaxHeight
            }
            if self.videoPlayerContainerView.adPlayerView.isDescendant(of: self.videoPlayerContainerView.containerView) {
                videoPlayerContainerView.adPlayerView.playerLayer?.frame.origin.x = 0
                videoPlayerContainerView.adPlayerView.playerLayer?.frame.origin.y = 0
                videoPlayerContainerView.adPlayerView.playerLayer?.frame.size.width = UIScreen.main.bounds.width
                videoPlayerContainerView.adPlayerView.playerLayer?.frame.size.height = videoPlayerContainerView.containerViewMaxHeight
            }
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseIn) {[ weak view] in
                view?.layoutIfNeeded()
            }
        }
    }
    
    @objc fileprivate func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .changed:
            let translation = gesture.translation(in: view)
            dragVideoPlayerContainerView(to: translation.y)
            if self.videoPlayerContainerView.videoPlayerView.isDescendant(of: self.videoPlayerContainerView.containerView) {
                videoPlayerContainerView.videoPlayerView.isHidden(true)
            }
            if self.videoPlayerContainerView.adPlayerView.isDescendant(of: self.videoPlayerContainerView.containerView) {
                videoPlayerContainerView.adPlayerView.isHidden(true)
            }
            switch gesture.direction(in: view) {
            case .up:
                increaseVideoPlayerViewHeight()
                maximizeVideoPlayerViewWidth()
            case .down:
                decreaseVideoPlayerViewHeight()
            default:
                break
            }
            gesture.setTranslation(.zero, in: view)
        case .failed, .cancelled, .ended:
            videoPlayerMode = gesture.direction(in: view) == .down ? .minimized : .expanded
            onGestureCompletion(mode: videoPlayerMode)
        default:
            break
        }
    }
    
    fileprivate func dragVideoPlayerContainerView(to yPoint: CGFloat) {
        // Prevents user from dragging videoPlayerContainerView past 0
        if videoPlayerContainerViewTopAnchor.constant < 0 {
            videoPlayerContainerViewTopAnchor.constant = 0
        } else {
            // Allows us to  drag the videoPlayerContainerView up & down
            videoPlayerContainerViewTopAnchor.constant += yPoint
        }
    }
    
    func increaseVideoPlayerViewHeight() {
        if videoPlayerContainerView.containerViewHeightAnchor.constant < videoPlayerContainerView.containerViewMaxHeight {
            videoPlayerContainerView.containerViewHeightAnchor.constant += 2
        }
    }
    
    fileprivate func decreaseVideoPlayerViewHeight() {
        isStatusBarHidden = false
        // minimizes video player as user drags down and makes sure it never gets smaller than minVideoPlayerHeight
        let heightLimit: CGFloat = 120
        if videoPlayerContainerView.containerViewHeightAnchor.constant > heightLimit {
            videoPlayerContainerView.containerViewHeightAnchor.constant -= 2
        }
    }
    
    fileprivate func onGestureCompletion(mode: VideoPlayerMode) {
        switch mode {
        case .expanded:
            expandVideoPlayer()
        case .minimized:
            minimizeVideoPlayer()
        }
    }
    
    fileprivate func minimizeVideoPlayer() {
        if self.videoPlayerContainerView.videoPlayerView.isDescendant(of: self.videoPlayerContainerView.containerView) {
            videoPlayerContainerView.videoPlayerView.isHidden(true)
        }
        if self.videoPlayerContainerView.adPlayerView.isDescendant(of: self.videoPlayerContainerView.containerView) {
            videoPlayerContainerView.adPlayerView.isHidden(true)
        }
        isTabBarHidden = false
        videoPlayerContainerViewTopAnchor.constant = collapsedModePadding
        videoPlayerContainerView.containerViewHeightAnchor.constant = MINI_PLAYER_HEIGHT
        minimizeVideoPlayerViewWidth()
        isStatusBarHidden = false
        videoPlayerMode = .minimized
        UIView.animate(withDuration: animationDuration, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0.7, options: .curveEaseIn) {[weak self] in
            self?.view.layoutIfNeeded()
        }
    }
    
    fileprivate func minimizeVideoPlayerViewWidth() {
        // animates video player width into collapsed mode
        videoPlayerContainerView.miniPlayerView.isHidden(false)
        if videoPlayerContainerView.containerViewWidthAnchor.constant == videoPlayerContainerView.containerViewMaxWidth {
            videoPlayerContainerView.containerViewWidthAnchor.constant = MINI_PLAYER_WIDTH
            if self.videoPlayerContainerView.videoPlayerView.isDescendant(of: self.videoPlayerContainerView.containerView) {
                videoPlayerContainerView.videoPlayerView.playerLayer?.frame.origin.x = 0
                videoPlayerContainerView.videoPlayerView.playerLayer?.frame.origin.y = 0
                videoPlayerContainerView.videoPlayerView.playerLayer?.frame.size.width = MINI_PLAYER_WIDTH
                videoPlayerContainerView.videoPlayerView.playerLayer?.frame.size.height = 80.0
            }
            if self.videoPlayerContainerView.adPlayerView.isDescendant(of: self.videoPlayerContainerView.containerView) {
                videoPlayerContainerView.adPlayerView.playerLayer?.frame.origin.x = 0
                videoPlayerContainerView.adPlayerView.playerLayer?.frame.origin.y = 0
                videoPlayerContainerView.adPlayerView.playerLayer?.frame.size.width = MINI_PLAYER_WIDTH
                videoPlayerContainerView.adPlayerView.playerLayer?.frame.size.height = 80.0
            }
            UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0.5, options: .curveEaseOut) { [weak self] in
                self?.view.layoutIfNeeded()
            }
        }
    }
    
    func showProgressDialog(text: String) {
        hud = JGProgressHUD(style: .dark)
        hud?.textLabel.text = text
        hud?.show(in: self.view)
    }
    
    func dismissProgressDialog(completionBlock: @escaping () ->()) {
        hud?.dismiss()
        completionBlock()
    }
    
}

// MARK: - Extensions

// MARK: VideoPlayerContainerViewDelegate
extension TabbarController: VideoPlayerContainerViewDelegate {
    
    func handleLoadVideoAd(video_ad: Video_ad) {
        if let url = URL(string: video_ad.ad_media ?? "") {
            guard let player = self.videoPlayerContainerView.videoPlayerView.player else { return }
            if player.isPlaying {
                player.pause()                
            }
            self.videoPlayerContainerView.videoPlayerView.pausePlayButton.setImage(player.icon, for: .normal)
            self.videoPlayerContainerView.videoPlayerView.isHidden(true)
            self.videoPlayerContainerView.initializeAdPlayer(for: url, video_ad: video_ad)
        }
    }
    
}

// MARK: VideoPlayerViewDelegate
extension TabbarController: VideoPlayerViewDelegate {
    
    func autoPlayNextVideo() {
        if (self.videoPlayerContainerView.suggestedVideosArray.isEmpty == true) || (self.videoPlayerContainerView.suggestedVideosArray.count == 0) {
            print("Nothing")
        } else {
            AppInstance.instance.addCount = AppInstance.instance.addCount! + 1
            guard let videoObject = self.videoPlayerContainerView.suggestedVideosArray.first else { return }
            self.handleOpenVideoPlayer(for: videoObject)
        }
    }
    
    func playNextVideo() {
        if (self.videoPlayerContainerView.suggestedVideosArray.isEmpty == true) || (self.videoPlayerContainerView.suggestedVideosArray.count == 0) {
            print("Nothing")
        } else {
            AppInstance.instance.addCount = AppInstance.instance.addCount! + 1
            guard let videoObject = self.videoPlayerContainerView.suggestedVideosArray.first else { return }
            self.handleOpenVideoPlayer(for: videoObject)
        }
    }
    
    func playPreviousVideo() {
        if (self.videoPlayerContainerView.previousVideosArray.isEmpty == true) || (self.videoPlayerContainerView.previousVideosArray.count == 0) {
            print("Nothing")
        } else {
            AppInstance.instance.addCount = AppInstance.instance.addCount! + 1
            self.videoPlayerContainerView.previousVideosArray.remove(at: self.videoPlayerContainerView.previousVideosArray.count - 1)
            let videoObject = self.videoPlayerContainerView.previousVideosArray[self.videoPlayerContainerView.previousVideosArray.count - 1]
            self.handleOpenVideoPlayer(for: videoObject, isPreviousVideo: true)
        }
    }
    
    func handleMinimizeVideoPlayer() {
        switch obj_appDelegate.window?.windowScene?.interfaceOrientation {
        case .portrait:
            minimizeVideoPlayer()
        default:
            break
        }
    }
    
    func handleMaximizeVideoPlayer() {
        expandVideoPlayer()
    }
    
    func videoPlayStatusChanged(isPlaying: Bool) {
        let imageName = isPlaying ? "icn_pause.fill" : "icn_play.fill"
        videoPlayerContainerView.miniPlayerView.updatePlayButton(with: imageName, isPlaying: isPlaying)
    }
    
    func handleFullScreenVideoPlayer() {
        DispatchQueue.main.async {
            switch obj_appDelegate.window?.windowScene?.interfaceOrientation {
            case .portrait:
                if #available(iOS 16.0, *) {
                    let windowScene = obj_appDelegate.window?.windowScene
                    windowScene?.requestGeometryUpdate(.iOS(interfaceOrientations: .landscapeLeft))
                    self.setNeedsUpdateOfSupportedInterfaceOrientations()
                } else {
                    let value = UIInterfaceOrientation.landscapeLeft.rawValue
                    UIDevice.current.setValue(value, forKey: "orientation")
                }
            case .landscapeLeft, .portraitUpsideDown, .landscapeRight:
                if #available(iOS 16.0, *) {
                    let windowScene = obj_appDelegate.window?.windowScene
                    windowScene?.requestGeometryUpdate(.iOS(interfaceOrientations: .portrait))
                    self.setNeedsUpdateOfSupportedInterfaceOrientations()
                } else {
                    let value = UIInterfaceOrientation.portrait.rawValue
                    UIDevice.current.setValue(value, forKey: "orientation")
                }
            default:
                break
            }
        }
    }
    
    func didTapSettingButton(sender: UIButton) {
        self.videoPlayerContainerView.dropDown.show()
    }
    
}

// MARK: MiniPlayerViewDelegate
extension TabbarController: MiniPlayerViewDelegate {
    
    func handleExpandVideoPlayer() {
        expandVideoPlayer()
    }
    
    func handleChangePlayStatus(play: Bool) {
        videoPlayerContainerView.videoPlayerView.playPauseButtonAction(videoPlayerContainerView.videoPlayerView.pausePlayButton)
    }
    
    func handleDismissVideoPlayer() {
        self.videoPlayerContainerView.previousVideosArray = []
        videoPlayerContainerView.videoPlayerView.cleanUpPlayerForReuse()
        videoPlayerContainerViewTopAnchor.constant = view.frame.height
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseIn) {[ weak self] in
            self?.view.layoutIfNeeded()
        }
    }
    
}

// MARK: AdPlayerViewDelegate
extension TabbarController: AdPlayerViewDelegate {
    
    func handlePlayerDidPlayToEndTime() {
        self.videoPlayerContainerView.adPlayerView.player?.seek(to: CMTime.zero)
        self.videoPlayerContainerView.adPlayerView.player?.pause()
        self.videoPlayerContainerView.adPlayerView.removeFromSuperview()
        guard let player = self.videoPlayerContainerView.videoPlayerView.player else { return }
        if !player.isPlaying {
            player.play()
        }
        self.videoPlayerContainerView.videoPlayerView.pausePlayButton.setImage(player.icon, for: .normal)
        self.videoPlayerContainerView.videoPlayerView.isHidden(false)
    }    
    
}

// MARK: PaidVideoViewDelegate
extension TabbarController: PaidVideoViewDelegate {
    
    func handlePaidVideoButtonTap(_ sender: UIButton) {
        let warningPopupVC = R.storyboard.popups.warningPopupVC()
        warningPopupVC?.delegate = self
        warningPopupVC?.titleText  = "Purchase Required"
        warningPopupVC?.messageText = "This video is being sold, you have to rent the video to watch it"
        warningPopupVC?.okText = "PURCHASE"
        self.present(warningPopupVC!, animated: true, completion: nil)
        warningPopupVC?.okButton.tag = 1002
    }
    
}

// MARK: UITabBarControllerDelegate Methods
extension TabbarController: UITabBarControllerDelegate {
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        self.selectedTabIndex = item.tag
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if AppInstance.instance.userType == 0 {
            if self.selectedTabIndex != 0 && self.selectedTabIndex != 1 {
                let warningPopupVC = R.storyboard.popups.warningPopupVC()
                warningPopupVC?.delegate = self
                warningPopupVC?.titleText  = "Warning"
                warningPopupVC?.messageText = "Sorry you can not continue, you must log in and enjoy access to everything you want"
                self.present(warningPopupVC!, animated: true, completion: nil)
                warningPopupVC?.okButton.tag = 1001
                return false
            } else {
                return true
            }
        } else {
            if self.selectedTabIndex == 2 {
                menuButtonAction()
                return false
            } else if self.selectedTabIndex == 3 {
                let newVC = R.storyboard.loggedUser.shortsVC()
                newVC?.isFromTabbar = true
                self.navigationController?.pushViewController(newVC!, animated: true)
                return false
            } else {
                return true
            }
        }
    }
    
}

// MARK: WarningPopupVCDelegate Methods
extension TabbarController: WarningPopupVCDelegate {
    
    func warningPopupOKButtonPressed(_ sender: UIButton) {
        if sender.tag == 1001 {
            let vc = R.storyboard.auth.loginVC()
            self.navigationController?.pushViewController(vc!, animated: true)
        }
        if sender.tag == 1002 {
            guard let content = self.videoDataObject else { return }
            var sell_video = 0.0
            switch content.sell_video {
            case .integer(let value as NSNumber):
                sell_video = value.doubleValue
            case .string(let value as NSString):
                sell_video = value.doubleValue
            case .double(let value):
                sell_video = value
            default:
                break
            }
            var amount = 0.0
            if (content.owner?.am_i_subscribed == 0 && content.owner?.subscriber_price != "0") || sell_video > 0 {
                if sell_video > 0 {
                    amount = sell_video
                    self.purchaseType = API.WALLET_PAY_TYPE.buy
                } else {
                    amount = ((content.owner?.subscriber_price ?? "") as NSString).doubleValue
                    self.purchaseType = API.WALLET_PAY_TYPE.subscribe
                }
            }
            print("Amount >>>>>", amount)
            AppInstance.instance.fetchUserProfile { success in
                if success {
                    let walletBalance = AppInstance.instance.userProfile?.data?.wallet?.rounded() ?? 0.0
                    self.purchaseId = (self.purchaseType == API.WALLET_PAY_TYPE.subscribe ? content.owner?.id : content.id) ?? 0
                    if amount < walletBalance {
                        self.payUsingWalletApi(pay_Type: self.purchaseType, id: self.purchaseId)
                    } else {
                        let warningPopupVC = R.storyboard.popups.warningPopupVC()
                        warningPopupVC?.delegate = self
                        warningPopupVC?.titleText  = "Wallet"
                        warningPopupVC?.messageText = "Sorry, You do not have enough money please top up your wallet"
                        warningPopupVC?.okText = "ADD WALLET"
                        self.present(warningPopupVC!, animated: true, completion: nil)
                        warningPopupVC?.okButton.tag = 1003
                    }
                }
            }
            
        }
        if sender.tag == 1003 {
            let newVC = R.storyboard.settings.walletVC()
            newVC?.isPurchase = true
            newVC?.delegate = self
            self.navigationController?.pushViewController(newVC!, animated: true)
        }
    }
    
}

// MARK: Api Call
extension TabbarController {
    
    func payUsingWalletApi(pay_Type: String, id: Int) {
        if Connectivity.isConnectedToNetwork() {
            self.showProgressDialog(text: NSLocalizedString("Loading...", comment: "Loading..."))
            let userID = AppInstance.instance.userId ?? 0
            let sessionID = AppInstance.instance.sessionId ?? ""
            Async.background {
                WalletManager.instance.payUsingWalletApi(user_id: userID, session_token: sessionID, pay_Type: pay_Type, id: id) { success, sessionError, error in
                    if success != nil {
                        Async.main {
                            self.dismissProgressDialog {
                                log.verbose("success \(success?.success ?? "")")
                            }
                        }
                    } else if sessionError != nil {
                        self.dismissProgressDialog {
                            log.verbose("sessionError = \(sessionError?.errors?.error_text ?? "")")
                            self.view.makeToast(sessionError?.errors?.error_text ?? "")
                        }
                    } else {
                        self.dismissProgressDialog {
                            log.verbose("error = \(error?.localizedDescription ?? "")")
                            self.view.makeToast(error?.localizedDescription ?? "")
                        }
                    }
                }
            }
        } else {
            self.view.makeToast(InterNetError)
        }
    }
    
}

extension TabbarController: ShowCreatePlayListDelegate {
    
    func showCreatePlaylist(Status: Bool) {
        let vc = R.storyboard.playlist.createNewPlaylistVC()
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
}

extension UITabBarController {
    
    func addSubviewToLastTabItem() {
        if AppInstance.instance.userType == 1 {
            if let lastTabBarButton = self.tabBar.subviews.last, let tabItemImageView = lastTabBarButton.subviews.first {
                if let accountTabBarItem = self.tabBar.items?.last {
                    accountTabBarItem.selectedImage = nil
                    accountTabBarItem.image = nil
                }
                let imgView = UIImageView()
                imgView.frame = tabItemImageView.frame
                imgView.layer.cornerRadius = tabItemImageView.frame.height/2
                imgView.layer.masksToBounds = true
                imgView.contentMode = .scaleAspectFill
                imgView.clipsToBounds = true
                let profileImage = URL(string: AppInstance.instance.userProfile?.data?.avatar ?? "")
                imgView.sd_setImage(with: profileImage , placeholderImage:R.image.maxresdefault())
                self.tabBar.subviews.last?.addSubview(imgView)
            }
        } else {
            log.verbose("Nothing to print ")
        }
    }
    
}


// MARK: UIViewControllerTransitioningDelegate Methods
extension TabbarController: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        BottomSheetPresentationController(presentedViewController: presented, presenting: presenting)
    }
}

// MARK: CreatePopupDelegate Methods
extension TabbarController: CreatePopupDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            let newVC = R.storyboard.loggedUser.webViewVC()
            newVC?.article = "Import"
            self.navigationController?.pushViewController(newVC!, animated: true)
        } else if indexPath.row == 1 {
            let newVC = R.storyboard.loggedUser.webViewVC()
            newVC?.article = "Upload"
            self.navigationController?.pushViewController(newVC!, animated: true)
        } else if indexPath.row == 2 {
            let newVC = R.storyboard.loggedUser.webViewVC()
            newVC?.article = "Create a short"
            self.navigationController?.pushViewController(newVC!, animated: true)
        } else if indexPath.row == 3 {
            let vc = R.storyboard.live.liveStreamController()
            vc?.modalPresentationStyle = .overFullScreen
            self.present(vc!, animated: true, completion: nil)
        }
    }
    
}

extension TabbarController: WalletVCDelegate {
    
    func handleAddMoneyInWalletForPurchase() {
        self.payUsingWalletApi(pay_Type: self.purchaseType, id: self.purchaseId)
    }
    
}
