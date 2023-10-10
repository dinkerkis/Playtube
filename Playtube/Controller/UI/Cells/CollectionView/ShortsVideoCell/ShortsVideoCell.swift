//
//  ShortsVideoCell.swift
//  Playtube
//
//  Created by iMac on 11/05/23.
//  Copyright © 2023 ScriptSun. All rights reserved.
//

import UIKit
import SDWebImage
import PlaytubeSDK
import Async
import Toast_Swift
import AVKit

class ShortsVideoCell: UICollectionViewCell {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var likeCountLabel: UILabel!
    @IBOutlet weak var disLikeButton: UIButton!
    @IBOutlet weak var disLikeCountLabel: UILabel!
    @IBOutlet weak var lblViewsCount: UILabel!
    @IBOutlet weak var lblCommentCount: UILabel!
    @IBOutlet weak var subscribeButton: UIButton!
    
    // MARK: - Properties
    
    var object: VideoDetail?
    private var likeCount: Int? = 0
    private var dislikeCount: Int? = 0
        
    // MARK: - Selectors
    
    // Like Button Action
    @IBAction func likeButtonAction(_ sender: UIButton) {
        self.like()
    }
    
    // DisLike Button Action
    @IBAction func disLikeButtonAction(_ sender: UIButton) {
        self.disLike()
    }
    
    // Comment Button Action
    @IBAction func commentButtonAction(_ sender: UIButton) {
        
    }
    
    @IBAction func userProfileAction(_ sender: UIButton) {
        let newVC = R.storyboard.loggedUser.newProfileVC()
        newVC?.channalData = self.object?.owner
        (obj_appDelegate.window?.rootViewController as? UINavigationController)?.pushViewController(newVC!, animated: true)
    }
    
    // Video Option Button Action
    @IBAction func videoOptionButtonAction(_ sender: UIButton) {
        let newVC = R.storyboard.popups.videoOptionPopupVC()
        newVC?.modalPresentationStyle = .custom
        newVC?.transitioningDelegate = self
        newVC?.object = self.object
        obj_appDelegate.window?.rootViewController?.present(newVC!, animated: true)
    }
    
    // Subscribe Button Action
    @IBAction func subscribeButtonAction(_ sender: UIButton) {
        self.subscribeChannel()
    }
    
    // MARK: - Helper Functions
    
    // Set Data
    func setData(data: VideoDetail) {
        let url = URL(string: data.owner?.avatar ?? "")
        self.profileImage.sd_setShowActivityIndicatorView(true)
        self.profileImage.sd_setIndicatorStyle(.medium)
        self.profileImage.sd_setImage(with: url, placeholderImage:R.image.maxresdefault())
        self.usernameLabel.text = data.owner?.name
        self.titleLabel.text = data.title
        self.lblViewsCount.text = "\(data.views ?? 0)"
        self.likeCount = data.likes ?? 0
        self.likeCountLabel.text = "\(data.likes ?? 0)"
        self.dislikeCount = data.dislikes ?? 0
        self.disLikeCountLabel.text = "\(data.dislikes ?? 0)"
        if data.is_liked == 1 {
            self.likeButton.setImage(UIImage(named: "like_blue-1"), for: .normal)
            self.disLikeButton.setImage(R.image.outline_thumbs_down_white(), for: .normal)
        } else if (data.is_disliked == 1) {
            self.likeButton.setImage(R.image.outline_thumbs_up_white(), for: .normal)
            self.disLikeButton.setImage(UIImage(named: "dislike_blue-1"), for: .normal)
        } else {
            self.likeButton.setImage(R.image.outline_thumbs_up_white(), for: .normal)
            self.disLikeButton.setImage(R.image.outline_thumbs_down_white(), for: .normal)
        }
        if data.owner?.am_i_subscribed == 0 {
            self.subscribeButton.setTitle("Subscribe", for: .normal)
        } else {
            self.subscribeButton.setTitle("Subscribed", for: .normal)
        }
        self.lblCommentCount.text = "\(data.comments_count ?? 0)"
        self.layoutIfNeeded()
    }
    
}

// MARK: - Extensions

// MARK: Api Call
extension ShortsVideoCell {
    
