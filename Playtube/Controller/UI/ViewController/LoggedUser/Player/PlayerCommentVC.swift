import UIKit
import Async
import PlaytubeSDK
import Toast_Swift

class PlayerCommentVC: BaseVC {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var commentTextTextField: UITextField!
    
    // MARK: - Properties
    
    private var isLoading = true {
        didSet {
            tableView.reloadData()
        }
    }
    private var commentsArray = [Comment]()
    var videoID: Int? = 0
    var isEmpty = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        isLoading = true
        self.setupUI()
        self.fetchComments()
    }
    
    @IBAction func sendPressed(_ sender: Any) {
        self.sendComment(videoID: self.videoID ?? 0)
        
    }
    private func setupUI(){
        
        self.tableView.separatorStyle = .singleLine
        self.tableView.tableFooterView = UIView()
        tableView.register(UINib(resource: R.nib.articlesSectionFiveTableItem), forCellReuseIdentifier: R.reuseIdentifier.articlesSectionFiveTableItem.identifier)
        tableView.register(UINib(resource: R.nib.articlesSectionSixTableItem), forCellReuseIdentifier: R.reuseIdentifier.articlesSectionSixTableItem.identifier)
        tableView.register(UINib(resource: R.nib.articlesSectionSevenTableItem), forCellReuseIdentifier: R.reuseIdentifier.articlesSectionSevenTableItem.identifier)
    }
    func fetchComments(){
        //self.showProgressDialog(text: NSLocalizedString("Loading...", comment: "Loading..."))
        Async.background({
            //             self.dismissProgressDialog {
            self.commentsArray.removeAll()
            let userID = AppInstance.instance.userId ?? 0
            let sessionID = AppInstance.instance.sessionId ?? ""
            let videoID = self.videoID ?? 0
            PlayVideoManager.instance.fetchComments(User_id: userID, Session_Token: sessionID, VideoId: videoID, completionBlock: { (success, sessionError, error) in
                if success != nil{
                    Async.main({
                        self.dismissProgressDialog {
                            self.commentTextTextField.text  = ""
                            self.commentsArray = success?.data ?? []
                            if self.commentsArray.count != 0{
                                self.isEmpty = 0
                            }
                            else{
                                self.isEmpty = 1
                            }
                            
                            if self.commentsArray.isEmpty {
                                self.tableView.scrollToRow(at: IndexPath(item: 0, section: 0), at: .bottom, animated: false)
                            }
                            self.isLoading = false
                        }
                    })
                }else if sessionError != nil{
                    Async.main({
                        self.dismissProgressDialog {
                            
                            log.error("sessionError = \(sessionError?.errors!.error_text)")
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
    func sendComment(videoID:Int) {
        if Connectivity.isConnectedToNetwork(){
            self.showProgressDialog(text: NSLocalizedString("Loading...", comment: "Loading..."))
            let userID = AppInstance.instance.userId ?? 0
            let sessionID = AppInstance.instance.sessionId ?? ""
            let commentText = self.commentTextTextField.text ?? ""
            Async.background({
                PlayVideoManager.instance.addComments(User_id: userID, Session_Token: sessionID, VideoId: videoID, Comment_Text: commentText, completionBlock: { (success, sessionError, error) in
                    if success != nil{
                        Async.main({
                            self.dismissProgressDialog {
                                /*let data = CommentModel.Datum(id: success?.id ?? 0, userID: AppInstance.instance.userId ?? 0, videoID: 0, postID: 0, activityID: 0, text: self.commentTextTextField.text, time: 0, pinned: "", likes: 0, disLikes: 0, isLikedComment: 0, isCommentOwner: false, repliesCount: 0, commentReplies: nil, isDislikedComment: 0, commentUserData: CommentModel.UserData(id:AppInstance.instance.userId ?? 0, username: AppInstance.instance.userProfile?.data?.username, email: AppInstance.instance.userProfile?.data?.email, ipAddress: AppInstance.instance.userProfile?.data?.ipAddress, firstName: AppInstance.instance.userProfile?.data?.firstName, lastName: AppInstance.instance.userProfile?.data?.lastName, gender: AppInstance.instance.userProfile?.data?.gender, emailCode: AppInstance.instance.userProfile?.data?.emailCode, deviceID: AppInstance.instance.userProfile?.data?.deviceID, language: AppInstance.instance.userProfile?.data?.language, avatar: AppInstance.instance.userProfile?.data?.avatar, cover: AppInstance.instance.userProfile?.data?.cover, src: AppInstance.instance.userProfile?.data?.src, countryID: AppInstance.instance.userProfile?.data?.countryID, age: AppInstance.instance.userProfile?.data?.age, about: AppInstance.instance.userProfile?.data?.about, google: AppInstance.instance.userProfile?.data?.google, facebook: AppInstance.instance.userProfile?.data?.facebook, twitter: AppInstance.instance.userProfile?.data?.twitter, instagram: AppInstance.instance.userProfile?.data?.instagram, active: AppInstance.instance.userProfile?.data?.active, admin: AppInstance.instance.userProfile?.data?.admin, verified: AppInstance.instance.userProfile?.data?.verified, lastActive: AppInstance.instance.userProfile?.data?.lastActive, registered: AppInstance.instance.userProfile?.data?.registered, isPro: AppInstance.instance.userProfile?.data?.isPro, imports: AppInstance.instance.userProfile?.data?.imports, uploads: AppInstance.instance.userProfile?.data?.uploads, wallet: AppInstance.instance.userProfile?.data?.wallet, balance: AppInstance.instance.userProfile?.data?.balance, videoMon: AppInstance.instance.userProfile?.data?.videoMon, ageChanged: AppInstance.instance.userProfile?.data?.ageChanged, donationPaypalEmail: AppInstance.instance.userProfile?.data?.donationPaypalEmail, userUploadLimit: AppInstance.instance.userProfile?.data?.userUploadLimit, twoFactor: AppInstance.instance.userProfile?.data?.twoFactor, lastMonth: AppInstance.instance.userProfile?.data?.lastName, activeTime: AppInstance.instance.userProfile?.data?.activeTime, activeExpire: AppInstance.instance.userProfile?.data?.activeExpire, phoneNumber: AppInstance.instance.userProfile?.data?.phoneNumber, address: AppInstance.instance.userProfile?.data?.address, city: AppInstance.instance.userProfile?.data?.city, state: AppInstance.instance.userProfile?.data?.state, zip: AppInstance.instance.userProfile?.data?.zip, subscriberPrice: AppInstance.instance.userProfile?.data?.subscriberPrice, monetization: AppInstance.instance.userProfile?.data?.monetization, newEmail: AppInstance.instance.userProfile?.data?.newEmail, favCategory: AppInstance.instance.userProfile?.data?.favCategory, totalAds: AppInstance.instance.userProfile?.data?.totalAds, suspendUpload: AppInstance.instance.userProfile?.data?.suspendUpload, suspendImport: AppInstance.instance.userProfile?.data?.suspendImport, paystackRef: AppInstance.instance.userProfile?.data?.paystackRef, conversationID: AppInstance.instance.userProfile?.data?.conversationID, pointDayExpire: AppInstance.instance.userProfile?.data?.pointDayExpire, points: AppInstance.instance.userProfile?.data?.points, dailyPoints: AppInstance.instance.userProfile?.data?.dailyPoints, name: AppInstance.instance.userProfile?.data?.name, exCover: AppInstance.instance.userProfile?.data?.exCover, url: AppInstance.instance.userProfile?.data?.url, aboutDecoded: AppInstance.instance.userProfile?.data?.aboutDecoded, fullCover: AppInstance.instance.userProfile?.data?.fullCover, balanceOr: AppInstance.instance.userProfile?.data?.balanceOr, nameV: AppInstance.instance.userProfile?.data?.nameV, countryName: AppInstance.instance.userProfile?.data?.countryName, genderText: AppInstance.instance.userProfile?.data?.genderText, amISubscribed: AppInstance.instance.userProfile?.data?.amISubscribed, subscribeCount: AppInstance.instance.userProfile?.data?.subscribeCount, isSubscribedToChannel: AppInstance.instance.userProfile?.data?.isSubscribedToChannel), textTime: "")
                                 //                                    ["id":success?.id ?? 0,"text":self.commentTextTextField.text] as [String : Any]
                                 self.commentsArray.insert(data, at: 0)*/
                                self.commentTextTextField.text  = ""
                                self.commentTextTextField.resignFirstResponder()
                                self.tableView.reloadData()
                                log.verbose("success \(success?.message ?? "") ")
                                
                            }
                            //                            self.fetchComments()
                        })
                    }else if sessionError != nil{
                        self.dismissProgressDialog {
                            log.verbose("sessionError = \(sessionError?.errors.error_text ?? "")")
                            self.view.makeToast(sessionError?.errors.error_text ?? "")
                        }
                        
                    }else{
                        self.dismissProgressDialog {
                            log.verbose("error = \(error?.localizedDescription ?? "")")
                            self.view.makeToast(error?.localizedDescription ?? "")
                        }
                    }
                })
            })
            
        } else {
            self.view.makeToast(InterNetError)
        }
    }
    
}

// MARK: TableView Setup
extension PlayerCommentVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isLoading {
            return 10
        } else {
            if self.isEmpty == 1 {
                return 1
            } else {
                return self.commentsArray.count
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isLoading {
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.articlesSectionFiveTableItem.identifier) as? ArticlesSectionFiveTableItem
            return cell!
        } else {
            if self.commentsArray.isEmpty {
                let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.articlesSectionSixTableItem.identifier) as? ArticlesSectionSixTableItem
                return cell!
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.articlesSectionFiveTableItem.identifier) as? ArticlesSectionFiveTableItem
                cell!.playerCommentVC = self
                let object = self.commentsArray[indexPath.row]
                cell?.bind(nil, playerCommentData: object, articleData: nil)
                return cell!
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.setTemplateWithSubviews(isLoading, animate: true, viewBackgroundColor: .systemBackground)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.commentsArray.isEmpty {
            return 360.0
        } else {
            return UITableView.automaticDimension
        }
    }
    
}
