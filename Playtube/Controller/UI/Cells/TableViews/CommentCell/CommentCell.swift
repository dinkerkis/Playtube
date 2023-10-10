//
//  CommentCell.swift
//  Playtube
//
//  Created by iMac on 30/05/23.
//  Copyright © 2023 ScriptSun. All rights reserved.
//

import UIKit
import UIView_Shimmer
import SDWebImage
import Async
import PlaytubeSDK

protocol CommentCellDelegate {
    func handleRepliesButtonTap(_ sender: UIButton, commentData: Comment?)
}

class CommentCell: UITableViewCell, ShimmeringViewProtocol {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var lblUsername: UILabel!
    @IBOutlet weak var commentTextLabel: UILabel!
    @IBOutlet weak var replyCountLabel: UILabel!
    @IBOutlet weak var replyCountLabelTop: NSLayoutConstraint!
    @IBOutlet weak var replyCountLabelHeight: NSLayoutConstraint!
    @IBOutlet weak var likeCountLabel: UILabel!
    @IBOutlet weak var dislikeButton: UIButton!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var repliesButton: UIButton!
    
    // MARK: - Properties
    
    var shimmeringAnimatedItems: [UIView] {
        [
            profileImage,
            lblUsername,
            commentTextLabel,
            likeButton,
            likeCountLabel,
            dislikeButton,
            replyCountLabel
        ]
    }
    var commentData: Comment?
    var likeCount: Int? = 0
    var delegate: CommentCellDelegate?
    
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
        self.likeComment(commentID: commentData?.id ?? 0)
    }
    
    // DisLike Button Action
    @IBAction func disLikeButtonAction(_ sender: UIButton) {
        self.disLikeComment(commentID: self.commentData?.id ?? 0)
    }
    
    // Replies Button Action
    @IBAction func repliesButtonAction(_ sender: UIButton) {
        self.delegate?.handleRepliesButtonTap(sender, commentData: self.commentData)
    }
    
    // MARK: - Helper functions
    
    func bind(_ object: Comment) {
        self.commentData = object
        self.likeCount = object.likes ?? 0
        self.commentTextLabel.text = object.text?.htmlAttributedString ?? ""
        self.likeCountLabel.text = "\(object.likes ?? 0)"
        self.replyCountLabelTop.constant = 8
        self.replyCountLabelHeight.constant = 24
        self.replyCountLabel.text = "\(object.repliesCount ?? 0) Replies"
        let profileImage = URL(string: object.commentUserData?.avatar ?? "")
        self.lblUsername.text = "\(object.commentUserData?.username ?? "") · \(object.textTime ?? "")"
        self.profileImage.sd_setImage(with: profileImage, placeholderImage: R.image.maxresdefault())
        if object.likes == 0 && object.disLikes == 0 {
            self.likeButton.setImage(UIImage(named: "like_gray"), for: .normal)
            self.dislikeButton.setImage(UIImage(named: "dislike_gray"), for: .normal)
        } else {
            if object.isLikedComment == 1 {
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
extension CommentCell {
    
    func likeComment(commentID: Int) {
        if Connectivity.isConnectedToNetwork() {
            let userID = AppInstance.instance.userId ?? 0
            let sessionID = AppInstance.instance.sessionId ?? ""
            Async.background({
                ArticlesManager.instance.likeArticleComments(User_id: userID, Session_Token: sessionID, Type: "like", Comment_Id: commentID, completionBlock: { (success, sessionError, error) in
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
    
    func disLikeComment(commentID: Int) {
        if Connectivity.isConnectedToNetwork() {
            let userID = AppInstance.instance.userId ?? 0
            let sessionID = AppInstance.instance.sessionId ?? ""
            Async.background {
                ArticlesManager.instance.dislikeArticlesComments(User_id: userID, Session_Token: sessionID, Type: "dislike", Comment_Id: commentID, completionBlock: { (success, sessionError, error) in
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