    func fetchVideoDetails(object: VideoDetail) {
        if Connectivity.isConnectedToNetwork() {
            let userID = AppInstance.instance.userId ?? 0
            let sessionID = AppInstance.instance.sessionId ?? ""
            let videoID = object.video_id ?? ""
            Async.background {
                PlayVideoManager.instance.getVideosDetailsByVideoId(User_id: userID, Session_Token: sessionID, VideoId: videoID, completionBlock: { (success, sessionError, error) in
                    if success != nil {
                        Async.main {
                            self.object = success?.data
                            if let object = self.object {
                                self.setData(data: object)
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
    
    func like() {
        if Connectivity.isConnectedToNetwork() {
            let userID = AppInstance.instance.userId ?? 0
            let sessionID = AppInstance.instance.sessionId ?? ""
            let channelID = self.object?.id ?? 0
            Async.background {
                PlayVideoManager.instance.likeDislikeVideos(User_id: userID, Session_Token: sessionID, Video_Id: channelID, Like_Type: "like", completionBlock: { (success, sessionError, error) in
                    if success?.success_type == "added_like" {
                        self.likeButton.setImage(UIImage(named: "like_blue-1"), for: .normal)
                        log.verbose("success = \(success?.success_type)")
                        obj_appDelegate.window?.rootViewController?.view.makeToast(NSLocalizedString("Liked", comment: "Liked"))
                        // self.likeBtn.setImage(R.image.likees(), for: .normal)
                        self.likeCount = self.likeCount! + 1
                        self.likeCountLabel.text = "\(self.likeCount ?? 0)"
                        if self.disLikeButton.imageView!.image == R.image.dislike_blue1() {
                            self.disLikeButton.setImage(R.image.outline_thumbs_down_white(), for: .normal)
                            self.dislikeCount = self.dislikeCount! - 1
                            self.disLikeCountLabel.text = "\(self.dislikeCount ?? 0)"
                        }
                    } else {
                        self.likeButton.setImage(R.image.outline_thumbs_up_white(), for: .normal)
                        log.verbose("success = \(success?.success_type)")
                        self.likeCount = self.likeCount! - 1
                        self.likeCountLabel.text = "\(self.likeCount ?? 0)"
                    }
                })
            }
        } else {
            obj_appDelegate.window?.rootViewController?.view.makeToast("InterNetError")
        }
    }
    
    func disLike() {
        if Connectivity.isConnectedToNetwork() {
            let userID = AppInstance.instance.userId ?? 0
            let sessionID = AppInstance.instance.sessionId ?? ""
            let channelID = self.object?.id ?? 0
            Async.background {
                PlayVideoManager.instance.likeDislikeVideos(User_id: userID, Session_Token: sessionID, Video_Id: channelID, Like_Type: "dislike", completionBlock: { (success, sessionError, error) in
                    if success?.success_type == "added_dislike"{
                        self.disLikeButton.setImage(UIImage(named: "dislike_blue-1"), for: .normal)
                        obj_appDelegate.window?.rootViewController?.view.makeToast(NSLocalizedString("Disliked", comment: "Disliked"))
                        self.dislikeCount = self.dislikeCount! + 1
                        self.disLikeCountLabel.text = "\(self.dislikeCount ?? 0)"
                        if self.likeButton.imageView!.image == R.image.like_blue1() {
                            self.likeButton.setImage(R.image.outline_thumbs_up_white(), for: .normal)
                            self.likeCount = self.likeCount! - 1
                            self.likeCountLabel.text = "\(self.likeCount ?? 0)"
                        }
                    } else {
                        self.disLikeButton.setImage(R.image.outline_thumbs_down_white(), for: .normal)
                        log.verbose("success = \(success?.success_type)")
                        self.dislikeCount = self.dislikeCount! - 1
                        self.disLikeCountLabel.text = "\(self.dislikeCount ?? 0)"
                    }
                })
            }
        } else {
            obj_appDelegate.window?.rootViewController?.view.makeToast("InterNetError")
        }
    }
    
    func subscribeChannel() {
        if Connectivity.isConnectedToNetwork() {
            let userID = AppInstance.instance.userId ?? 0
            let sessionID = AppInstance.instance.sessionId ?? ""
            let channelID = self.object?.owner?.id ?? 0
            // self.videoDataObject?.owner?.id ?? 0
            Async.background {
                PlayVideoManager.instance.subUnsubChannel(User_id: userID, Session_Token: sessionID, Channel_Id: channelID) { (success, sessionError, error) in
                    if success != nil {
                        Async.main {
                            if success?.code == 0 {
                                obj_appDelegate.window?.rootViewController?.view.makeToast("Unsubscribed Successfully")
//                                self.subscribeButton.setTitle("Subscribe", for: .normal)
                            } else {
                                obj_appDelegate.window?.rootViewController?.view.makeToast(NSLocalizedString("Subscribed Successfully", comment: "Subscribed Successfully"))
//                                self.subscribeButton.setTitle("Subscribed", for: .normal)
                            }
                            NotificationCenter.default.post(name: NSNotification.Name("reloadShortData"), object: nil)
                        }
                    } else if sessionError != nil {
                        log.verbose("sessionError = \(sessionError?.errors!.error_text ?? "")")
                        obj_appDelegate.window?.rootViewController?.view.makeToast(sessionError?.errors!.error_text ?? "")
                    } else {
                        log.verbose("error = \(error?.localizedDescription ?? "")")
                        obj_appDelegate.window?.rootViewController?.view.makeToast(error?.localizedDescription ?? "")
                    }
                }
            }
        } else {
            obj_appDelegate.window?.rootViewController?.view.makeToast("InterNetError")
        }
    }
    
}

// MARK: UIViewControllerTransitioningDelegate Methods
extension ShortsVideoCell: UIViewControllerTransitioningDelegate {
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        BottomSheetPresentationController(presentedViewController: presented, presenting: presenting)
    }
    
}
