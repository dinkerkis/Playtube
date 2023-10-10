//
//  VideoDetailCell.swift
//  Playtube
//
//  Created by Ubaid Javaid on 5/23/20.
//  Copyright © 2020 Muhammad Haris Butt. All rights reserved.
//

import UIKit
import SDWebImage
import Async
import ActiveLabel
import PlaytubeSDK
import UIView_Shimmer
import Toast_Swift

protocol VideoDetailCellDelegate {
    func showDescriptionButtonTapped()
}

class VideoDetailCell: UITableViewCell, ShimmeringViewProtocol {
    
    // MARK: - IBOutelets
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var viewsLabel: UILabel!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var updownBtn: UIButton!
    @IBOutlet weak var likeBtn: UIButton!
    @IBOutlet weak var disLikeBtn: UIButton!
    @IBOutlet weak var shareBtn: UIButton!
    @IBOutlet weak var AddBtn: UIButton!
    @IBOutlet weak var SubscribeBtn: UIButton!
    @IBOutlet weak var publishedDate: UILabel!
    @IBOutlet weak var descriptionLabel: ActiveLabel!
    @IBOutlet weak var CategoryLabel: UILabel!
    @IBOutlet weak var likeCountLabel: UILabel!
    @IBOutlet weak var donateLabel: UILabel!
    @IBOutlet weak var disLikeCountLabel: UILabel!
    @IBOutlet weak var shareLabel: UILabel!
    @IBOutlet weak var subscriberCount: UILabel!
    @IBOutlet weak var addLabel: UILabel!
    @IBOutlet weak var categoryLbl: UILabel!
    @IBOutlet weak var btnDonate: UIButton!
    @IBOutlet weak var detailView: UIView!
    
    // MARK: - Properties
    
    var owner_id: Int? = nil
    var videoLoaction: String? =  nil
    var videoId: Int? = nil
    private var likeCount: Int? = 0
    private var dislikeCount: Int? = 0
    var tabBarController: TabbarController!
    var object: VideoDetail?
    var isShowDescription: Bool = false
    var shimmeringAnimatedItems: [UIView] {
        [
            titleLabel,
            viewsLabel,
            likeCountLabel,
            disLikeCountLabel,
            donateLabel,
            shareLabel,
            addLabel,
            profileImage,
            userName,
            subscriberCount,
            SubscribeBtn,
            publishedDate,
            descriptionLabel,
            categoryLbl,
            CategoryLabel            
        ]
    }
    var delegate: VideoDetailCellDelegate?
    
    // MARK: - View Life Cycles
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    // MARK: - Selectors
    
    // Like Button Action
    @IBAction func likeButtonAction(_ sender: UIButton) {
        if AppInstance.instance.getUserSession() {
            self.like()
        } else {
            let newVC = R.storyboard.popups.loginPopupVC()
            self.tabBarController?.present(newVC!, animated: true)
        }
    }
    
    // Dis Like Button Action
    @IBAction func disLikeButtonAction(_ sender: UIButton) {
        if AppInstance.instance.getUserSession() {
            self.disLike()
        } else {
            let newVC = R.storyboard.popups.loginPopupVC()
            self.tabBarController?.present(newVC!, animated: true, completion: nil)
        }
    }
    
    // Share Button Action
    @IBAction func shareButtonAction(_ sender: UIButton) {
        self.shareVideoLink()
    }
    
    // Add To Button Action
    @IBAction func addToButtonAction(_ sender: UIButton) {
        let popupVC = R.storyboard.popups.addToPopupVC()
        popupVC?.delegate = self
        self.tabBarController?.present(popupVC!, animated: true)
    }
    
    // Donate Button Action
    @IBAction func donateButtonAction(_ sender: UIButton) {
        
    }
    
