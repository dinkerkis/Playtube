import UIKit
import Async
import PlaytubeSDK
import Toast_Swift

class ArticlesSectionSevenTableItem: UITableViewCell {

    @IBOutlet weak var commentTextfiled: UITextField!
    
    var vc: DetailsArticlesVC?
    var playerCommentVC: PlayerCommentVC?
    var ArticleData: Article?
    var playerCommentData: Comment?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func bind(_ object: Article?, playerCommentData: Comment?) {
        if object != nil {
            self.ArticleData = object
        } else if playerCommentData != nil {
            self.playerCommentData = playerCommentData
        }
    }
    
    @IBAction func sendPressed(_ sender: Any) {
        if self.commentTextfiled.text!.isEmpty{
            self.vc!.view.makeToast(NSLocalizedString("Please type Comment", comment: "Please type Comment"))
        } else {
            if self.ArticleData != nil {
                self.sendComment(postID: self.ArticleData?.id ?? 0)
            } else if self.playerCommentData != nil {
                self.sendComment(postID: self.playerCommentData?.videoID ?? 0)
            }
        }
    }
    
    func sendComment(postID: Int) {
        if Connectivity.isConnectedToNetwork() {
            let userID = AppInstance.instance.userId ?? 0
            let sessionID = AppInstance.instance.sessionId ?? ""
            let commentText = self.commentTextfiled.text ?? ""
            Async.background {
                ArticlesManager.instance.addArtilcesComments(User_id: userID, Session_Token: sessionID, Post_id: postID, Comment_Text: commentText, completionBlock: { (success, sessionError, error) in
                    if success != nil {
                        Async.main {
                            log.verbose("success \(success?.message ?? "") ")
                            if self.vc != nil {
                            self.vc?.fetchArticlesComment()
                            } else {
                                self.playerCommentVC!.fetchComments()
                            }
                        }
                    } else if sessionError != nil {
                        if self.vc != nil {
                            log.verbose("sessionError = \(sessionError?.errors!.error_text ?? "")")
                            self.vc!.view.makeToast(sessionError?.errors!.error_text ?? "")
                        } else {
                            log.verbose("sessionError = \(sessionError?.errors!.error_text ?? "")")
                            self.playerCommentVC!.view.makeToast(sessionError?.errors!.error_text ?? "")
                        }
                    } else {
                        if self.vc != nil {
                            log.verbose("error = \(error?.localizedDescription ?? "")")
                            self.vc!.view.makeToast(error?.localizedDescription ?? "")
                        } else {
                            log.verbose("error = \(error?.localizedDescription ?? "")")
                            self.playerCommentVC!.view.makeToast(error?.localizedDescription ?? "")
                        }
                    }
                })
            }
        } else {
           if self.vc != nil {
                self.vc!.view.makeToast(InterNetError)
            } else {
                self.playerCommentVC!.view.makeToast(InterNetError)
            }
        }
    }
    
}
