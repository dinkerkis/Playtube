import UIKit
import PlaytubeSDK
import SDWebImage
import GoogleMobileAds
import Async
import Toast_Swift
import DropDown

struct Libraryitem {
    
    var iconImage:UIImage?
    var title:String?
    
}

class LibraryVC: BaseVC {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var tblViewHeightConst: NSLayoutConstraint!
    @IBOutlet weak var recentCollectionView: UICollectionView!
    @IBOutlet weak var playListTblView: UITableView!
    @IBOutlet weak var imgProfile: RoundImage!
    @IBOutlet weak var lblUsername: UILabel!
    @IBOutlet weak var lblSubscriptionsCount: UILabel!
    @IBOutlet weak var lblWatchLaterCount: UILabel!
    @IBOutlet weak var lblOfflineCount: UILabel!
    @IBOutlet weak var lblLikeCount: UILabel!
    @IBOutlet weak var lblPaidCount: UILabel!
    @IBOutlet weak var lblSharedCount: UILabel!
    @IBOutlet weak var lblPlaylistShort: UILabel!
    @IBOutlet weak var recentlyStackView: UIStackView!
    @IBOutlet weak var btnDropDown: UIButton!
    
    // MARK: - Properties
    
    private var isLoading = true {
        didSet {
            self.recentCollectionView.reloadData()
            self.playListTblView.reloadData()
        }
    }
    var recentlyWatchedArray: [VideoDetail] = []
    var playlistsArray = [PlaylistModel.MyAllPlaylist]()
    var interstitial: GADInterstitialAd!
    var dropDown = DropDown()
    var selectedDropDownItem = "Recently added"
    var isStatusBarHidden: Bool = false {
        didSet {
            if oldValue != self.isStatusBarHidden {
                self.setNeedsStatusBarAppearanceUpdate()
            }
        }
    }
    