    // Subscribe Button Action
    @IBAction func subscribeButtonAction(_ sender: UIButton) {
        if AppInstance.instance.getUserSession() {
            self.subscribeChannel()
        } else {
            let warningPopupVC = R.storyboard.popups.warningPopupVC()
            warningPopupVC?.delegate = self
            warningPopupVC?.okText = "YES"
            warningPopupVC?.cancelText = "NO"
            warningPopupVC?.titleText  = "Warning"
            warningPopupVC?.messageText = "Please sign in to subscribe to the channel"
            self.tabBarController?.present(warningPopupVC!, animated: true, completion: nil)
        }
    }
    
    // Up Down Button Action
    @IBAction func upDownButtonAction(_ sender: UIButton) {
        self.delegate?.showDescriptionButtonTapped()        
    }
    
    // MARK: - Helper Functions
    
    func bind(object: VideoDetail) {
        self.object = object
        self.owner_id = object.owner?.id ?? 0
        self.videoLoaction = object.video_location ?? ""
        self.videoId = object.id ?? 0
        let url = URL(string: object.owner?.avatar ?? "")
        self.profileImage.sd_setShowActivityIndicatorView(true)
        self.profileImage.sd_setIndicatorStyle(.medium)
        DispatchQueue.global(qos: .userInteractive).async {
            self.profileImage.sd_setImage(with: url , placeholderImage:R.image.maxresdefault())
        }
        self.titleLabel.text = object.title?.htmlAttributedString ?? ""
        if object.owner?.username == "" || object.owner?.username == nil {
            self.userName.text = "\(object.owner?.first_name ?? "") \(object.owner?.last_name ?? "")"
        } else {
            self.userName.text = object.owner?.username ?? ""
        }
        self.viewsLabel.text = "\(object.category_name?.htmlAttributedString ?? "") | \(object.views ?? 0) Views | \(object.time_ago ?? "")"
        self.publishedDate.text = "\("Published on ")\(object.time_date ?? "")"
        self.descriptionLabel.attributedText = object.description?.removeContinuousBRTags().stringByDecodingURL.convertHtmlToAttributedStringWithCSS(font: UIFont(name: "TTCommons-Regular", size: 16), csscolor: "#737884", lineheight: 20)
        self.likeCountLabel.text =  "\(object.likes ?? 0)"
        self.disLikeCountLabel.text = "\(object.dislikes ?? 0)"
        self.likeCount = object.likes ?? 0
        self.dislikeCount = object.dislikes ?? 0
        self.categoryLbl.text = NSLocalizedString("Category", comment: "Category")
        self.CategoryLabel.text = object.category_name ?? ""
        switch object.owner?.subscribe_count {
        case .integer(let value):
            self.subscriberCount.text = "\(value) Subscribers"
        case .string(let value):
            self.subscriberCount.text = "\(value) Subscribers"
        default:
            break
        }
        if AppInstance.instance.getUserSession() {
            self.descriptionLabel.handleURLTap { (url) in
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
            if object.is_subscribed == 0 {
                self.SubscribeBtn.setTitle("Subscribe", for: .normal)
            } else {
                self.SubscribeBtn.setTitle("Subscribed", for: .normal)
            }
            if object.likes == 0 && object.dislikes == 0 {
                self.likeBtn.setImage(UIImage(named: "like_gray"), for: .normal)
                self.disLikeBtn.setImage(UIImage(named: "dislike_gray"), for: .normal)
            } else {
                if object.is_liked == 1 {
                    self.likeBtn.setImage(UIImage(named: "like_blue-1"), for: .normal)
                    self.disLikeBtn.setImage(UIImage(named: "dislike_gray"), for: .normal)
                } else if (object.is_disliked == 1) {
                    self.likeBtn.setImage(UIImage(named: "like_gray"), for: .normal)
                    self.disLikeBtn.setImage(UIImage(named: "dislike_blue-1"), for: .normal)
                } else {
                    self.likeBtn.setImage(UIImage(named: "like_gray"), for: .normal)
                    self.disLikeBtn.setImage(UIImage(named: "dislike_gray"), for: .normal)
                }
            }
        }
        if self.isShowDescription {
            self.detailView.isHidden = true
            self.titleLabel.numberOfLines = 1
            self.descriptionLabel.numberOfLines = 1
            self.updownBtn.setImage(UIImage(named: "down_new"), for: .normal)
        } else {
            self.detailView.isHidden = false
            self.titleLabel.numberOfLines = 0
            self.descriptionLabel.numberOfLines = 0
            self.updownBtn.setImage(UIImage(named: "up_new"), for: .normal)
        }
    }
    
    func subscribeChannel() {
        if Connectivity.isConnectedToNetwork() {
            let userID = AppInstance.instance.userId ?? 0
            let sessionID = AppInstance.instance.sessionId ?? ""
            let channelID = self.owner_id ?? 0
            // self.videoDataObject?.owner?.id ?? 0
            Async.background {
                PlayVideoManager.instance.subUnsubChannel(User_id: userID, Session_Token: sessionID, Channel_Id: channelID) { (success, sessionError, error) in
                    if success != nil {
                        Async.main {
                            if success?.code == 0 {
                                self.tabBarController?.view.makeToast("Unsubscribed Successfully")
                                self.SubscribeBtn.setTitle("Subscribe", for: .normal)
                            } else {
                                self.tabBarController?.view.makeToast(NSLocalizedString("Subscribed Successfully", comment: "Subscribed Successfully"))
                                self.SubscribeBtn.setTitle("Subscribed", for: .normal)
                            }
                        }
                    } else if sessionError != nil {
                        log.verbose("sessionError = \(sessionError?.errors!.error_text ?? "")")
                        self.tabBarController?.view.makeToast(sessionError?.errors!.error_text ?? "")
                    } else {
                        log.verbose("error = \(error?.localizedDescription ?? "")")
                        self.tabBarController?.view.makeToast(error?.localizedDescription ?? "")
                    }
                }
            }
        } else {
            self.tabBarController?.view.makeToast("InterNetError")
        }
    }
    
    func disLike() {
        if Connectivity.isConnectedToNetwork() {
            let userID = AppInstance.instance.userId ?? 0
            let sessionID = AppInstance.instance.sessionId ?? ""
            let channelID = self.videoId ?? 0
            Async.background {
                PlayVideoManager.instance.likeDislikeVideos(User_id: userID, Session_Token: sessionID, Video_Id: channelID, Like_Type: "dislike", completionBlock: { (success, sessionError, error) in
                    if success?.success_type == "added_dislike"{
                        self.disLikeBtn.setImage(UIImage(named: "dislike_blue-1"), for: .normal)
                        self.tabBarController?.view.makeToast(NSLocalizedString("Disliked", comment: "Disliked"))
                        self.dislikeCount = self.dislikeCount! + 1
                        self.disLikeCountLabel.text = "\(self.dislikeCount ?? 0)"
                        if self.likeBtn.imageView!.image == R.image.like_blue() {
                            self.likeBtn.setImage(R.image.likees(), for: .normal)
                            self.likeCount = self.likeCount! - 1
                            self.likeCountLabel.text = "\(self.likeCount ?? 0)"
                        }
                    } else {
                        self.disLikeBtn.setImage(UIImage(named: "dislike_gray"), for: .normal)
                        log.verbose("success = \(success?.success_type ?? "")")
                        self.dislikeCount = self.dislikeCount! - 1
                        self.disLikeCountLabel.text = "\(self.dislikeCount ?? 0)"
                    }
                })
            }
        } else {
            self.tabBarController!.view.makeToast("InterNetError")
        }
    }
    
    func like() {
        if Connectivity.isConnectedToNetwork() {
            let userID = AppInstance.instance.userId ?? 0
            let sessionID = AppInstance.instance.sessionId ?? ""
            let channelID = self.videoId ?? 0
            Async.background {
                PlayVideoManager.instance.likeDislikeVideos(User_id: userID, Session_Token: sessionID, Video_Id: channelID, Like_Type: "like", completionBlock: { (success, sessionError, error) in
                    if success?.success_type == "added_like"{
                        self.likeBtn.setImage(UIImage(named: "like_blue-1"), for: .normal)
                        log.verbose("success = \(success?.success_type ?? "")")
                        self.tabBarController?.view.makeToast(NSLocalizedString("Liked", comment: "Liked"))
                        // self.likeBtn.setImage(R.image.likees(), for: .normal)
                        self.likeCount = self.likeCount! + 1
                        self.likeCountLabel.text = "\(self.likeCount ?? 0)"
                        if self.disLikeBtn.imageView!.image == R.image.dislike_blue() {
                            self.disLikeBtn.setImage(R.image.dislikees(), for: .normal)
                            self.dislikeCount = self.dislikeCount! - 1
                            self.disLikeCountLabel.text = "\(self.dislikeCount ?? 0)"
                        }
                    } else {
                        self.likeBtn.setImage(UIImage(named: "like_gray"), for: .normal)
                        log.verbose("success = \(success?.success_type ?? "")")
                        self.likeCount = self.likeCount! - 1
                        self.likeCountLabel.text = "\(self.likeCount ?? 0)"
                    }
                })
            }
        } else {
            self.tabBarController?.view.makeToast("InterNetError")
        }
    }
    
    func getPlaylist() {
        if Connectivity.isConnectedToNetwork() {
            self.tabBarController?.showProgressDialog(text: NSLocalizedString("Loading...", comment: "Loading..."))
            let userID = AppInstance.instance.userId ?? 0
            let sessionID = AppInstance.instance.sessionId ?? ""
            Async.background {
                PlaylistManager.instance.getPlaylist(User_id: userID, Session_Token: sessionID, completionBlock: { (success, sessionError, error) in
                    if success != nil {
                        Async.main {
                            self.tabBarController?.dismissProgressDialog {
                                let newVC = R.storyboard.popups.playlistsPopupVC()
                                newVC?.videoID = self.videoId ?? 0
                                newVC?.playlistArray = success?.myAllPlaylists ?? []
                                newVC?.delegate = self.tabBarController!
                                self.tabBarController!.present(newVC!, animated: true, completion: nil)
                            }
                        }
                    } else if sessionError != nil {
                        self.tabBarController?.dismissProgressDialog {
                            log.verbose("sessionError = \(sessionError?.errors?.error_text ?? "")")
                            self.tabBarController?.view.makeToast(sessionError?.errors?.error_text ?? "")
                        }
                    } else {
                        self.tabBarController?.dismissProgressDialog {
                            log.verbose("Error = \(error?.localizedDescription ?? "")")
                            self.tabBarController?.view.makeToast(error?.localizedDescription ?? "")
                        }
                    }
                })
            }
        } else {
            self.tabBarController?.dismissProgressDialog {
                self.tabBarController?.view.makeToast("InterNetError")
            }
        }
    }
    
    func shareVideoLink() {
        // text to share
        let url = self.object?.url ?? ""
        print(url)
        // set up activity view controller
        let textToShare = [ url ]
        let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self
        // exclude some activity types from the list (optional,)
        activityViewController.excludedActivityTypes = [
            UIActivity.ActivityType.airDrop,
            UIActivity.ActivityType.postToFacebook,
            UIActivity.ActivityType.assignToContact,
            UIActivity.ActivityType.mail,
            UIActivity.ActivityType.postToTwitter,
            UIActivity.ActivityType.message,
            UIActivity.ActivityType.postToFlickr,
            UIActivity.ActivityType.postToVimeo,
            UIActivity.ActivityType.postToTencentWeibo,
            UIActivity.ActivityType.init(rawValue: "net.whatsapp.WhatsApp.ShareExtension"),
            UIActivity.ActivityType.init(rawValue: "com.google.Gmail.ShareExtension"),
            UIActivity.ActivityType.init(rawValue: "com.toyopagroup.picaboo.share"),
            UIActivity.ActivityType.init(rawValue: "com.tinyspeck.chatlyio.share")
        ]
        activityViewController.completionWithItemsHandler = { activity, completed, items, error in
            if !completed {
                return
            } else {
                if self.object != nil {
                    log.verbose("Check = \(UserDefaults.standard.getSharedVideos(Key: Local.SHARED_VIDEOS.shared_videos))")
                    let objectToEncode = self.object
                    let data = try? PropertyListEncoder().encode(objectToEncode)
                    var getSharedVideosData = UserDefaults.standard.getSharedVideos(Key: Local.SHARED_VIDEOS.shared_videos)
                    if UserDefaults.standard.getSharedVideos(Key: Local.SHARED_VIDEOS.shared_videos).contains(data!) {
                        self.tabBarController?.view.makeToast(NSLocalizedString("Already added in shared videos", comment: "Already added in shared videos"))
                    } else {
                        getSharedVideosData.append(data!)
                        UserDefaults.standard.setSharedVideos(value: getSharedVideosData, ForKey: Local.SHARED_VIDEOS.shared_videos)
                        self.tabBarController?.view.makeToast(NSLocalizedString("Added to shared videos", comment: "Added to shared videos"))
                    }
                }
            }
        }
        // present the view controller
        self.tabBarController?.present(activityViewController, animated: true, completion: nil)
    }
    
}

// MARK: WarningPopupVCDelegate Methods
extension VideoDetailCell: WarningPopupVCDelegate {
    
