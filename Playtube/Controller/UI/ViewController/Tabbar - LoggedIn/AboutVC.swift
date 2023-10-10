import UIKit
import Async
import PlaytubeSDK

class AboutVC: BaseVC {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var lblGender: UILabel!
    @IBOutlet weak var lblEmail: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var lblBlock: UILabel!
    @IBOutlet weak var facebookView: UIView!
    @IBOutlet weak var instagramView: UIView!
    @IBOutlet weak var twitterView: UIView!
    @IBOutlet weak var blockUserView: UIView!
    
    // MARK: - Properties
    
    var channelID: Int? = 0
    var channelData: Owner?
    var parentVC: BaseVC?
    
    // MARK: - View Life Cycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupData()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            print("contentSize :- ", (self.view.subviews.first as! UIScrollView).contentSize)
//            NotificationCenter.default.post(name: NSNotification.Name("ReloadContainerView"), object: nil)
        }
        
        //self.setupUI()
        NotificationCenter.default.addObserver(self, selector: #selector(self.video_Upload(notification:)), name: Notification.Name("VideoUploded"), object: nil)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print(#function)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print(#function)
        NotificationCenter.default.post(name: NSNotification.Name("ReloadContainerView"), object: nil)
    }
    
    @objc func video_Upload(notification: NSNotification){
//        let parentViewController = self.parent as! UserVC
//        parentViewController.moveToViewController(at: 0)
    }
    
    @IBAction func facebookButtonAction(_ sender: UIButton) {
        self.view.endEditing(true)
        if let urlSTR = self.channelData?.facebook {
            if urlSTR.localizedCaseInsensitiveContains("http"),
               let url = URL(string: urlSTR) {
                UIApplication.shared.open(url)
            }else {
                if let url = URL(string: "https://www.facebook.com/\(urlSTR)"){
                    UIApplication.shared.open(url)
                }
            }
        }
    }
    
    @IBAction func instagramButtonAction(_ sender: UIButton) {
        self.view.endEditing(true)
        if let urlSTR = self.channelData?.instagram,
           let url = URL(string: "instagram://user?username=\(urlSTR)") {
            let application = UIApplication.shared
            if application.canOpenURL(url) {
                application.open(url)
            } else {
                // if Instagram app is not installed, open URL inside Safari
                if let webURL = URL(string: "https://instagram.com/\(urlSTR)") {
                    application.open(webURL)
                }
            }
        }
    }
    
    @IBAction func twitterButtonAction(_ sender: UIButton) {
        self.view.endEditing(true)
        if let urlSTR = self.channelData?.twitter,
           let url = URL(string: "https://twitter.com/\(urlSTR)") {
            UIApplication.shared.open(url)
        }
    }
    
    @IBAction func blockButtonAction(_ sender: UIButton) {
        self.view.endEditing(true)
        blockUser()
    }
    
    static func aboutVC() -> AboutVC {
        let newVC = R.storyboard.loggedUser.aboutVC()
        return newVC!
    }
    
    func setupData() {
        self.blockUserView.isHidden =  AppInstance.instance.userId == channelID
        if channelID == 0 {
            self.lblGender.text = AppInstance.instance.userProfile?.data?.gender_text ?? "----"
            self.lblEmail.text = AppInstance.instance.userProfile?.data?.email ?? "----"
            if AppInstance.instance.userProfile?.data?.about == "" {
                self.lblDescription.text = "Has not any info"
            }else {
                self.lblDescription.text = channelData?.about ?? "Has not any info"
            }
            self.facebookView.isHidden = (AppInstance.instance.userProfile?.data?.facebook == "" || AppInstance.instance.userProfile?.data?.facebook == nil)
            self.twitterView.isHidden = (AppInstance.instance.userProfile?.data?.twitter == "" || AppInstance.instance.userProfile?.data?.twitter == nil)
            self.instagramView.isHidden = (AppInstance.instance.userProfile?.data?.instagram == "" || AppInstance.instance.userProfile?.data?.instagram == nil)
            self.lblBlock.text = "Block " + (AppInstance.instance.userProfile?.data?.name ?? "")
        }else{
            if self.channelData != nil {
                self.lblGender.text = channelData?.gender ?? "----"
                if channelData?.about == "" {
                    self.lblDescription.text = "Has not any info"
                }else {
                    self.lblDescription.text = channelData?.about ?? "Has not any info"
                }
                self.lblEmail.text = channelData?.email ?? "----"
                self.facebookView.isHidden = (channelData?.facebook == "" || channelData?.facebook == nil)
                self.twitterView.isHidden = (channelData?.twitter == "" || channelData?.twitter == nil)
                self.instagramView.isHidden = (channelData?.instagram == "" || channelData?.instagram == nil)
                self.lblBlock.text = "Block " + "“\(channelData?.name ?? "")”"
            }
        }
    }
    
    private func blockUser() {
        if Connectivity.isConnectedToNetwork(){
            parentVC?.showProgressDialog(text: NSLocalizedString("Loading...", comment: "Loading..."))
            let userID = AppInstance.instance.userId ?? 0
            let sessionID = AppInstance.instance.sessionId ?? ""
            let blockId = self.channelID ?? 0
            Async.background({
                BlockedUserManager.instance.blockUnBlockUser(User_id: userID, Session_Token: sessionID, type: "block", blockId: blockId, completionBlock: { (success, sessionError, error) in
                    if success != nil{
                        Async.main({
                            self.parentVC?.dismissProgressDialog {
                                log.verbose("SUCCESS")
                                NotificationCenter.default.post(name: NSNotification.Name("reloadPopularChannelData"), object: nil)
                                self.parentVC?.navigationController?.popViewController(animated: true)
                            }
                        })
                    }else if sessionError != nil{
                        self.parentVC?.dismissProgressDialog {
                            self.parentVC?.view.makeToast(sessionError?.errors!.error_text)
                            log.verbose("SessionError = \(sessionError?.errors!.error_text)")
                        }
                        
                    }else{
                        self.parentVC?.dismissProgressDialog {
                            self.parentVC?.view.makeToast(error?.localizedDescription)
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
