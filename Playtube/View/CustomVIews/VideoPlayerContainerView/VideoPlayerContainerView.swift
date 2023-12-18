//
//  VideoPlayerContainerView.swift
//  Playtube
//
//  Created by iMac on 28/04/23.
//  Copyright © 2023 ScriptSun. All rights reserved.
//

import UIKit
import Async
import Toast_Swift
import PlaytubeSDK
import JGProgressHUD
import DropDown
import DailymotionPlayerSDK

protocol VideoPlayerContainerViewDelegate {
    func handleLoadVideoAd(video_ad: Video_ad)
}

class VideoPlayerContainerView: UIView {
    
    // MARK: - IBOutlets
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var containerViewHeightAnchor: NSLayoutConstraint!
    @IBOutlet weak var containerViewWidthAnchor: NSLayoutConstraint!
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var miniPlayerView: MiniPlayerView!
    @IBOutlet weak var tableView: UITableView!    
    
    // MARK: - Properties
    
    var videoPlayerView: VideoPlayerView = {
        let view = VideoPlayerView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var adPlayerView: AdPlayerView = {
        let view = AdPlayerView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var flowPlayerView: FlowPlayerView = {
        let view = FlowPlayerView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var dmPlayerView: DMPlayerView!
    var paidVideoView: PaidVideoView = {
        let view = PaidVideoView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var videoPlayerErrorView: VideoPlayerErrorView = {
        let view = VideoPlayerErrorView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var twitchPlayerView: TwitchPlayerView = {
        let view = TwitchPlayerView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var twitchClipPlayerView: TwitchClipPlayerView = {
        let view = TwitchClipPlayerView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var facebookPlayerView: FacebookPlayerView = {
        let view = FacebookPlayerView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var containerViewMaxHeight: CGFloat = UIScreen.main.bounds.width * 9 / 16
    var containerViewMaxWidth: CGFloat = UIScreen.main.bounds.width
    var videoDataObject: VideoDetail?
    private var isLoading = true
    var suggestedVideosArray: [VideoDetail] = []
    var previousVideosArray: [VideoDetail] = []
    var hud : JGProgressHUD?
    var EmptyVideo = 0
    var isCompleted = false
    var tabBarController: TabbarController!
    var dropDown = DropDown()
    var isShowDescription: Bool = false
    var delegate: VideoPlayerContainerViewDelegate?
    
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
        Bundle.main.loadNibNamed("VideoPlayerContainerView", owner: self, options: nil)
        self.contentView.isOpaque = false
        self.contentView.backgroundColor = .clear
        self.contentView.frame = self.bounds
        self.addSubview(self.contentView)
        self.setupUI()
        self.registerCell()
        self.customizeDropDownFunc()
    }
    
    // MARK: - Helper Functions
    
    // Setup UI
    func setupUI() {
        self.containerViewHeightAnchor.constant = self.containerViewMaxHeight
        self.containerViewWidthAnchor.constant = self.containerViewMaxWidth
    }
    
    // Register Cell
    func registerCell() {
        self.tableView.register(UINib(resource: R.nib.videoDetailCell), forCellReuseIdentifier: R.reuseIdentifier.videoDetailCell.identifier)
        self.tableView.register(UINib(resource: R.nib.emptyVideoCell), forCellReuseIdentifier: R.reuseIdentifier.emptyCell.identifier)
        self.tableView.register(UINib(resource: R.nib.playerNextTableItem), forCellReuseIdentifier: R.reuseIdentifier.playerNextTableItem.identifier)
        self.tableView.register(UINib(resource: R.nib.playerSectionHeader), forHeaderFooterViewReuseIdentifier: "DemoHeaderView")
        self.tableView.register(UINib(resource: R.nib.playerFooterSection), forHeaderFooterViewReuseIdentifier: "DemoFooterView")
        if #available(iOS 15, *) {
            tableView.sectionHeaderTopPadding = 0
        }
    }
    
    func dismissProgressDialog(completionBlock: @escaping () ->()) {
        hud?.dismiss()
        completionBlock()
    }
    
    func removeSubView() {
        if self.videoPlayerView.isDescendant(of: self.containerView) {
            self.videoPlayerView.removeFromSuperview()
        }
        if self.flowPlayerView.isDescendant(of: self.containerView) {
            self.flowPlayerView.removeFromSuperview()
        }
        if self.adPlayerView.isDescendant(of: self.containerView) {
            self.adPlayerView.removeFromSuperview()
        }
        if self.paidVideoView.isDescendant(of: self.containerView) {
            self.paidVideoView.removeFromSuperview()
        }
        if self.dmPlayerView != nil {
            self.dmPlayerView.removeFromSuperview()
        }
        if self.videoPlayerErrorView.isDescendant(of: self.containerView) {
            self.videoPlayerErrorView.removeFromSuperview()
        }
        if self.twitchPlayerView.isDescendant(of: self.containerView) {
            self.twitchPlayerView.removeFromSuperview()
        }
        if self.twitchClipPlayerView.isDescendant(of: self.containerView) {
            self.twitchClipPlayerView.removeFromSuperview()
        }
        if self.facebookPlayerView.isDescendant(of: self.containerView) {
            self.facebookPlayerView.removeFromSuperview()
        }
    }
    
    private  func customizeDropDownFunc() {
        dropDown.dataSource = [NSLocalizedString("Help and Report Center", comment: "Help and Report Center"),NSLocalizedString("Add to Playlist", comment: "Add to Playlist"),NSLocalizedString("Not interested", comment: "Not interested"),NSLocalizedString("Share", comment: "Share"),NSLocalizedString("Report", comment: "Report")]
        dropDown.anchorView = self.videoPlayerView.settingButton
        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            if index == 0 {
            } else if index == 1 {
                log.verbose("Selected item: \(item) at index: \(index)")
            }
            self.dropDown.width = 200
            self.dropDown.direction = .any
        }
    }
    
    func initializePlayer(for url: URL) {
        self.containerView.addSubview(self.videoPlayerView)
        self.setConstraintToSubView(view: self.videoPlayerView)
        self.videoPlayerView.parentView = self
        self.videoPlayerView.initializePlayer(for: url)
        self.thumbnailImageView.image = nil
    }
    
    func initializeAdPlayer(for url: URL, video_ad: Video_ad) {
        self.containerView.addSubview(self.adPlayerView)
        self.setConstraintToSubView(view: self.adPlayerView)
        self.adPlayerView.initializePlayer(for: url, video_ad: video_ad)
    }
    
    func initializeFlowPlayer(for url: URL, video_id: VideoDetail) {
        self.containerView.addSubview(self.flowPlayerView)
        self.setFlowPlayerConstraintToSubView(view: self.flowPlayerView)
        self.flowPlayerView.parentView = self
        self.flowPlayerView.initializeFlowPlayer(for: url,video_id: video_id)
        self.thumbnailImageView.image = nil
        self.activityIndicator.stopAnimating()
    }
    
    func setupDailyMotionPlayer(videoId: String, controller: TabbarController) {
        let playerParams = DMPlayerParameters(mute: false)
        Dailymotion.createPlayer(playerId: "xfh51", videoId: videoId, playerParameters: playerParams, playerDelegate: self) { playerView, error in
            if let error = error {
                print(error.localizedDescription)
            } else {
                self.activityIndicator.stopAnimating()
                if let playerView = playerView {
                    self.dmPlayerView = playerView
                    self.containerView.addSubview(self.dmPlayerView)
                    self.setConstraintToSubView(view: self.dmPlayerView)
                    self.thumbnailImageView.image = nil
                }
            }
        }
    }
    
    func initializeTwitchPlayer(for twitch: String) {
        self.containerView.addSubview(self.twitchPlayerView)
        self.setConstraintToSubView(view: self.twitchPlayerView)
        self.twitchPlayerView.parentView = self
        self.twitchPlayerView.initializeTwitchPlayer(for: twitch)
    }
    
    func initializeTwitchClipPlayer(for twitch: String) {
        self.containerView.addSubview(self.twitchClipPlayerView)
        self.setConstraintToSubView(view: self.twitchClipPlayerView)
        self.twitchClipPlayerView.parentView = self
        self.twitchClipPlayerView.initializeTwitchClipPlayer(for: twitch)
    }
    
    func initializeFaceBookPlayer(for facebook: String) {
        self.containerView.addSubview(self.facebookPlayerView)
        self.setConstraintToSubView(view: self.facebookPlayerView)
        self.facebookPlayerView.parentView = self
        self.facebookPlayerView.initializeFaceBookPlayer(for: facebook)
    }
    
    func initializePaidVideoView(for content: VideoDetail) {
        self.paidVideoView.setupPaidVideoView(for: content)
        self.containerView.addSubview(self.paidVideoView)
        self.setConstraintToSubView(view: self.paidVideoView)
        self.activityIndicator.stopAnimating()
    }
    
    func initializeVideoPlayerErrorView(errorImage: UIImage?, description: String) {
        self.videoPlayerErrorView.setupsVideoPlayerErrorView(errorImage: errorImage, description: description)
        self.containerView.addSubview(self.videoPlayerErrorView)
        self.setConstraintToSubView(view: self.videoPlayerErrorView)
        self.activityIndicator.stopAnimating()
    }
    
    func setConstraintToSubView(view: UIView) {
        let constraints = [
            view.topAnchor.constraint(equalTo: self.containerView.topAnchor, constant: 0),
            view.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor, constant: 0),
            view.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 0),
            view.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: 0)
        ]
        NSLayoutConstraint.activate(constraints)
        view.setNeedsDisplay()
        view.layoutIfNeeded()
    }
    
    func setFlowPlayerConstraintToSubView(view: UIView) {
        let constraints = [
            view.topAnchor.constraint(equalTo: self.containerView.topAnchor, constant: 0),
            view.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor, constant: 0),
            view.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 0),
            view.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: 0)
        ]
        NSLayoutConstraint.activate(constraints)
        view.setNeedsDisplay()
        view.layoutIfNeeded()
    }
    
}

