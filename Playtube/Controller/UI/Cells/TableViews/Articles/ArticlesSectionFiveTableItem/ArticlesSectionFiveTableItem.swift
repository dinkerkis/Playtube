
import UIKit
import Async
import PlaytubeSDK
import FittedSheets
import UIView_Shimmer

class ArticlesSectionFiveTableItem: UITableViewCell, ShimmeringViewProtocol {
    
    @IBOutlet weak var lblUsername: UILabel!
    @IBOutlet weak var commentTextLabel: UILabel!
    @IBOutlet weak var profileLeadingConst: NSLayoutConstraint!
    @IBOutlet weak var likeCountLabel: UILabel!
    @IBOutlet weak var dislikeBtn: UIButton!
    @IBOutlet weak var likeBtn: UIButton!
    @IBOutlet weak var btnReplies: UIButton!
    @IBOutlet weak var profileImage: UIImageView!
    
    var shimmeringAnimatedItems: [UIView] {
        [
            lblUsername,
            commentTextLabel,
            likeCountLabel,
            dislikeBtn,
            likeBtn,
            btnReplies,
            profileImage
        ]
    }
    
    var commentData: Comment?
    var playerCommentData: Comment?
    var vc:DetailsArticlesVC?
    var articleReplyVC:ArticleCommentReplyVC?
    var playerCommentVC:PlayerCommentVC?
    var articlesReplyData: ReplyComment?
    var likeCount:Int? = 0
    var dislikeCount:Int? = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    @IBAction func likePressed(_ sender: Any) {
        if AppInstance.instance.getUserSession(){
            if self.commentData != nil{
//                self.likeCount = commentData?.likes ?? 0
                self.likeArticleComment(commentID: self.commentData?.id ?? 0)
                
            }else if self.playerCommentData != nil{
//                self.likeCount = playerCommentData?.likes ?? 0
                self.likeArticleComment(commentID: self.playerCommentData?.id ?? 0)
                
            }else if self.articlesReplyData != nil{
//                self.likeCount = articlesReplyData?.replyLikes ?? 0
                self.likeArticleComment(commentID: self.articlesReplyData?.commentID ?? 0)
            }
        }else{
            let vc = R.storyboard.popups.loginPopupVC()
            self.vc?.present(vc!, animated: true, completion: nil)
        }
        
    }
    @IBAction func sharePressed(_ sender: Any) {
        if AppInstance.instance.getUserSession(){
            if self.commentData != nil {
                let viewController = R.storyboard.articles.articleCommentReplyVC()
                viewController?.commentData = self.commentData
                let controller = SheetViewController(controller:viewController!, sizes: [.percent(0.5)])
                self.vc?.present(controller, animated: false, completion: nil)
            }else if self.playerCommentData != nil{
                let viewController = R.storyboard.articles.articleCommentReplyVC()
                viewController?.playerCommentData = self.playerCommentData
                let controller = SheetViewController(controller:viewController!, sizes: [.fixed(420), .intrinsic])
                self.playerCommentVC?.present(controller, animated: true, completion: nil)
            }
        }else{
            let vc = R.storyboard.popups.loginPopupVC()
            self.vc?.present(vc!, animated: true, completion: nil)
        }
    }
    