    // MARK: - View Life Cycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initialConfig()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.isLoading = true
        self.fetchRecentlyWatched()
        self.myChannelPlayListfetchData()
        self.fetchSubscribedChannels()
        self.getLikedVideos()
        let watchLaterData =  UserDefaults.standard.getWatchLater(Key: Local.WATCH_LATER.watch_Later)
        self.lblWatchLaterCount.text = "\(watchLaterData.count) " + (watchLaterData.count <= 1 ? "Video" : "Videos")
        let offlineVideosData = UserDefaults.standard.getOfflineDownload(Key: Local.OFFLINE_DOWNLOAD.offline_download)
        self.lblOfflineCount.text =  "\(offlineVideosData.count) " + (offlineVideosData.count <= 1 ? "Video" : "Videos")
        let sharedVideosData = UserDefaults.standard.getSharedVideos(Key: Local.SHARED_VIDEOS.shared_videos)
        self.lblSharedCount.text = "\(sharedVideosData.count) " + (sharedVideosData.count <= 1 ? "Video" : "Videos")
        self.getPaidVideos()
    }
    
    // MARK: - Selectors
    
    // Drop Down Button Action
    @IBAction func dropdownButtonAction(_ sender: UIButton) {
        self.dropDown.show()
    }
    
    // View Profile Button Action
    @IBAction func viewProfileButtonAction(_ sender: UIButton) {
        let newVC = R.storyboard.loggedUser.newProfileVC()
        newVC?.channalData = AppInstance.instance.userProfile?.data
        self.navigationController?.pushViewController(newVC!, animated: true)
    }
    
    // Settings Button Action
    @IBAction func settingsButtonAction(_ sender: UIButton) {
        let vc = R.storyboard.settings.settingVC()
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    // Recent ViewAll Button Action
    @IBAction func recentViewAllButtonAction(_ sender: UIButton) {
        let vc = R.storyboard.library.recentlyWatchVC()
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    // New Playlist Button Action
    @IBAction func newPlaylistButtonAction(_ sender: UIButton) {
        let vc = R.storyboard.playlist.createNewPlaylistVC()
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    // Subscription Button Action
    @IBAction func subscriptionButtonAction(_ sender: UIButton) {
        let vc = R.storyboard.library.libSubscriptionVC()
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    // Watch Later Button Action
    @IBAction func watchLaterButtonAction(_ sender: UIButton) {
        let vc = R.storyboard.library.watchLaterVC()
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    // Offline Button Action
    @IBAction func offlineButtonAction(_ sender: UIButton) {
        let vc = R.storyboard.library.watchOfflineVC()
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    // Like Button Action
    @IBAction func likeButtonAction(_ sender: UIButton) {
        let vc = R.storyboard.library.lilbraryLikedVC()
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    // Paid Videos Button Action
    @IBAction func paidVideosButtonAction(_ sender: UIButton) {
        let Storyboards  = UIStoryboard(name: "library", bundle: nil)
        let vc = Storyboards.instantiateViewController(withIdentifier: "PaidVC") as! PaidVideoController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    // Share Videos Button Action
    @IBAction func shareVideosButtonAction(_ sender: UIButton) {
        let vc = R.storyboard.library.sharedVC()
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    // MARK: - Helper Functions
    
    // Initial Config
    func initialConfig() {
        self.registerCell()
        self.setupUI()
        NotificationCenter.default.addObserver(self, selector: #selector(self.updatePlaylist(notification:)), name: Notification.Name("updatePlaylist"), object: nil)
        
        self.lblUsername.text = AppInstance.instance.userProfile?.data?.username ?? ""
        let profileImage = URL(string: AppInstance.instance.userProfile?.data?.avatar ?? "")
        self.imgProfile.sd_setShowActivityIndicatorView(true)
        self.imgProfile.sd_setIndicatorStyle(.medium)
        DispatchQueue.global(qos: .userInteractive).async {
            self.imgProfile.sd_setImage(with: profileImage , placeholderImage:R.image.maxresdefault())
        }
    }
    
    // Register Cell
    func registerCell() {
        self.recentCollectionView.delegate = self
        self.recentCollectionView.dataSource = self
        self.recentCollectionView.register(UINib(resource: R.nib.videoSize3Cell), forCellWithReuseIdentifier: R.reuseIdentifier.videoSize3Cell.identifier)
        
        self.playListTblView.delegate = self
        self.playListTblView.dataSource = self
        self.playListTblView.register(UINib(resource: R.nib.playListCell), forCellReuseIdentifier: R.reuseIdentifier.playListCell.identifier)
        
        self.customizeDropDownFunc()
    }
    
    private  func customizeDropDownFunc() {
        dropDown.dataSource = ["Ascending", "Descending", "Recently added"]
        dropDown.anchorView = self.btnDropDown
        dropDown.cellNib = UINib(resource: R.nib.customDropDownCell)
        dropDown.backgroundColor = .white
        dropDown.customCellConfiguration = { (index: Index, item: String, cell: DropDownCell) -> Void in
            guard let cell = cell as? CustomDropDownCell else { return }
            cell.lineView.isHidden = index == 2
            cell.radioImage.image = UIImage(named: (self.selectedDropDownItem == item) ? "radio_button_on" : "radio_button_off")
        }
        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
          print("Selected item: \(item) at index: \(index)")
            if index == 0 {
                self.playlistsArray = self.playlistsArray.sorted(by: {($0.name ?? "") < ($1.name ?? "")})
                self.playListTblView.reloadData()
            }else if index == 1 {
                self.playlistsArray = self.playlistsArray.sorted(by: {($0.name ?? "") > ($1.name ?? "")})
                self.playListTblView.reloadData()
            }else if index == 2 {
                self.playlistsArray = self.playlistsArray.sorted(by: {($0.time ?? 0) < ($1.time ?? 0)})
                self.playListTblView.reloadData()
            }
            self.lblPlaylistShort.text = item
            self.selectedDropDownItem = item
            self.dropDown.reloadAllComponents()
        }
        self.dropDown.bottomOffset = .init(x: 0.0, y:  self.btnDropDown.bounds.height)
        self.dropDown.direction = .bottom
        DropDown.appearance().textColor = UIColor.black
        DropDown.appearance().backgroundColor = UIColor.white
        DropDown.appearance().selectionBackgroundColor = .clear
        DropDown.appearance().cornerRadius = 10
        DropDown.appearance().cellHeight = 45.0
    }
        
    private func setupUI() {
        if AppSettings.shouldShowAddMobBanner {
            let request = GADRequest()
            GADInterstitialAd.load(withAdUnitID: AppSettings.interestialAddUnitId, request: request, completionHandler: { (ad, error) in
                if let error = error {
                    print("Failed to load interstitial ad with error: \(error.localizedDescription)")
                    return
                }
                self.interstitial = ad
            })
        }
    }
    
    func CreateAd() -> GADInterstitialAd {
        GADInterstitialAd.load(withAdUnitID: AppSettings.interestialAddUnitId, request: GADRequest(), completionHandler: { (ad, error) in
            if let error = error {
                print("Failed to load interstitial ad with error: \(error.localizedDescription)")
                return
            }
            self.interstitial = ad
        })
        return  self.interstitial
    }
    
    @objc func updatePlaylist(notification: Notification) {
        self.myChannelPlayListfetchData()
    }
    
}

// MARK: - Extensions

// MARK: Api Call
extension LibraryVC {
    
    func fetchSubscribedChannels() {
        if Connectivity.isConnectedToNetwork() {
            let userID = AppInstance.instance.userId ?? 0
            let sessionID = AppInstance.instance.sessionId ?? ""
            LibraryManager.instance.getSubscribedChannels(user_id: userID, session_Token: sessionID, channel: 1, limit: 4, completionBlock: { (success, sessionError, error) in
                if success != nil {
                    Async.main {
                        log.debug("Success")
                        self.lblSubscriptionsCount.text = "\((success?.data?.count) ?? 0) Videos"
                    }
                } else if sessionError != nil {
                    Async.main {
                        self.dismissProgressDialog {
                            log.error("sessionError = \(sessionError?.errors!.error_text ?? "")")
                            self.view.makeToast(sessionError?.errors!.error_text)
                        }
                    }
                } else {
                    Async.main {
                        self.dismissProgressDialog {
                            log.error("error = \(error?.localizedDescription ?? "" )")
                            self.view.makeToast(error?.localizedDescription)
                        }
                    }
                }
            })
        } else {
            self.view.makeToast(InterNetError)
        }
    }
    
    func myChannelPlayListfetchData() {
        if Connectivity.isConnectedToNetwork() {
            let userID = AppInstance.instance.userId ?? 0
            let sessionID = AppInstance.instance.sessionId ?? ""
            Async.background {
                PlaylistManager.instance.getPlaylist(User_id: userID, Session_Token: sessionID, completionBlock: { (success, sessionError, error) in
                    if success != nil {
                        Async.main {
                            self.dismissProgressDialog {
                                log.debug("success")
                                self.playlistsArray = (success?.myAllPlaylists)!
                                self.playlistsArray = self.playlistsArray.sorted(by: {($0.time ?? 0) < ($1.time ?? 0)})
                                self.tblViewHeightConst.constant = CGFloat(self.playlistsArray.count * 65)
                                if !self.playlistsArray.isEmpty {
                                    UserDefaults.standard.setPlaylistImage(value: success?.myAllPlaylists?.last?.thumbnail ?? "", ForKey: "playlist")
                                }
                                self.playListTblView.reloadData()
                            }
                        }
                    } else if sessionError != nil {
                        Async.main {
                            log.debug("sessionError = \(sessionError?.errors!.error_text ?? "")")
                            self.view.makeToast(sessionError?.errors!.error_text)
                        }
                    } else {
                        Async.main {
                            log.debug("error = \(error?.localizedDescription ?? "")")
                            self.view.makeToast(error?.localizedDescription)
                        }
                    }
                })
            }
        } else {
            self.view.makeToast(InterNetError)
        }
    }
    
    func fetchRecentlyWatched() {
        if Connectivity.isConnectedToNetwork() {
            let userID = AppInstance.instance.userId ?? 0
            let sessionID = AppInstance.instance.sessionId ?? ""
            Async.background {
                LibraryManager.instance.recentlyWatchedVideos(User_id: userID, Session_Token: sessionID, Offset: 0, Limit: 10, completionBlock: { (success,sessionError , error) in
                    if success != nil {
                        Async.main {
                            log.debug("Success")
                            if let data = success?.data {
                                self.recentlyWatchedArray = AppInstance.instance.getNotInterestedData(data: data)
                            }
                            self.recentlyStackView.isHidden = self.recentlyWatchedArray.isEmpty
                            if !self.recentlyWatchedArray.isEmpty {
                                UserDefaults.standard.setRecentWatchImage(value: success?.data?.last?.thumbnail ?? "", ForKey: "recentlyWatch")
                            }
                            self.isLoading = false
                        }
                    } else if sessionError != nil {
                        Async.main {
                            self.recentlyWatchedArray = []
                            self.recentlyStackView.isHidden = self.recentlyWatchedArray.isEmpty
                            self.isLoading = false
                            log.error("sessionError = \(sessionError?.errors!.error_text ?? "")")
                            self.view.makeToast(sessionError?.errors!.error_text)
                        }
                    } else {
                        Async.main {
                            self.isLoading = false
                            log.error("error = \(error?.localizedDescription ?? "")")
                            self.view.makeToast(error?.localizedDescription)
                        }
                    }
                })
            }
        } else {
            self.view.makeToast(InterNetError)
        }
    }
    
    func getLikedVideos() {
        if Connectivity.isConnectedToNetwork() {
            let userID = AppInstance.instance.userId ?? 0
            let sessionID = AppInstance.instance.sessionId ?? ""
            Async.background {
                LibraryManager.instance.getLikedVideos(User_id: userID, Session_Token: sessionID, completionBlock: { (success, sessionError, error) in
                    if success != nil {
                        Async.main {
                            log.debug("success")
                            self.lblLikeCount.text = "\((success?.data?.count) ?? 0) Videos"
                        }
                    } else if sessionError != nil {
                        Async.main {
                            self.dismissProgressDialog {
                                log.debug("sessionError = \(sessionError?.errors!.error_text ?? "")")
                                self.view.makeToast(sessionError?.errors!.error_text)
                            }
                        }
                    } else {
                        Async.main {
                            self.dismissProgressDialog {
                                log.debug("error = \(error?.localizedDescription ?? "")")
                                self.view.makeToast(error?.localizedDescription)
                            }
                        }
                    }
                })
            }
        } else {
            self.view.makeToast(InterNetError)
        }
    }
    
    private func getPaidVideos() {
        if Connectivity.isConnectedToNetwork() {
            Async.background {
                PaidVideosManager.sharedInstance.getPaidVideos { (success, authError, error) in
                    if success != nil {
                        Async.main {
                            self.dismissProgressDialog {
                                log.debug("success")
                                self.lblPaidCount.text = "\((success?.videos?.count) ?? 0) Videos"
                            }
                        }
                    } else if authError != nil {
                        Async.main {
                            self.dismissProgressDialog {
                                log.debug("sessionError = \(authError?.errors?.error_text ?? "")")
                                self.view.makeToast(authError?.errors?.error_text ?? "")
                            }
                        }
                    } else {
                        Async.main {
                            log.debug("error = \(error?.localizedDescription ?? "")")
                            self.view.makeToast(error?.localizedDescription ?? "")
                        }
                    }
                }
            }
        } else {
            self.view.makeToast(InterNetError)
        }
    }
    
}

// MARK: TableView Setup
extension LibraryVC : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.isLoading {
            return 10
        } else {
            return self.playlistsArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.isLoading {
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.playListCell.identifier, for: indexPath) as! PlayListCell
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.playListCell.identifier, for: indexPath) as! PlayListCell
            let object = self.playlistsArray[indexPath.row]
            cell.setData(object: object)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.setTemplateWithSubviews(isLoading, animate: true, viewBackgroundColor: .systemBackground)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !self.isLoading {
            let vc = R.storyboard.playlist.getPlaylistVideosVC()
            vc?.listID = self.playlistsArray[indexPath.row].listID ?? ""
            vc?.playlistName = self.playlistsArray[indexPath.row].name ?? ""
            self.navigationController?.pushViewController(vc!, animated: true)
        }        
    }
    
}

// MARK: Collection View Setup
extension LibraryVC : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.isLoading {
            return 10
        } else {
            return self.recentlyWatchedArray.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if self.isLoading {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.videoSize3Cell.identifier, for: indexPath) as! VideoSize3Cell
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.videoSize3Cell.identifier, for: indexPath) as! VideoSize3Cell
            let object = self.recentlyWatchedArray[indexPath.row]
            cell.bind(object)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if !self.isLoading {
            if AppInstance.instance.addCount == AppSettings.interestialCount {
                interstitial.present(fromRootViewController: self)
                interstitial = CreateAd()
                AppInstance.instance.addCount = 0
            }
            AppInstance.instance.addCount = AppInstance.instance.addCount! + 1
            let videoObject = self.recentlyWatchedArray[indexPath.row]
            let newVC = self.tabBarController as! TabbarController
            newVC.statusBarHiddenDelegate = self
            newVC.handleOpenVideoPlayer(for: videoObject)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        cell.setTemplateWithSubviews(isLoading, animate: true, viewBackgroundColor: .systemBackground)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 156, height: 150)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 12
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 12
    }
    
}

// MARK: StatusBarHiddenDelegate
extension LibraryVC: StatusBarHiddenDelegate {
    
    func handleUpdate(isStatusBarHidden: Bool) {
        self.isStatusBarHidden = isStatusBarHidden
    }
    
}

// MARK: Overriden Properties
extension LibraryVC {
    
    override var prefersStatusBarHidden: Bool {
        return self.isStatusBarHidden
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        get {
            return .slide
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .darkContent
    }
    
}
