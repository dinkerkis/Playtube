import UIKit
import AVKit
import Async
import PlaytubeSDK
import Toast_Swift

class SettingVC: BaseVC {
    
    @IBOutlet weak var tableView: UITableView!
    var pause_history = 0
    var picture_In_Picture = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.title = NSLocalizedString("Settings", comment: "Settings")
        self.setupUI()
    }
    
    @IBAction func btnBack(_ sender: Any) {
        self.view.endEditing(true)
        self.navigationController?.popViewController(animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    private func setupUI(){
        self.tableView.separatorStyle = .none
        tableView.register(UINib(resource: R.nib.settingOneTableItem), forCellReuseIdentifier: R.reuseIdentifier.settingOneTableItem.identifier)
        tableView.register(UINib(resource: R.nib.settingThreeTableItem), forCellReuseIdentifier: R.reuseIdentifier.settingThreeTableItem.identifier)
        self.picture_In_Picture = UserDefaults.standard.getPictureInPicture(Key: Local.GET_SETTINGS.picture_In_Picture)
        self.getPauseHistory()        
    }
    
    func getPauseHistory() {
        AppInstance.instance.fetchUserProfile { success in
            if success {
                self.pause_history = AppInstance.instance.userProfile?.data?.pause_history ?? 0
                self.tableView.reloadData()
            }
        }
    }
    
    private func clearWatchHistory() {
        if Connectivity.isConnectedToNetwork(){
            self.showProgressDialog(text: NSLocalizedString("Loading...", comment: "Loading..."))
            let userID = AppInstance.instance.userId ?? 0
            let sessionID = AppInstance.instance.sessionId ?? ""
            Async.background({
                MyChannelManager.instance.clearWatchHistory(User_id: userID, Session_Token: sessionID, completionBlock: { (success, sessionError, error) in
                    if success != nil{
                        Async.main({
                            self.dismissProgressDialog {
                                log.verbose("SUCCESS = \(success?.message ?? "")")
                            }
                        })
                    }else if sessionError != nil{
                        self.dismissProgressDialog {
                            self.view.makeToast(sessionError?.errors.error_text ?? "")
                            log.verbose("SessionError = \(sessionError?.errors.error_text ?? "")")
                        }
                        
                    }else{
                        self.dismissProgressDialog {
                            self.view.makeToast(error?.localizedDescription ?? "")
                            log.verbose("error = \(error?.localizedDescription ?? "")")
                            
                        }
                    }
                })
            })
        }else{
            self.view.makeToast(InterNetError)
        }
    }
    
    private func updatePauseWatchHistory() {
        if Connectivity.isConnectedToNetwork() {
            self.showProgressDialog(text: NSLocalizedString("Loading...", comment: "Loading..."))
            GetSettingsManager.instance.updatePauseWatchHistory() { (success, authError, error) in
                if (success != nil) {
                    self.dismissProgressDialog {
                        print(success?.message ?? "")
                        self.view.makeToast(success?.message ?? "")
                        self.getPauseHistory()
                    }
                } else if (authError != nil) {
                    self.dismissProgressDialog {
                        self.view.makeToast(authError?.errors?.error_text ?? "")
                    }
                } else {
                    self.dismissProgressDialog {
                        self.view.makeToast(error?.localizedDescription ?? "")
                    }
                }
            }
        } else {
            self.view.makeToast(InterNetError)
        }
    }
        
}

extension SettingVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                let vc = R.storyboard.settings.editChannelVC()
                vc?.is_Setting = 1
                self.navigationController?.pushViewController(vc!, animated: true)
            }
            
            else if indexPath.row == 1 {
                let vc = R.storyboard.settings.withdrawalsVC()
                self.navigationController?.pushViewController(vc!, animated: true)
            }
//            else if indexPath.row == 2 {
//                let vc = R.storyboard.upgrade.upgradeVC()
//                self.navigationController?.pushViewController(vc!, animated: true)
//            }
            else if indexPath.row == 2 {
                if AppInstance.instance.userProfile?.data?.verified == 0{
                    let vc = R.storyboard.settings.verificationVC()
                    self.navigationController?.pushViewController(vc!, animated: true)
                }else{
                    let vc = R.storyboard.settings.verifiedVC()
                    self.navigationController?.pushViewController(vc!, animated: true)
                }
            }
