//
//  ReplyCommentCell.swift
//  Playtube
//
//  Created by iMac on 31/05/23.
//  Copyright © 2023 ScriptSun. All rights reserved.
//

import UIKit
import Async
import Toast_Swift
import PlaytubeSDK

class ReplyCommentCell: UITableViewCell {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var lblUsername: UILabel!
    @IBOutlet weak var commentTextLabel: UILabel!
    @IBOutlet weak var likeCountLabel: UILabel!
    @IBOutlet weak var dislikeButton: UIButton!
    @IBOutlet weak var likeButton: UIButton!
    
    // MARK: - Properties
    
    var shimmeringAnimatedItems: [UIView] {
        [
            profileImage,
            lblUsername,
            commentTextLabel,
            likeButton,
            likeCountLabel,
            dislikeButton,
        ]
    }
    var replyCommentData: ReplyComment?
    var likeCount: Int? = 0

    // MARK: - Initialize Functions
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // MARK: - Selectors
    
    // Like Button Action
    @IBAction func likeButtonAction(_ sender: UIButton) {
        self.likeComment(reply_id: self.replyCommentData?.id ?? 0)
    }
    
    // DisLike Button Action
    @IBAction func disLikeButtonAction(_ sender: UIButton) {
        self.disLikeComment(reply_id: self.replyCommentData?.id ?? 0)
    }
    
    // MARK: - Helper functions
    
    func bind(_ object: ReplyComment) {
        self.replyCommentData = object
        self.likeCount = object.replyLikes ?? 0
        self.commentTextLabel.text = object.text?.htmlAttributedString ?? ""
        self.likeCountLabel.text = "\(object.replyLikes ?? 0)"
        let profileImage = URL(string: object.replyUserData?.avatar ?? "")
        self.lblUsername.text = "\(object.replyUserData?.username ?? "") · \(object.textTime ?? "")"
        self.profileImage.sd_setImage(with: profileImage, placeholderImage: R.image.maxresdefault())
        if object.replyLikes == 0 && object.replyDislikes == 0 {
            self.likeButton.setImage(UIImage(named: "like_gray"), for: .normal)
            self.dislikeButton.setImage(UIImage(named: "dislike_gray"), for: .normal)
        } else {
            if object.isLikedReply == 1 {
                self.likeButton.setImage(UIImage(named: "like_blue-1"), for: .normal)
                self.dislikeButton.setImage(UIImage(named: "dislike_gray"), for: .normal)
            } else {
                self.likeButton.setImage(UIImage(named: "like_gray"), for: .normal)
                self.dislikeButton.setImage(UIImage(named: "dislike_blue-1"), for: .normal)
            }
        }
    }
    
}

// MARK: - Extensions

// MARK: Api Call
extension ReplyCommentCell {
    
    func likeComment(reply_id: Int) {
        if Connectivity.isConnectedToNetwork() {
            let userID = AppInstance.instance.userId ?? 0
            let sessionID = AppInstance.instance.sessionId ?? ""
            Async.background({
                UserActivityManager.sharedInstance.likeActivityReplyComments(User_id: userID, Session_Token: sessionID, Type: "like", reply_id: reply_id, completionBlock: { (success, sessionError, error) in
                    if success != nil {
                        Async.main {
                            log.verbose("success \(success?.liked ?? 0)")
                            if success?.liked == 1 {
                                self.likeButton.setImage(UIImage(named: "like_blue-1"), for: .normal)
                                log.verbose("success = \(success?.successType ?? "")")
                                self.likeCount = self.likeCount! + 1
                                self.likeCountLabel.text = "\(self.likeCount ?? 0)"
                                if self.dislikeButton.imageView!.image == UIImage(named: "dislike_blue-1") {
                                    self.dislikeButton.setImage(UIImage(named: "dislike_gray"), for: .normal)
                                }
                                obj_appDelegate.window?.rootViewController?.view.makeToast(NSLocalizedString("Liked", comment: "Liked"))
                            } else {
                                self.likeButton.setImage(UIImage(named: "like_gray"), for: .normal)
                                log.verbose("success = \(success?.successType ?? "")")
                                self.likeCount = self.likeCount! - 1
                                self.likeCountLabel.text = "\(self.likeCount ?? 0)"
                            }
                        }
                    } else if sessionError != nil {
                        log.verbose("sessionError = \(sessionError?.errors!.error_text ?? "")")
                        obj_appDelegate.window?.rootViewController?.view.makeToast(sessionError?.errors!.error_text ?? "")
                    } else {
                        log.verbose("error = \(error?.localizedDescription ?? "")")
                        obj_appDelegate.window?.rootViewController?.view.makeToast(error?.localizedDescription ?? "")
                    }
                })
            })
        } else {
            obj_appDelegate.window?.rootViewController?.view.makeToast(InterNetError)
        }
    }
    
    func disLikeComment(reply_id: Int) {
        if Connectivity.isConnectedToNetwork() {
            let userID = AppInstance.instance.userId ?? 0
            let sessionID = AppInstance.instance.sessionId ?? ""
            Async.background {
                UserActivityManager.sharedInstance.dislikeActivityReplyComments(User_id: userID, Session_Token: sessionID, Type: "dislike", reply_id: reply_id, completionBlock: { (success, sessionError, error) in
                    if success != nil{
                        Async.main({
                            log.verbose("success \(success?.dislike ?? 0) ")
                            if success?.dislike == 1 {
                                self.dislikeButton.setImage(UIImage(named: "dislike_blue-1"), for: .normal)
                                log.verbose("success = \(success?.successType ?? "")")
                                if self.likeButton.imageView!.image == UIImage(named: "like_blue-1"){
                                    self.likeButton.setImage(UIImage(named: "like_gray"), for: .normal)
                                    self.likeCount = self.likeCount! - 1
                                    self.likeCountLabel.text = "\(self.likeCount ?? 0)"
                                }
                                obj_appDelegate.window?.rootViewController?.view.makeToast(NSLocalizedString("Disliked", comment: "Disliked"))
                            } else {
                                self.dislikeButton.setImage(UIImage(named: "dislike_gray"), for: .normal)
                                log.verbose("success = \(success?.successType ?? "")")
                            }
                        })
                    } else if sessionError != nil {
                        log.verbose("sessionError = \(sessionError?.errors!.error_text ?? "")")
                        obj_appDelegate.window?.rootViewController?.view.makeToast(sessionError?.errors!.error_text ?? "")
                    } else {
                        log.verbose("error = \(error?.localizedDescription ?? "")")
                        obj_appDelegate.window?.rootViewController?.view.makeToast(error?.localizedDescription ?? "")
                    }
                })
            }
        } else {
            obj_appDelegate.window?.rootViewController?.view.makeToast(InterNetError)
        }
    }
    
}
