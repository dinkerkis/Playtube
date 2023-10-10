
import UIKit
import PlaytubeSDK
import GoogleMobileAds
import Async
class NotificationVC: BaseVC {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var showStack: UIStackView!
    //@IBOutlet weak var noNotification: UILabel!
    var interstitial: GADInterstitialAd!
    private var notificationsArray = [NotificationsModel.Notification]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.getNotification()
    }
    
    @IBAction func btnBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    private func setupUI(){
        //self.title = NSLocalizedString("Notification", comment: "Notification")
        //self.noNotification.text = NSLocalizedString("No Notification!", comment: "No Notification!")
        if AppSettings.shouldShowAddMobBanner{
            let request = GADRequest()
            GADInterstitialAd.load(withAdUnitID: AppSettings.interestialAddUnitId,
                                   request: request,
                                   completionHandler: { (ad, error) in
                if let error = error {
                    print("Failed to load interstitial ad with error: \(error.localizedDescription)")
                    return
                }
                self.interstitial = ad
            }
            )
        }
        
        self.tableView.separatorStyle = .none
        tableView.register(UINib(resource: R.nib.notificationTableItem), forCellReuseIdentifier: R.reuseIdentifier.notificationTableItem.identifier)
    }
    func CreateAd() -> GADInterstitialAd {
        GADInterstitialAd.load(withAdUnitID: AppSettings.interestialAddUnitId,
                               request: GADRequest(),
                               completionHandler: { (ad, error) in
            if let error = error {
                print("Failed to load interstitial ad with error: \(error.localizedDescription)")
                return
            }
            self.interstitial = ad
        }
        )
        return  self.interstitial
    }
    private func getNotification(){
        if Connectivity.isConnectedToNetwork(){
            //self.showProgressDialog(text: NSLocalizedString("Loading...", comment: "Loading..."))
            let userID = AppInstance.instance.userId ?? 0
            let sessionID = AppInstance.instance.sessionId ?? ""
            Async.background({
                NotificationsManager.instance.getNotifications(User_id: userID, Session_Token: sessionID, completionBlock: { (success, sessionError, error) in
                    if success != nil{
                        Async.main({
                            self.dismissProgressDialog {
                                log.debug("success")
                                self.notificationsArray = (success?.notifications)!
                                if !self.notificationsArray.isEmpty{
                                    self.tableView.reloadData()
                                    self.showStack.isHidden = true
                                    self.tableView.isHidden = false
                                }else{
                                    self.showStack.isHidden = false
                                    self.tableView.isHidden = true
                                }
                            }
                        })
                    }else if sessionError != nil{
                        Async.main({
                            self.dismissProgressDialog {
                                log.debug("sessionError = \(sessionError?.errors!.error_text)")
                                self.view.makeToast(sessionError?.errors!.error_text)
                            }
                        })
                    }else{
                        Async.main({
                            self.dismissProgressDialog {
                                log.debug("error = \(error?.localizedDescription)")
                                self.view.makeToast(error?.localizedDescription)
                            }
                        })
                    }
                })
            })
            
        }else {
            self.view.makeToast(InterNetError)
        }
    }
}

extension NotificationVC:UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.notificationsArray.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:R.reuseIdentifier.notificationTableItem.identifier) as! NotificationTableItem
        let object = self.notificationsArray[indexPath.row]
        cell.bind(object)
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let notificationObject = self.notificationsArray[indexPath.row]
        if (notificationObject.title?.contains("added"))! || (notificationObject.title?.contains("disliked"))! || (notificationObject.title?.contains("liked"))! || (notificationObject.title?.contains("commented"))! || (notificationObject.title?.contains("commented"))! {
            if AppInstance.instance.addCount == AppSettings.interestialCount {
                interstitial.present(fromRootViewController: self)
                interstitial = CreateAd()
                AppInstance.instance.addCount = 0
            }
            AppInstance.instance.addCount = AppInstance.instance.addCount! + 1
            if let videoObject = self.notificationsArray[indexPath.row].video?.videoClass {
                let newVC = self.tabBarController as! TabbarController
                // newVC.statusBarHiddenDelegate = self
                newVC.handleOpenVideoPlayer(for: videoObject)
            } else {
                let vc = R.storyboard.library.newUserChannelVC()
                vc?.channelData = self.notificationsArray[indexPath.row].userData
                self.navigationController?.pushViewController(vc!, animated: true)
            }
        } else {
            //            if AppInstance.instance.addCount == AppSettings.interestialCount {
            //                if interstitial.isReady {
            //                    interstitial.present(fromRootViewController: self)
            //                    interstitial = CreateAd()
            //                    AppInstance.instance.addCount = 0
            //                } else {
            //
            //                    print("Ad wasn't ready")
            //                }
            //            }
            
            let vc = R.storyboard.library.newUserChannelVC()
            vc?.channelData = self.notificationsArray[indexPath.row].userData
            self.navigationController?.pushViewController(vc!, animated: true)
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80.0
        //            UITableView.automaticDimension
        
    }
}