//            else if indexPath.row == 4 {
//                let Storyboards = UIStoryboard(name: "Settings", bundle: nil)
//                let vc = Storyboards.instantiateViewController(withIdentifier: "PointsVC") as! PointsVC
//                self.navigationController?.pushViewController(vc, animated: true)
//            }
            else if indexPath.row == 3 {
                let vc = R.storyboard.settings.blockedUsersVC()
                self.navigationController?.pushViewController(vc!, animated: true)
            }
//            else if indexPath.row == 6 {
//                let Storyboards = UIStoryboard(name: "Settings", bundle: nil)
//                let vc = Storyboards.instantiateViewController(withIdentifier: "WalletVC") as! WalletVC
//                self.navigationController?.pushViewController(vc, animated: true)
//            }
            else if indexPath.row == 4 {
                let Storyboards = UIStoryboard(name: "Settings", bundle: nil)
                let vc = Storyboards.instantiateViewController(withIdentifier: "LinkTvVC") as! LinkTvVC
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }else if indexPath.section == 1{
            switch indexPath.row {
            case 0:
                let vc = R.storyboard.settings.changePasswordVC()
                self.navigationController?.pushViewController(vc!, animated: true)
                //            case 1:
                //                let vc = R.storyboard.settings.twoFactorController()
                //                self.navigationController?.pushViewController(vc!, animated: true)
                //                print("Two Factor")
            case 1:
                let vc = R.storyboard.settings.manageSessionVC()
                self.navigationController?.pushViewController(vc!, animated: true)
                
            default:
                break
            }
        }
//        } else if indexPath.section == 2 {
//            if indexPath.row == 0 {
//                let newVC = R.storyboard.popups.themeOptionPopupVC()
//                newVC?.modalPresentationStyle = .custom
//                newVC?.transitioningDelegate = self
//                newVC?.sheetHeight = 220
//                self.present(newVC!, animated: true)
//            }
//        }
        else if indexPath.section == 3 {
            switch indexPath.row {
            case 0:
                self.clearWatchHistory()
            case 1:
                break
            case 2:
                let newVC = R.storyboard.popups.clearCachesPopupVC()
                newVC?.modalPresentationStyle = .custom
                newVC?.transitioningDelegate = self
                self.present(newVC!, animated: true)
            default:
                break
            }
        }
        else if indexPath.section == 4{
            switch indexPath.row {
            case 0:
                // let helpURL = URL(string: "\(API.baseURL)/terms/privacy-policy")
                // UIApplication.shared.openURL(helpURL!)
                print("Rate our App")
                self.view.makeToast("Coming Soon....")
            case 1:
                print("Invite Friends")
                let vc = R.storyboard.settings.phoneContactsVC()
                self.navigationController?.pushViewController(vc!, animated: true)
            case 2:
                let newVC = R.storyboard.settings.settingsWebViewVC()
                newVC?.headerText = "About"
                self.navigationController?.pushViewController(newVC!, animated: true)
            case 3:
                let newVC = R.storyboard.settings.settingsWebViewVC()
                newVC?.headerText = "Terms of use"
                self.navigationController?.pushViewController(newVC!, animated: true)
            case 4:
                let newVC = R.storyboard.settings.settingsWebViewVC()
                newVC?.headerText = "Privacy Policy"
                self.navigationController?.pushViewController(newVC!, animated: true)
            case 5:
                let newVC = R.storyboard.settings.settingsWebViewVC()
                newVC?.headerText = "Help"
                self.navigationController?.pushViewController(newVC!, animated: true)
            default:
                break
            }
        }
        else if indexPath.section == 5{
            switch indexPath.row {
            case 0:
                let vc = R.storyboard.settings.deleteAccountVC()
                self.navigationController?.pushViewController(vc!, animated: true)
            case 1:
                let newVC = R.storyboard.popups.logoutPopupVC()
                newVC?.parentVC = self
                newVC?.modalPresentationStyle = .custom
                newVC?.transitioningDelegate = self
                self.present(newVC!, animated: true)
            default:
                break
            }
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section != 0 {
            let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 20))
            view.backgroundColor = UIColor.bgcolor1
            let separatorView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 1))
            separatorView.backgroundColor = UIColor.bgcolor2
            view.addSubview(separatorView)
            return view
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0
        }
        return 20
    }
}