    @IBAction func dislikePressed(_ sender: Any) {
        if AppInstance.instance.getUserSession(){
            if self.commentData != nil{
//                dislikeCount = commentData?.disLikes
                self.disLikeArticleComment(commentID: self.commentData?.id ?? 0)
                
            }else if self.playerCommentData != nil{
//                dislikeCount = playerCommentData?.disLikes
                self.disLikeArticleComment(commentID: self.playerCommentData?.id ?? 0)
                
            }else if self.articlesReplyData != nil{
//                dislikeCount = articlesReplyData?.replyDislikes
                self.disLikeArticleComment(commentID: self.articlesReplyData?.commentID ?? 0)
            }
        }else{
            let vc = R.storyboard.popups.loginPopupVC()
            self.vc?.present(vc!, animated: true, completion: nil)
        }
       
    }
    func bind(_ object: Comment?, playerCommentData: Comment?, articleData: ReplyComment?) {
        
        if object != nil{
            self.btnReplies.isHidden = false
            self.commentData = object
            self.likeCount = object?.likes ?? 0
            self.dislikeCount = object?.disLikes ?? 0
            self.commentTextLabel.text = object?.text?.htmlAttributedString ?? ""
            self.likeCountLabel.text = "\(object?.likes ?? 0)"
            self.btnReplies.setTitle("\(object?.repliesCount ?? 0) Replies", for: .normal)
            let profileImage = URL(string: object?.commentUserData?.avatar ?? "")
            self.lblUsername.text = "\(object?.commentUserData?.username ?? "") | \(object?.textTime ?? "")"
            self.profileImage.sd_setImage(with: profileImage , placeholderImage:R.image.maxresdefault())
            if object?.likes == 0 && object?.disLikes == 0{
                self.likeBtn.setImage(UIImage(named: "like_gray"), for: .normal)
                self.dislikeBtn.setImage(UIImage(named: "dislike_gray"), for: .normal)
            }else{
                if object?.isLikedComment == 1{
                    self.likeBtn.setImage(UIImage(named: "like_blue-1"), for: .normal)
                    self.dislikeBtn.setImage(UIImage(named: "dislike_gray"), for: .normal)
                }else{
                    self.likeBtn.setImage(UIImage(named: "like_gray"), for: .normal)
                    self.dislikeBtn.setImage(UIImage(named: "dislike_blue-1"), for: .normal)
                }
            }
        }else if playerCommentData != nil{
            self.btnReplies.isHidden = false
            self.playerCommentData = playerCommentData
            self.likeCount = playerCommentData?.likes ?? 0
            self.dislikeCount = playerCommentData?.disLikes ?? 0
            self.commentTextLabel.text = playerCommentData?.text?.htmlAttributedString ?? ""
            self.likeCountLabel.text = "\(playerCommentData?.likes ?? 0)"
            self.btnReplies.setTitle("\(playerCommentData?.repliesCount ?? 0) Replies", for: .normal)
            let profileImage = URL(string: playerCommentData?.commentUserData?.avatar ?? "")
            self.lblUsername.text = "\(playerCommentData?.commentUserData?.username ?? "") | \(playerCommentData?.textTime ?? "")"
            self.profileImage.sd_setImage(with: profileImage , placeholderImage:R.image.maxresdefault())
            
            if object?.likes == 0 && object?.disLikes == 0{
                self.likeBtn.setImage(UIImage(named: "like_gray"), for: .normal)
                self.dislikeBtn.setImage(UIImage(named: "dislike_gray"), for: .normal)
            }else{
                if object?.isLikedComment == 1{
                    self.likeBtn.setImage(UIImage(named: "like_blue-1"), for: .normal)
                    self.dislikeBtn.setImage(UIImage(named: "dislike_gray"), for: .normal)
                }else if (object?.isDislikedComment == 1){
                    self.likeBtn.setImage(UIImage(named: "like_gray"), for: .normal)
                    self.dislikeBtn.setImage(UIImage(named: "dislike_blue-1"), for: .normal)
                } else {
                    self.likeBtn.setImage(UIImage(named: "like_gray"), for: .normal)
                    self.dislikeBtn.setImage(UIImage(named: "dislike_gray"), for: .normal)
                }
            }
        }else if articleData != nil{
            self.articlesReplyData = articleData
            self.likeCount = articleData?.replyLikes ?? 0
            self.dislikeCount = articleData?.replyDislikes ?? 0
            self.commentTextLabel.text = articleData?.text?.htmlAttributedString ?? ""
            self.likeCountLabel.text = "\(articleData?.replyLikes ?? 0)"
            self.btnReplies.isHidden = true
            //self.dislikeCountLabel.text = "\(articleData?.replyDislikes ?? 0)"
            let profileImage = URL(string: articleData?.replyUserData?.avatar ?? "")
            self.lblUsername.text = "\(articleData?.replyUserData?.username ?? "") | \(articleData?.textTime ?? "")"
            self.profileImage.sd_setImage(with: profileImage , placeholderImage:R.image.maxresdefault())
            if articleData?.replyLikes == 0 && articleData?.replyDislikes == 0{
                self.likeBtn.setImage(UIImage(named: "like_gray"), for: .normal)
                self.dislikeBtn.setImage(UIImage(named: "dislike_gray"), for: .normal)
            }else{
                if articleData?.isLikedReply == 1{
                    self.likeBtn.setImage(UIImage(named: "like_blue-1"), for: .normal)
                    self.dislikeBtn.setImage(UIImage(named: "dislike_gray"), for: .normal)
                }else{
                    self.likeBtn.setImage(UIImage(named: "like_gray"), for: .normal)
                    self.dislikeBtn.setImage(UIImage(named: "dislike_blue-1"), for: .normal)
                }
            }
        }
    }
    func likeArticleComment(commentID:Int) {
        if Connectivity.isConnectedToNetwork(){
            let userID = AppInstance.instance.userId ?? 0
            let sessionID = AppInstance.instance.sessionId ?? ""
            Async.background({
                ArticlesManager.instance.likeArticleComments(User_id: userID, Session_Token: sessionID, Type: "like", Comment_Id: commentID, completionBlock: { (success, sessionError, error) in
                    if success != nil{
                        Async.main({
                            log.verbose("success \(success?.liked) ")
                            
                            if success?.liked == 1 {
                                self.likeBtn.setImage(UIImage(named: "like_blue-1"), for: .normal)
                                log.verbose("success = \(success?.successType)")
                                self.likeCount = self.likeCount! + 1
                                self.likeCountLabel.text = "\(self.likeCount ?? 0)"
//                                R.image.likeblue()
//                                R.image.like()
//                                R.image.ic_dislikeBLue()
//                                R.image.dislike()
                                
                                 if self.dislikeBtn.imageView!.image == UIImage(named: "dislike_blue-1") {
                                    
                                    self.dislikeBtn.setImage(UIImage(named: "dislike_gray"), for: .normal)
                                        self.dislikeCount = self.dislikeCount! - 1
                                        //self.dislikeCountLabel.text = "\(self.dislikeCount ?? 0)"
                                        
                                    }

                                ////////////////////////////
//                                if self.likeBtn.imageView!.image == R.image.likeblue(){
//                                    self.likeBtn.setImage(R.image.like(), for: .normal)
//                                    self.likeCount = self.likeCount! + 1
//                                    self.likeCountLabel.text = "\(self.likeCount ?? 0)"
//
//                                }
//                                if self.dislikeBtn.imageView!.image == R.image.ic_dislikeBLue(){
//                                    self.dislikeBtn.setImage(R.image.dislike(), for: .normal)
//                                    self.dislikeCount = self.dislikeCount! - 1
//                                    self.dislikeCountLabel.text = "\(self.dislikeCount ?? 0)"
//
//                                }
                                if self.vc != nil{
                                    self.vc!.view.makeToast(NSLocalizedString("Liked", comment: "Liked"))
                                    
                                }else if self.playerCommentVC != nil{
                                    self.playerCommentVC!.view.makeToast(NSLocalizedString("Liked", comment: "Liked"))
                                }else if self.articleReplyVC != nil{
                                    self.articleReplyVC!.view.makeToast(NSLocalizedString("Liked", comment: "Liked"))
                                }
     
                            }
                            else{
                                self.likeBtn.setImage(UIImage(named: "like_gray"), for: .normal)
                                log.verbose("success = \(success?.successType)")
                                self.likeCount = self.likeCount! - 1
                                self.likeCountLabel.text = "\(self.likeCount ?? 0)"
                            }
                        })
                        
                    }else if sessionError != nil{
                        if self.vc != nil{
                            log.verbose("sessionError = \(sessionError?.errors!.error_text ?? "")")
                            self.vc!.view.makeToast(sessionError?.errors!.error_text ?? "")
                            
                        }else if self.playerCommentVC != nil{
                            log.verbose("sessionError = \(sessionError?.errors!.error_text ?? "")")
                            self.playerCommentVC!.view.makeToast(sessionError?.errors!.error_text ?? "")
                        }else if self.articleReplyVC != nil{
                            log.verbose("sessionError = \(sessionError?.errors!.error_text ?? "")")
                            self.articleReplyVC!.view.makeToast(sessionError?.errors!.error_text ?? "")
                        }
                        
                    }else{
                        if self.vc != nil{
                            log.verbose("error = \(error?.localizedDescription ?? "")")
                            self.vc!.view.makeToast(error?.localizedDescription ?? "")
                            
                        }else if self.playerCommentVC != nil{
                            log.verbose("error = \(error?.localizedDescription ?? "")")
                            self.playerCommentVC!.view.makeToast(error?.localizedDescription ?? "")
                        }else if self.articleReplyVC != nil{
                            log.verbose("sessionError = \(sessionError?.errors!.error_text ?? "")")
                            self.articleReplyVC!.view.makeToast(sessionError?.errors!.error_text ?? "")
                        }
                    }
                })
            })
            
        }else{
            if self.vc != nil{
                self.vc!.view.makeToast(InterNetError)
                
            }else if self.playerCommentVC != nil{
                self.playerCommentVC!.view.makeToast(InterNetError)

            }else if self.articleReplyVC != nil{
                self.articleReplyVC!.view.makeToast(InterNetError)
            }
        }
    }
    func disLikeArticleComment(commentID:Int) {
        if Connectivity.isConnectedToNetwork(){
            let userID = AppInstance.instance.userId ?? 0
            let sessionID = AppInstance.instance.sessionId ?? ""
            Async.background({
                ArticlesManager.instance.dislikeArticlesComments(User_id: userID, Session_Token: sessionID, Type: "dislike", Comment_Id: commentID, completionBlock: { (success, sessionError, error) in
                    if success != nil{
                        Async.main({
                            log.verbose("success \(success?.dislike) ")
                            //
                            
                            if success?.dislike == 1{
                                self.dislikeBtn.setImage(UIImage(named: "dislike_blue-1"), for: .normal)
                                
                                log.verbose("success = \(success?.successType)")
                                self.dislikeCount = self.dislikeCount! + 1
                                //self.dislikeCountLabel.text = "\(self.dislikeCount ?? 0)"
                                
                                if self.likeBtn.imageView!.image == UIImage(named: "like_blue-1"){
                                    self.likeBtn.setImage(UIImage(named: "like_gray"), for: .normal)
                                    self.likeCount = self.likeCount! - 1
                                    self.likeCountLabel.text = "\(self.likeCount ?? 0)"
                                }
                                
                                
//                                if self.dislikeBtn.imageView!.image == R.image.ic_dislikeBLue(){
//                                    self.dislikeCount = self.dislikeCount! + 1
//                                    self.dislikeCountLabel.text = "\(self.dislikeCount ?? 0)"
//
//                                }
//                                if self.likeBtn.imageView!.image == R.image.ic_likeBlue(){
//                                    self.likeBtn.setImage(R.image.like(), for: .normal)
//                                    self.likeCount = self.likeCount! - 1
//                                    self.likeCountLabel.text = "\(self.likeCount ?? 0)"
//
//                                }
                                
                                if self.vc != nil{
                                    self.vc!.view.makeToast(NSLocalizedString("Disliked", comment: "Disliked"))
                                    
                                }else if self.playerCommentVC != nil {
                                    self.playerCommentVC!.view.makeToast(NSLocalizedString("Disliked", comment: "Disliked"))
                                    
                                }else if self.articleReplyVC != nil {
                                    self.articleReplyVC!.view.makeToast(NSLocalizedString("Disliked", comment: "Disliked"))
                                }
                            }else{
                                self.dislikeBtn.setImage(UIImage(named: "dislike_gray"), for: .normal)
                                 log.verbose("success = \(success?.successType)")
                                 self.dislikeCount = self.dislikeCount! - 1
                                 //self.dislikeCountLabel.text = "\(self.dislikeCount ?? 0)"
                                
//                                self.dislikeBtn.setImage(R.image.dislike(), for: .normal)
//                                log.verbose("success = \(success?.successType)")
//                                self.dislikeCount = self.dislikeCount! - 1
//                                self.dislikeCountLabel.text = "\(self.dislikeCount ?? 0)"
                            }
                        })
                        
                    }else if sessionError != nil{
                        if self.vc != nil{
                            log.verbose("sessionError = \(sessionError?.errors!.error_text ?? "")")
                            self.vc!.view.makeToast(sessionError?.errors!.error_text ?? "")
                            
                        }else if self.playerCommentVC != nil{
                            log.verbose("sessionError = \(sessionError?.errors!.error_text ?? "")")
                            self.playerCommentVC!.view.makeToast(sessionError?.errors!.error_text ?? "")
                        }else if self.articleReplyVC != nil{
                            log.verbose("sessionError = \(sessionError?.errors!.error_text ?? "")")
                            self.articleReplyVC!.view.makeToast(sessionError?.errors!.error_text ?? "")
                        }
                    }else{
                        if self.vc != nil{
                            log.verbose("error = \(error?.localizedDescription ?? "")")
                            self.vc!.view.makeToast(error?.localizedDescription ?? "")
                            
                        }else if self.playerCommentVC != nil{
                            log.verbose("error = \(error?.localizedDescription ?? "")")
                            self.playerCommentVC!.view.makeToast(error?.localizedDescription ?? "")
                        }else if self.articleReplyVC != nil{
                            log.verbose("sessionError = \(sessionError?.errors!.error_text ?? "")")
                            self.articleReplyVC!.view.makeToast(sessionError?.errors!.error_text ?? "")
                        }
                        
                    }
                })
            })
            
        }else{
            if self.vc != nil{
                self.vc!.view.makeToast(InterNetError)
                
            }else if self.playerCommentVC != nil{
                self.playerCommentVC!.view.makeToast(InterNetError)
                
            }else if self.articleReplyVC != nil{
                self.articleReplyVC!.view.makeToast(InterNetError)
            }
        }
    }
}
