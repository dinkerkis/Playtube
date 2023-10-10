import UIKit
import Async
import PlaytubeSDK
import GoogleMobileAds
import Toast_Swift

class LibSubscriptionVC: BaseVC {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var showStack: UIStackView!
    @IBOutlet weak var noVideo: UILabel!
    
    // MARK: - Properties
    
    private var isLoading = true {
        didSet {
            self.tableView.reloadData()
        }
    }
    private var subscribedChannelArray: [Owner] = []
    var subscribedChannelVideosArray: [VideoDetail] = []
    var bannerView: GADBannerView!
    var interstitial: GADInterstitialAd!
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
    
    // MARK: - Selectors
    
    // Back Button Action
    @IBAction func backButtonAction(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    // View More Button Action
    @IBAction func viewMoreButtonAction(_ sender: UIButton) {
        let newVC = R.storyboard.library.channelsVC()
        self.navigationController?.pushViewController(newVC!, animated: true)
    }
    
    // MARK: - Helper Functions
    
    // Initial Config
    func initialConfig() {
        self.noVideo.text = NSLocalizedString("No videos found for now!", comment: "No videos found for now!")
        self.setupUI()
        self.registerCell()
        self.isLoading = true
        self.fetchSubscribedChannels()
    }
    
    // Register Cell
    func registerCell() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(UINib(resource: R.nib.popularCell), forCellReuseIdentifier: R.reuseIdentifier.popularCell.identifier)
        self.tableView.register(UINib(resource: R.nib.trendingCell), forCellReuseIdentifier: R.reuseIdentifier.trendingCell.identifier)
        self.tableView.addPullRefresh { [weak self] in
            self?.isLoading = true
            self?.fetchSubscribedChannels()
        }
    }
    
    private func setupUI() {
        if AppSettings.shouldShowAddMobBanner {
            /*bannerView = GADBannerView(adSize: kGADAdSizeBanner)
            addBannerViewToView(bannerView)
            bannerView.adUnitID = AppSettings.addUnitId
            bannerView.rootViewController = self
            bannerView.load(GADRequest())*/
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
    
    func addBannerViewToView(_ bannerView: GADBannerView) {
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bannerView)
        view.addConstraints([
            NSLayoutConstraint(item: bannerView, attribute: .bottom, relatedBy: .equal, toItem: bottomLayoutGuide, attribute: .top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: bannerView, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0)
        ])
    }
    
}

// MARK: - Extensions

// MARK: Api Call
extension LibSubscriptionVC {
    
    private func fetchSubscribedChannels() {
        if Connectivity.isConnectedToNetwork() {
            let userID = AppInstance.instance.userId ?? 0
            let sessionID = AppInstance.instance.sessionId ?? ""
            LibraryManager.instance.getSubscribedChannels(user_id: userID, session_Token: sessionID, channel: 1, limit: 4) { (success, sessionError, error) in
                if success != nil {
                    Async.main {
                        log.debug("Success")
                        self.subscribedChannelArray = []
                        self.subscribedChannelArray = success?.data ?? []
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
                            log.error("error = \(error?.localizedDescription ?? "")")
                            self.view.makeToast(error?.localizedDescription)
                        }
                    }
                }
            }
            self.subscribedChannelVideos()
        } else {
            self.view.makeToast(InterNetError)
        }
    }
    
    private func subscribedChannelVideos() {
        if Connectivity.isConnectedToNetwork() {
            let userID = AppInstance.instance.userId ?? 0
            let sessionID = AppInstance.instance.sessionId ?? ""
            Async.background {
                LibraryManager.instance.getSubscribedChannelsVideos(User_id: userID, Session_Token: sessionID, ChannelId: 0, Limit: 10, completionBlock: { (success, sessionError, error) in
                    if success != nil {
                        Async.main {
                            self.dismissProgressDialog {
                                log.verbose("success")
                                self.subscribedChannelVideosArray = []
                                if let data = success?.data {
                                    self.subscribedChannelVideosArray = AppInstance.instance.getNotInterestedData(data: data)
                                }
                                if self.subscribedChannelVideosArray.isEmpty {
                                    self.tableView.isHidden = true
                                    self.showStack.isHidden = false
                                } else {
                                    self.tableView.isHidden = false
                                    self.showStack.isHidden = true
                                }
                                self.isLoading = false
                                self.tableView.stopPullRefreshEver()
                                let getThumb = UserDefaults.standard.getSubscriptionImage(Key: "subscription")
                                UserDefaults.standard.setSubscriptionImage(value: success?.data?.last?.thumbnail ?? "", ForKey: "subscription")
                            }
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
                                log.error("error = \(error?.localizedDescription ?? "")")
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
    
}

// MARK: TableView Setup
extension LibSubscriptionVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            if isLoading {
                return 10
            } else {
                return self.subscribedChannelArray.count
            }
        case 1:
            if isLoading {
                return 10
            } else {
                return self.subscribedChannelVideosArray.count
            }
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            if isLoading {
                let cell = self.tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.popularCell.identifier, for: indexPath) as! PopularCell
                return cell
            } else {
                let cell = self.tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.popularCell.identifier, for: indexPath) as! PopularCell
                let object = self.subscribedChannelArray[indexPath.row]
                cell.bind(object)
                return cell
            }
        case 1:
            if isLoading {
                let cell = self.tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.trendingCell.identifier, for: indexPath) as! TrendingCell
                return cell
            } else {
                let cell = self.tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.trendingCell.identifier, for: indexPath) as! TrendingCell
                let object = self.subscribedChannelVideosArray[indexPath.row]
                cell.bind(object)
                return cell
            }
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            if !isLoading {
                let newVC = R.storyboard.library.newUserChannelVC()
                newVC?.channelData = self.subscribedChannelArray[indexPath.row]
                self.navigationController?.pushViewController(newVC!, animated: true)
            }
        case 1:
            if !isLoading {
                AppInstance.instance.addCount = AppInstance.instance.addCount! + 1
                let videoObject = self.subscribedChannelVideosArray[indexPath.row]
                let newVC = self.tabBarController as! TabbarController
                newVC.statusBarHiddenDelegate = self
                newVC.handleOpenVideoPlayer(for: videoObject)
            }
        default:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.setTemplateWithSubviews(isLoading, animate: true, viewBackgroundColor: .systemBackground)
    }
    
}

// MARK: StatusBarHiddenDelegate
extension LibSubscriptionVC: StatusBarHiddenDelegate {
    
    func handleUpdate(isStatusBarHidden: Bool) {
        self.isStatusBarHidden = isStatusBarHidden
    }
    
}

// MARK: Overriden Properties
extension LibSubscriptionVC {
    
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