extension SettingVC: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 6
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 5
        case 1:
            return 2
        case 2:
            return 1
        case 3:
            return 3
        case 4:
            return 6
        case 5:
            return 2
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.settingOneTableItem.identifier) as! SettingOneTableItem
                cell.titleLabel.text = NSLocalizedString("Edit My Channel", comment: "Edit My Channel")
                cell.titleLabel.textColor = .black
                cell.imgLeft.image = UIImage(named: "s_edit")
                return cell
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.settingOneTableItem.identifier) as! SettingOneTableItem
                cell.titleLabel.text = NSLocalizedString("Withdrawals", comment: "Withdrawals")
                cell.titleLabel.textColor = .black
                cell.imgLeft.image = UIImage(named: "s_withdrawal")
                return cell
//            case 2:
//                let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.settingOneTableItem.identifier) as! SettingOneTableItem
//                cell.titleLabel.text = NSLocalizedString("Go Pro", comment: "Go Pro")
//                cell.titleLabel.textColor = UIColor(red: 248/255, green: 171/255, blue: 23/255, alpha: 1)
//                cell.imgLeft.image = UIImage(named: "s_pro")
//                return cell
            case 2:
                let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.settingOneTableItem.identifier) as! SettingOneTableItem
                cell.titleLabel.text = NSLocalizedString("Verification", comment: "Verification")
                cell.titleLabel.textColor = .black
                cell.imgLeft.image = UIImage(named: "s_verification")
                return cell
//            case 4:
//                let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.settingOneTableItem.identifier) as! SettingOneTableItem
//                cell.titleLabel.text = "Points"
//                cell.titleLabel.textColor = .black
//                cell.imgLeft.image = UIImage(named: "points_new")
//                return cell
            case 3:
                let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.settingOneTableItem.identifier) as! SettingOneTableItem
                cell.titleLabel.text = NSLocalizedString("Blocked Users", comment: "Blocked Users")
                cell.titleLabel.textColor = .black
                cell.imgLeft.image = UIImage(named: "s_block")
                return cell
//            case 6:
//                let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.settingOneTableItem.identifier) as! SettingOneTableItem
//                cell.titleLabel.text = "Wallet"
//                cell.titleLabel.textColor = .black
//                cell.imgLeft.image = UIImage(named: "wallet_new")
//                return cell
            case 4:
                let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.settingOneTableItem.identifier) as! SettingOneTableItem
                cell.titleLabel.text = "Link with TV code"
                cell.titleLabel.textColor = .black
                cell.imgLeft.image = UIImage(named: "tv_new")
                return cell
            default:
                return UITableViewCell()
            }
        case 1:
            switch indexPath.row{
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.settingOneTableItem.identifier) as! SettingOneTableItem
                cell.titleLabel.text = NSLocalizedString("Password", comment: "Password")
                cell.titleLabel.textColor = .black
                cell.imgLeft.image = UIImage(named: "s_password")
                return cell
