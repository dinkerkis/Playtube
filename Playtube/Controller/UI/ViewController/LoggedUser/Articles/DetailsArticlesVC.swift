import UIKit
import Async
import PlaytubeSDK

class DetailsArticlesVC: BaseVC {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var lblTitle: UILabel!
    
    var articlesData: Article?
    var articleCommentArray: [Comment] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.fetchArticlesComment()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    private func setupUI() {
        
        self.lblTitle.text = articlesData?.title?.htmlAttributedString
        self.tableView.separatorStyle = .none
        
        tableView.register(UINib(resource: R.nib.articleSectionOneTableItem), forCellReuseIdentifier: R.reuseIdentifier.articleSectionOneTableItem.identifier)
        
        /*tableView.register(R.nib.articlesSectionTwoTableItem(), forCellReuseIdentifier: R.reuseIdentifier.articlesSectionTwoTableItem.identifier)
        
        tableView.register(R.nib.articlesSectionThreeTableItem(), forCellReuseIdentifier: R.reuseIdentifier.articlesSectionThreeTableItem.identifier)
        
        tableView.register(R.nib.articlesSectionFourTableItem(), forCellReuseIdentifier: R.reuseIdentifier.articlesSectionFourTableItem.identifier)*/
        
        tableView.register(UINib(resource: R.nib.articlesSectionFiveTableItem), forCellReuseIdentifier: R.reuseIdentifier.articlesSectionFiveTableItem.identifier)
        
        tableView.register(UINib(resource: R.nib.articlesSectionSixTableItem), forCellReuseIdentifier: R.reuseIdentifier.articlesSectionSixTableItem.identifier)
        
        tableView.register(UINib(resource: R.nib.articlesSectionSevenTableItem), forCellReuseIdentifier: R.reuseIdentifier.articlesSectionSevenTableItem.identifier)
        tableView.register(UINib(resource: R.nib.articleFooterView), forHeaderFooterViewReuseIdentifier: "ArticleFooterView")
        log.verbose("Message = \(self.articlesData?.id ?? 0)")
    }
    
    @IBAction func btnBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnCopy(_ sender: Any) {
        UIPasteboard.general.string = self.articlesData?.url ?? ""
        let content = UIPasteboard.general.string
        self.view.makeToast(NSLocalizedString("Copy to clipboard", comment: "Copy to clipboard"))
    }
    
    @IBAction func btnShare(_ sender: Any) {
        self.shareVideo(stringURL: self.articlesData?.url ?? "")
    }
    
    func shareVideo(stringURL: String) {
        let someText:String = self.articlesData?.url ?? ""
        let objectsToShare:URL = URL(string: stringURL)!
        let sharedObjects:[AnyObject] = [objectsToShare as AnyObject,someText as AnyObject]
        let activityViewController = UIActivityViewController(activityItems : sharedObjects, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        
        activityViewController.excludedActivityTypes = [ UIActivity.ActivityType.airDrop, UIActivity.ActivityType.postToFacebook,UIActivity.ActivityType.postToTwitter,UIActivity.ActivityType.mail,UIActivity.ActivityType.postToTencentWeibo]
        
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    func fetchArticlesComment() {
        self.articleCommentArray.removeAll()
        //self.showProgressDialog(text: NSLocalizedString("Loading...", comment: "Loading..."))
        Async.background {
            let userID = AppInstance.instance.userId ?? 0
            let sessionID = AppInstance.instance.sessionId ?? ""
            let postID = self.articlesData?.id ?? 0
            ArticlesManager.instance.getArticlesComments(User_id: userID, Session_Token: sessionID, Limit: 10, Post_id: postID, completionBlock: { (success, sessionError, error) in
                if success != nil {
                    self.dismissProgressDialog {
                        Async.main {
                            self.articleCommentArray = success?.data ?? []
                            self.tableView.reloadData()
                        }
                    }
                } else if sessionError != nil {
                    self.dismissProgressDialog {
                        Async.main {
                            log.verbose("sessionError = \(sessionError?.errors?.error_text ?? "")")
                            self.view.makeToast(sessionError?.errors?.error_text ?? "")
                        }
                    }
                } else {
                    self.dismissProgressDialog {
                        Async.main {
                            log.verbose("error = \(error?.localizedDescription ?? "")")
                            self.view.makeToast(error?.localizedDescription ?? "")
                        }
                    }
                }
            })
        }
    }
    
}

extension DetailsArticlesVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1 {
            if self.articleCommentArray.isEmpty {
                return 1
            } else {
                return self.articleCommentArray.count 
            }
        }
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.articleSectionOneTableItem.identifier) as? ArticleSectionOneTableItem
            cell?.bind(self.articlesData!)
            return cell!
        case 1:
            if self.articleCommentArray.isEmpty {
                let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.articlesSectionSixTableItem.identifier) as? ArticlesSectionSixTableItem
                return cell!
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.articlesSectionFiveTableItem.identifier) as? ArticlesSectionFiveTableItem
                cell!.vc = self
                let object = self.articleCommentArray[indexPath.row]
                cell?.bind(object, playerCommentData: nil, articleData: nil)
                return cell!
            }
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.articleSectionOneTableItem.identifier) as? ArticleSectionOneTableItem
            return cell!
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {            
        case 1:
            if self.articleCommentArray.isEmpty {
                return 360.0
            } else {
                return UITableView.automaticDimension
            }
        default:
            return UITableView.automaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == 1 {
            let footerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "ArticleFooterView") as! ArticleFooterView
            footerView.vc = self
            footerView.bind(self.articlesData!, playerCommentData: nil)
            return footerView
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 1 {
            return 60.0
        }
        return 0
    }
    
}