    func warningPopupOKButtonPressed(_ sender: UIButton) {
        let vc = R.storyboard.auth.loginVC()
        self.tabBarController?.navigationController?.pushViewController(vc!, animated: true)
    }
    
}

// MARK: AddToPopupVCDelegate Methods
extension VideoDetailCell: AddToPopupVCDelegate {
    
    func handleSaveToPlaylistTap(_ sender: UIButton) {
        if AppInstance.instance.getUserSession() {
         self.getPlaylist()
         } else {
         let newVC = R.storyboard.popups.loginPopupVC()
         self.tabBarController?.present(newVC!, animated: true, completion: nil)
         }
    }
    
    func handleSaveToWatchLaterTap(_ sender: UIButton) {
        if AppInstance.instance.getUserSession() {
            self.setWatchLater()
        } else {
            let warningPopupVC = R.storyboard.popups.warningPopupVC()
            warningPopupVC?.delegate = self
            warningPopupVC?.okText = "YES"
            warningPopupVC?.cancelText = "NO"
            warningPopupVC?.titleText  = "Warning"
            warningPopupVC?.messageText = "Please sign in to add to WatchLater videos"
            self.tabBarController?.present(warningPopupVC!, animated: true, completion: nil)
        }
    }
    
    func setWatchLater() {
        if object != nil {
            log.verbose("Check = \(UserDefaults.standard.getWatchLater(Key: Local.WATCH_LATER.watch_Later))")
            let objectToEncode = object
            let data = try? PropertyListEncoder().encode(objectToEncode)
            var getWatchLaterData = UserDefaults.standard.getWatchLater(Key: Local.WATCH_LATER.watch_Later)
            if UserDefaults.standard.getWatchLater(Key: Local.WATCH_LATER.watch_Later).contains(data!) {
                self.tabBarController?.view.makeToast(NSLocalizedString("Already added in watch later", comment: "Already added in watch later"))
            } else {
                getWatchLaterData.append(data!)
                UserDefaults.standard.setWatchLater(value: getWatchLaterData, ForKey: Local.WATCH_LATER.watch_Later)
                self.tabBarController?.view.makeToast(NSLocalizedString("Added to watch later", comment: "Added to watch later"))
            }
        }
    }
    
}