//            case 1:
//                let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.settingOneTableItem.identifier) as! SettingOneTableItem
//                cell.titleLabel.text = NSLocalizedString("Two Factor Authentication", comment: "Two Factor")
//                cell.titleLabel.textColor = .black
//                cell.imgLeft.image = UIImage(named: "s_two")
//                return cell
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.settingOneTableItem.identifier) as! SettingOneTableItem
                cell.titleLabel.text = NSLocalizedString("Manage Sessions", comment: "Manage Sessions")
                cell.titleLabel.textColor = .black
                cell.imgLeft.image = UIImage(named: "s_manage")
                return cell
            default:
                return UITableViewCell()
            }
        case 2:
            switch indexPath.row {
//            case 0:
//                let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.settingOneTableItem.identifier) as! SettingOneTableItem
//                cell.titleLabel.text = "Theme"//NSLocalizedString("Theme", comment: "Theme")
//                cell.titleLabel.textColor = .black
//                cell.imgLeft.image = UIImage(named: "s_theme")
//                return cell
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.settingThreeTableItem.identifier) as! SettingThreeTableItem
                cell.titleLabel.text = "Picture in picture"
                cell.pictureInPictureDelegate = self
                cell.type = "picture_in_picture"
                cell.titleLabel.textColor = .black
                cell.imgLeft.image = UIImage(named: "s_pip")
                cell.`switch`.isOn = self.picture_In_Picture
                return cell
            default:
                return UITableViewCell()
            }
        case 3:
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.settingOneTableItem.identifier) as! SettingOneTableItem
                cell.titleLabel.text = NSLocalizedString("Clear", comment: "Clear")
                cell.titleLabel.textColor = .black
                cell.imgLeft.image = UIImage(named: "s_history")
                return cell
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.settingThreeTableItem.identifier) as! SettingThreeTableItem
                cell.titleLabel.text = "Pause watch history"
                cell.pauseHistoryDelegate = self
                cell.type = "pause_history"
                cell.titleLabel.textColor = .black
                cell.imgLeft.image = UIImage(named: "s_pause_history")
                cell.`switch`.isOn = self.pause_history == 1
                return cell
            case 2:
                let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.settingOneTableItem.identifier) as! SettingOneTableItem
                cell.titleLabel.text = NSLocalizedString("Clear Cache", comment: "Clear Cache")
                cell.titleLabel.textColor = .black
                cell.imgLeft.image = UIImage(named: "s_cache")
                return cell
            default:
                return UITableViewCell()
            }
        case 4:
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.settingOneTableItem.identifier) as! SettingOneTableItem
                cell.titleLabel.text =  "Rate our App"
                cell.titleLabel.textColor = .black
                cell.imgLeft.image = UIImage(named: "s_rate")
                return cell
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.settingOneTableItem.identifier) as! SettingOneTableItem
                cell.titleLabel.text =  "Invite Friends"
                cell.titleLabel.textColor = .black
                cell.imgLeft.image = UIImage(named: "s_invite")
                return cell
            case 2:
                let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.settingOneTableItem.identifier) as! SettingOneTableItem
                cell.titleLabel.text = NSLocalizedString("About us", comment: "About us")
                cell.titleLabel.textColor = .black
                cell.imgLeft.image = UIImage(named: "s_about")
                return cell
            case 3:
                let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.settingOneTableItem.identifier) as! SettingOneTableItem
                cell.titleLabel.text = "Terms of use"
                cell.titleLabel.textColor = .black
                cell.imgLeft.image = UIImage(named: "s_terms")
                return cell
            case 4:
                let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.settingOneTableItem.identifier) as! SettingOneTableItem
                cell.titleLabel.text = "Privacy Policy"
                cell.titleLabel.textColor = .black
                cell.imgLeft.image = UIImage(named: "s_terms")
                return cell
            case 5:
                let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.settingOneTableItem.identifier) as! SettingOneTableItem
                cell.titleLabel.text =  NSLocalizedString("Help", comment: "Help")
                cell.titleLabel.textColor = .black
                cell.imgLeft.image = UIImage(named: "s_help")
                return cell
            default:
                return UITableViewCell()
            }
        case 5:
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.settingOneTableItem.identifier) as! SettingOneTableItem
                cell.titleLabel.text = NSLocalizedString("Delete Account", comment: "Delete Account")
                cell.titleLabel.textColor = .black
                cell.imgLeft.image = UIImage(named: "s_delete")
                return cell
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.settingOneTableItem.identifier) as! SettingOneTableItem
                cell.titleLabel.text = NSLocalizedString("Logout", comment: "Logout")
                cell.titleLabel.textColor = .black
                cell.imgLeft.image = UIImage(named: "s_logout")
                return cell
            default:
                return UITableViewCell()
            }
        default:
            return UITableViewCell()
        }
    }
    
}

// MARK: UIViewControllerTransitioningDelegate Methods
extension SettingVC: UIViewControllerTransitioningDelegate {
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        BottomSheetPresentationController(presentedViewController: presented, presenting: presenting)
    }
    
}

// MARK: PauseHistoryDelegate Methods
extension SettingVC: PauseHistoryDelegate {
    
    func handlePauseHistorySwitchTap(_ sender: UISwitch) {
        self.updatePauseWatchHistory()
    }
    
}

// MARK: PictureInPictureDelegate Methods
extension SettingVC: PictureInPictureDelegate {
    
    func handlePictureInPictureSwitchTap(_ sender: UISwitch) {
        if AVPictureInPictureController.isPictureInPictureSupported() {
            self.picture_In_Picture = !self.picture_In_Picture
            UserDefaults.standard.setPictureInPicture(value: self.picture_In_Picture, ForKey: Local.GET_SETTINGS.picture_In_Picture)
            self.picture_In_Picture = UserDefaults.standard.getPictureInPicture(Key: Local.GET_SETTINGS.picture_In_Picture)
        } else {
            self.view.makeToast("Picture In Picture is not supported on this device")
            UserDefaults.standard.setPictureInPicture(value: AVPictureInPictureController.isPictureInPictureSupported(), ForKey: Local.GET_SETTINGS.picture_In_Picture)
            self.picture_In_Picture = UserDefaults.standard.getPictureInPicture(Key: Local.GET_SETTINGS.picture_In_Picture)
        }
        self.tableView.reloadData()
    }
    
}