// MARK: - Extensions

// MARK: Api Call
extension VideoPlayerContainerView {
    
    func fetchVideoDetails(object: VideoDetail) {
        self.videoPlayerView.isEnableForwardButton(false)
        self.isCompleted = false
        self.isLoading = true
        self.tableView.reloadData()
        if Connectivity.isConnectedToNetwork() {
            let userID = AppInstance.instance.userId ?? 0
            let sessionID = AppInstance.instance.sessionId ?? ""
            let videoID = object.video_id ?? ""
            Async.background {
                PlayVideoManager.instance.getVideosDetailsByVideoId(User_id: userID, Session_Token: sessionID, VideoId: videoID, completionBlock: { (success, sessionError, error) in
                    if success != nil {
                        Async.main {
                            self.videoDataObject = success?.data
                            if let data = success?.data?.suggested_videos {
                                self.suggestedVideosArray = AppInstance.instance.getNotInterestedData(data: data)
                            }
                            self.EmptyVideo = self.suggestedVideosArray.isEmpty ? 1 : 0
                            let _ = AppInstance.instance.getUserSession()
                            self.isCompleted = true
                            self.isLoading = false
                            self.tableView.reloadData()
                            self.videoPlayerView.isEnableForwardButton(!self.suggestedVideosArray.isEmpty)
                            if self.videoDataObject?.source == "Uploaded" && self.videoDataObject?.video_type == "video/mp4" && self.videoDataObject?.is_short == 0 {
                                switch self.videoDataObject?.video_ad {
                                case .anythingArray(let value):
                                    print("Ad Array Count >>>>>", value.count)
                                case .videoAdClass(let value):
                                    self.delegate?.handleLoadVideoAd(video_ad: value)                                    
                                default:
                                    break
                                }
                            }
                        }
                    } else if sessionError != nil {
                        Async.main {
                            log.debug("sessionError = \(sessionError?.errors!.error_text ?? "")")
                            self.makeToast(sessionError?.errors!.error_text ?? "")
                        }
                    } else {
                        Async.main {
                            log.debug("error = \(error?.localizedDescription ?? "")")
                            self.makeToast(error?.localizedDescription)
                        }
                    }
                })
            }
        } else {
            self.makeToast(InterNetError)
        }
    }
    
}

