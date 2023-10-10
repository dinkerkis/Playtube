

import UIKit
import Async
import PlaytubeSDK
import UIView_Shimmer

class blockTblCell : UITableViewCell, ShimmeringViewProtocol
{
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var subscriberLabel: UILabel!
    @IBOutlet weak var profileImage: RoundImage!
    @IBOutlet weak var btnSubscribe: UIButton!
    
    var object: Owner?
    var shimmeringAnimatedItems: [UIView] {
        [
            userName,
            subscriberLabel,
            profileImage,
            btnSubscribe
        ]
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    @IBAction func unblockButton(_ sender: UIButton) {
        let vc = R.storyboard.popups.unblockUserPopupVC()
        vc?.blockID = self.object?.id
        obj_appDelegate.window?.rootViewController?.present(vc!, animated: true, completion: nil)
    }
    
    func bind(_ object: Owner) {
        self.userName.text = object.username ?? ""
        let profileImage = URL(string: object.avatar ?? "")
        switch object.subscribe_count {
        case .integer(let value):
            self.subscriberLabel.text = "\(value) Subscribers"
        case .string(let value):
            self.subscriberLabel.text = "\(value) Subscribers"
        default:
            break
        }
        self.profileImage.sd_setShowActivityIndicatorView(true)
        self.profileImage.sd_setIndicatorStyle(.medium)
        self.profileImage.sd_setImage(with: profileImage, placeholderImage:R.image.maxresdefault())
    }
}

class BlockedUsersVC: BaseVC {
    
    //@IBOutlet weak var noDataLabel: UILabel!
    @IBOutlet weak var noDataImage: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    
    private var isLoading = true {
        didSet {
            //tableView.isUserInteractionEnabled = !isLoading
            tableView.reloadData()
        }
    }
    
    private var blockedUsers:GetBlockedUserModel.GetBlockedUserSuccessModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.tableFooterView = UIView()
        isLoading = true
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("reloadBlockUserData"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.reloadBlockUserData(_:)), name: NSNotification.Name("reloadBlockUserData"), object: nil)
        
        self.tableView.addPullRefresh { [weak self] in
            self?.isLoading = true
            self?.noDataImage.isHidden = true
//            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//                self?.isLoading = false
//                self?.tableView.stopPullRefreshEver()
//            }
            self?.fetchBlockedUsers()
        }
        
        self.fetchBlockedUsers()
    }
    
    @objc func reloadBlockUserData(_ notification: NotificationCenter) {
        self.fetchBlockedUsers()
    }
    
    
    @IBAction func btnBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    private func fetchBlockedUsers(){
        if Connectivity.isConnectedToNetwork(){
            let userID = AppInstance.instance.userId ?? 0
            let sessionID = AppInstance.instance.sessionId ?? ""
            Async.background({
                BlockedUserManager.instance.getBlockedUser(User_id: userID, Session_Token: sessionID, type: "get", completionBlock: { (success, sessionError, error) in
                    if success != nil{
                        Async.main({
                            log.verbose("SUCCESS")
                            self.blockedUsers =  success ?? nil
                            if !(self.blockedUsers?.users!.isEmpty)!{
                                self.noDataImage.isHidden = true
                                //self.noDataLabel.isHidden = true
                            }else{
                                self.noDataImage.isHidden = false
                                //self.noDataLabel.isHidden = false
                            }
                            self.isLoading = false
                            self.tableView.stopPullRefreshEver()
                        })
                    }else if sessionError != nil{
                        self.dismissProgressDialog {
                            self.view.makeToast(sessionError?.errors!.error_text)
                            log.verbose("SessionError = \(sessionError?.errors!.error_text)")
                        }
                        
                    }else{
                        self.dismissProgressDialog {
                            self.view.makeToast(error?.localizedDescription)
                            log.verbose("error = \(error?.localizedDescription ?? "")")

                        }
                    }
                })
            })
        }else{
            self.view.makeToast(InterNetError)
        }
    }
}
extension BlockedUsersVC:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isLoading
        {
            return 10
        }
        else{
            return self.blockedUsers?.users?.count ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isLoading
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "blockTblCell") as! blockTblCell
            return cell
        }
        else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "blockTblCell") as! blockTblCell
            let object = self.blockedUsers?.users![indexPath.row]
            cell.object = object
            cell.bind(object!)
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView,
                            willDisplay cell: UITableViewCell,
                            forRowAt indexPath: IndexPath) {
        cell.setTemplateWithSubviews(isLoading, animate: true, viewBackgroundColor: .systemBackground)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let vc = R.storyboard.popups.unblockUserPopupVC()
//        vc?.blockID = self.blockedUsers?.users?[indexPath.row].id ?? 0
//        self.present(vc!, animated: true, completion: nil)
    }
}
