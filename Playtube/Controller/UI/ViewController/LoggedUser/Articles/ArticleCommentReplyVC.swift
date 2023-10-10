

import UIKit
import Async
import PlaytubeSDK
import UIView_Shimmer

class ArticleCommentReplyVC: BaseVC {
    
    @IBOutlet weak var likeBtn: UIButton!
    @IBOutlet weak var shareCount: UILabel!
    @IBOutlet weak var commentTextField: UITextField!
    @IBOutlet weak var dislikeCountLabel: UILabel!
    @IBOutlet weak var dislikeBtn: UIButton!
    @IBOutlet weak var likeCount: UILabel!
    @IBOutlet weak var commentTextLabel: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    
    var isLoading = true
    var commentData: Comment? = nil
    var playerCommentData: Comment? = nil
    
    private var repliesArray: [ReplyComment] = []
    @IBOutlet weak var noReplyLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.isLoading = true
        self.tableView.reloadData()
        self.fetchCommentReplies()
        self.setupUI()
        log.verbose("commentData?.videoID = \(commentData?.videoID)")
    }
    
    @IBAction func sendPressed(_ sender: Any) {
        self.addReply()
    }
    
    private func setupUI(){
        self.tableView.separatorStyle = .none
        tableView.register(UINib(resource: R.nib.articlesSectionFiveTableItem), forCellReuseIdentifier: R.reuseIdentifier.articlesSectionFiveTableItem.identifier)
        
        if self.commentData != nil{
            self.commentTextLabel.text = commentData?.text ?? ""
            self.likeCount.text = "\(self.commentData?.likes ?? 0)"
            self.dislikeCountLabel.text = "\(self.commentData?.disLikes ?? 0)"
            self.shareCount.text = "\(self.commentData?.repliesCount ?? 0)"
            if commentData?.isLikedComment == 1 {
                self.likeBtn.setImage(R.image.ic_likeBlue(), for: .normal)
                self.dislikeBtn.setImage(R.image.dislike(), for: .normal)
                
            }else if (commentData?.isDislikedComment == 1) {
                self.dislikeBtn.setImage(R.image.ic_dislikeBLue(), for: .normal)
                self.likeBtn.setImage(R.image.like(), for: .normal)
            }
            else{
                self.dislikeBtn.setImage(R.image.dislike(), for: .normal)
                self.likeBtn.setImage(R.image.like(), for: .normal)
            }
            
            let profileImage = URL(string: commentData?.commentUserData?.avatar ?? "")
            self.profileImage.sd_setImage(with: profileImage , placeholderImage:R.image.maxresdefault())
        }else{
            self.commentTextLabel.text = playerCommentData?.text ?? ""
            self.likeCount.text = "\(self.playerCommentData?.likes ?? 0)"
            self.dislikeCountLabel.text = "\(self.playerCommentData?.disLikes ?? 0)"
            self.shareCount.text = "\(self.playerCommentData?.repliesCount ?? 0)"
            if playerCommentData?.isLikedComment == 1{
                self.likeBtn.setImage(R.image.ic_likeBlue(), for: .normal)
                self.dislikeBtn.setImage(R.image.dislike(), for: .normal)
                
            }else if (playerCommentData?.isDislikedComment == 1){
                self.dislikeBtn.setImage(R.image.ic_dislikeBLue(), for: .normal)
                self.likeBtn.setImage(R.image.like(), for: .normal)
            }
            else{
                self.dislikeBtn.setImage(R.image.dislike(), for: .normal)
                self.likeBtn.setImage(R.image.like(), for: .normal)
            }
            let profileImage = URL(string: playerCommentData?.commentUserData?.avatar ?? "")
            self.profileImage.sd_setImage(with: profileImage , placeholderImage:R.image.maxresdefault())
        }
    }
    
    private func fetchCommentReplies(){
        let userID = AppInstance.instance.userId ?? 0
        let sessionID = AppInstance.instance.sessionId ?? ""
        var commentID:Int? = 0
        if self.commentData != nil{
            commentID = commentData?.id ?? 0
        }else{
            commentID = playerCommentData?.id ?? 0
        }
        Async.background({
            PlayVideoManager.instance.fetchReplies(User_id: userID, Session_Token: sessionID, Type: "fetch_replies", Comment_Id: commentID!, completionBlock: { (success, sessionError, error) in
                if success != nil{
                    Async.main({
                        self.dismissProgressDialog {
                            self.repliesArray.removeAll()
                            self.repliesArray = (success?.data)!
                            self.isLoading = false
                            if self.repliesArray.isEmpty{
                                self.tableView.isHidden = false
//                                self.noReplyLabel.isHidden = false
                            }else{
                                self.tableView.isHidden = false
//                                self.noReplyLabel.isHidden = true
                                
                            }
                            self.tableView.reloadData()
                        }
                    })
                }else if sessionError != nil{
                    Async.main({
                        self.dismissProgressDialog {
                            log.error("SessionError = \(sessionError?.errors!.error_text)")
                            self.view.makeToast(sessionError?.errors!.error_text)
                        }
                        
                    })
                }else{
                    Async.main({
                        self.dismissProgressDialog {
                            log.error("error = \(error?.localizedDescription)")
                            self.view.makeToast(error?.localizedDescription)
                        }
                    })
                }
            })
        })
    }
    
    private func addReply(){
        self.showProgressDialog(text: NSLocalizedString("Loading...", comment: "Loading..."))
        let userID = AppInstance.instance.userId ?? 0
        let sessionID = AppInstance.instance.sessionId ?? ""
        var commentID:Int? = 0
        var videoID:Int? = 0
        var article_id:Int? = 0
        if self.commentData != nil{
            commentID = commentData?.id ?? 0
            videoID = commentData?.videoID ?? 0
            article_id = commentData?.id ?? 0
        }else{
            commentID = playerCommentData?.id ?? 0
            videoID = playerCommentData?.videoID ?? 0
            article_id = playerCommentData?.id ?? 0
        }
        
        let commentText = self.commentTextField.text ?? ""
        if (self.commentData != nil){
            ArticlesManager.instance.addArticleCommentReply(article_id: article_id ?? 0, Comment_Id: commentID ?? 0, Comment_Text: commentText) { (success, authError, error) in
                if (success != nil){
                    Async.main({
                        self.dismissProgressDialog {
                            self.fetchCommentReplies()
                            self.commentTextField.text = nil
                        }
                    })
                }
                else if (authError != nil){
                    Async.main({
                        self.dismissProgressDialog {
                            log.error("SessionError = \(authError?.errors!.error_text)")
                            self.view.makeToast(authError?.errors!.error_text)
                        }
                    })
                }
                else{
                    Async.main({
                        self.dismissProgressDialog {
                            log.error("error = \(error?.localizedDescription)")
                            self.view.makeToast(error?.localizedDescription)
                        }
                    })
                }
            }
        }
        else if (self.playerCommentData != nil){
            Async.background({
                PlayVideoManager.instance.addCommentReply(User_id: userID, Session_Token: sessionID, VideoId: videoID!, Comment_Id: commentID!, Type: "reply", Comment_Text: commentText, completionBlock: { (success, sessionError, error) in
                    if success != nil{
                        Async.main({
                            self.dismissProgressDialog {
                                self.fetchCommentReplies()
                                self.commentTextField.text = nil
                            }
                        })
                    }else if sessionError != nil{
                        Async.main({
                            self.dismissProgressDialog {
                                log.error("SessionError = \(sessionError?.errors!.error_text)")
                                self.view.makeToast(sessionError?.errors!.error_text)
                            }
                            
                        })
                    }else{
                        Async.main({
                            self.dismissProgressDialog {
                                log.error("error = \(error?.localizedDescription)")
                                self.view.makeToast(error?.localizedDescription)
                            }
                        })
                    }
                })
            })
        }
    }
}
extension ArticleCommentReplyVC:UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isLoading {
            return 5
        }else {
            if self.repliesArray.count == 0 {
                return 1
            }
            return self.repliesArray.count + 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isLoading {
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.articlesSectionFiveTableItem.identifier) as! ArticlesSectionFiveTableItem
            cell.profileLeadingConst.constant = indexPath.row == 0 ? 15.0 : 40.0
            return cell
        }else {
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.articlesSectionFiveTableItem.identifier) as? ArticlesSectionFiveTableItem
            cell!.articleReplyVC = self
            if indexPath.row != 0 {
                let object = self.repliesArray[indexPath.row-1]
                cell?.bind(nil, playerCommentData: nil, articleData: object)
            } else {
                cell?.bind(self.commentData!, playerCommentData: nil, articleData: nil)
                cell?.btnReplies.isEnabled = false
            }
            cell?.profileLeadingConst.constant = indexPath.row == 0 ? 15.0 : 40.0
            return cell!
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.setTemplateWithSubviews(isLoading, animate: true, viewBackgroundColor: .systemBackground)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