extension VideoPlayerContainerView: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            if EmptyVideo == 1 {
                return 1
            } else {
                if isLoading {
                    return 10
                } else {
                    return self.suggestedVideosArray.count
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if isLoading {
                let cell = tableView.dequeueReusableCell(withIdentifier: "videoDetailCell") as! VideoDetailCell
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "videoDetailCell") as! VideoDetailCell
                cell.tabBarController = self.tabBarController
                cell.delegate = self
                cell.isShowDescription = self.isShowDescription
                if let videoData = self.videoDataObject {
                    cell.bind(object: videoData)
                }
                return cell
            }
        } else {
            if self.EmptyVideo == 1 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "EmptyCell") as! EmptyVideoCell
                cell.selectionStyle = .none
                return cell
            } else {
                if isLoading {
                    let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.playerNextTableItem.identifier) as! PlayerNextTableItem
                    return cell
                } else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.playerNextTableItem.identifier) as! PlayerNextTableItem
                    let object = self.suggestedVideosArray[indexPath.row]
                    cell.bind(object)
                    return cell
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath.section == 0) {
            return UITableView.automaticDimension
        } else {
            if self.EmptyVideo == 1 {
                return 300
            } else {
                return 120
            }
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 1 {
            let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "DemoHeaderView") as! PlayerSectionHeader
            headerView.autoPlaySwitch.isOn = UserDefaults.standard.getAutoPlay()
            return headerView
        } else {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.setTemplateWithSubviews(isLoading, animate: true, viewBackgroundColor: .systemBackground)
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == 1 {
            let footerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "DemoFooterView") as! PlayerSectionFooter
            footerView.commentsLbl.text = NSLocalizedString("Comments", comment: "Comments")
            footerView.tabBarController = self.tabBarController
            footerView.VideoId = videoDataObject?.id ?? 0
            return footerView
        } else {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 1 {
            if self.suggestedVideosArray.count == 0 {
                return 0.0
            } else {
                return 45
            }
        } else {
            return 0.0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 1 {
            if self.suggestedVideosArray.count == 0 {
                if isCompleted {
                    return 50
                } else {
                    return 0.0
                }
            } else {
                if isCompleted {
                    return 50
                } else {
                    return 0.0
                }
            }
        } else {
            return 0.0
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath.section == 1) {
            if (self.suggestedVideosArray.isEmpty == true) || (self.suggestedVideosArray.count == 0) {
                print("Nothing")
            } else {
                AppInstance.instance.addCount = AppInstance.instance.addCount! + 1
                let videoObject = self.suggestedVideosArray[indexPath.row]
                self.tabBarController.handleOpenVideoPlayer(for: videoObject)
            }
        }
    }
    
}

// MARK: VideoDetailCellDelegate Methods
extension VideoPlayerContainerView: VideoDetailCellDelegate {
    
    func showDescriptionButtonTapped() {
        self.isShowDescription = !self.isShowDescription
        self.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
    }
    
}

// MARK: DMPlayerDelegate
extension VideoPlayerContainerView: DMPlayerDelegate {
    
    func player(_ player: DailymotionPlayerSDK.DMPlayerView, openUrl url: URL) {
        
    }
    
    func playerWillPresentFullscreenViewController(_ player: DailymotionPlayerSDK.DMPlayerView) -> UIViewController {
        return self.tabBarController
    }
    
    func playerWillPresentAdInParentViewController(_ player: DailymotionPlayerSDK.DMPlayerView) -> UIViewController {
        return self.tabBarController
    }
    
}
