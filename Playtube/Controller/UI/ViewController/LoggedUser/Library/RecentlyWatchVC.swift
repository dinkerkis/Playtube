import UIKit
import Async
import PlaytubeSDK
import GoogleMobileAds
import Refreshable
import Toast_Swift

class RecentlyWatchVC: BaseVC {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var showStack: UIStackView!
    @IBOutlet weak var noVideoLbl: UILabel!
    
    // MARK: - Properties
    
    private static var pageSize = 15
    private var currentPage = 0
    private var lastPage = 0
    private var isLoading = true {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    var recentlyWatchedArray: [VideoDetail] = []
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
    
    // MARK: - Helper Functions
    
    // Initial Config
    func initialConfig() {
        self.noVideoLbl.text = NSLocalizedString("No videos found for now!", comment: "No videos found for now!")
        self.setupUI()
        self.registerCell()
        self.isLoading = true
        self.fetchRecentlyWatched()
    }
    
    // Register Cell
    func registerCell() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(UINib(resource: R.nib.playerNextTableItem), forCellReuseIdentifier: R.reuseIdentifier.playerNextTableItem.identifier)
        self.tableView.setLoadMoreEnable(true)
        self.tableView.addPullRefresh { [weak self] in
            RecentlyWatchVC.pageSize = 15
            self?.currentPage = 0
            self?.lastPage = 0
            self?.isLoading = true
            self?.tableView.setLoadMoreEnable(true)
            self?.fetchRecentlyWatched()
        }
        /*self.scView.addLoadMore(action: { [weak self] in
         self?.fetchRecentlyWatchedLoadMore()
         })*/
        if #available(iOS 10.0, *) {
            tableView.prefetchDataSource = self
        }
    }
    
    private func setupUI() {
        DispatchQueue.main.async { [weak self] in
            if AppSettings.shouldShowAddMobBanner {
                let request = GADRequest()
                GADInterstitialAd.load(withAdUnitID: AppSettings.interestialAddUnitId, request: request, completionHandler: { (ad, error) in
                    if let error = error {
                        print("Failed to load interstitial ad with error: \(error.localizedDescription)")
                        return
                    }
                    self?.interstitial = ad
                })
            }
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
    
    private func fetchRecentlyWatchedLoadMore(indx : Int) {
        if Connectivity.isConnectedToNetwork() {
            let targetCount = currentPage < 0 ? 0 : (currentPage + 1) * RecentlyWatchVC.pageSize - 10
            guard indx == targetCount else {
                //print("videModel :=> ",index , targetCount)
                return
            }
            currentPage += 1
            let userID = AppInstance.instance.userId ?? 0
            let sessionID = AppInstance.instance.sessionId ?? ""
            LibraryManager.instance.recentlyWatchedVideos(User_id: userID, Session_Token: sessionID, Offset: self.recentlyWatchedArray[self.recentlyWatchedArray.count-1].history_id! as NSNumber,Limit: 8, completionBlock: { (success,sessionError , error) in
                if success != nil {
                    Async.main {
                        log.debug("Success")
                        self.lastPage += 1
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            self.tableView.beginUpdates()
                            for i in (success?.data)! {
                                self.tableView.insertRows(at: [IndexPath(row: self.recentlyWatchedArray.count, section: 0)], with: .automatic)
                                self.recentlyWatchedArray.append(i)
                            }
                            self.tableView.endUpdates()
                            /*self.scView.stopLoadMore()
                            if (success?.data)!.count == 0
                            {
                                self.scView.setLoadMoreEnable(false)
                            }*/
                        }
                    }
                } else if sessionError != nil {
                    Async.main {
                        self.isLoading = false
                        self.tableView.stopLoadMore()
                        self.tableView.setLoadMoreEnable(false)
                        log.error("sessionError = \(sessionError?.errors?.error_text ?? "")")
                        /*self.view.makeToast(sessionError?.errors?.error_text ?? "")*/
                    }
                } else {
                    Async.main {
                        self.isLoading = false
                        self.tableView.stopLoadMore()
                        self.tableView.setLoadMoreEnable(false)
                        log.error("error = \(error?.localizedDescription ?? "")")
                        self.view.makeToast(error?.localizedDescription ?? "")
                    }
                }
            })
        } else {
            self.tableView.stopLoadMore()
            self.tableView.setLoadMoreEnable(false)
            self.view.makeToast(InterNetError)
        }
    }
    
    private func fetchRecentlyWatched() {
        if Connectivity.isConnectedToNetwork() {
            let userID = AppInstance.instance.userId ?? 0
            let sessionID = AppInstance.instance.sessionId ?? ""
            LibraryManager.instance.recentlyWatchedVideos(User_id: userID, Session_Token: sessionID, Offset: 0, Limit: 10, completionBlock: { (success, sessionError, error) in
                if success != nil {
                    Async.main {
                        log.debug("Success")
                        self.recentlyWatchedArray = success?.data ?? []
                            if self.recentlyWatchedArray.isEmpty {
                                self.tableView.isHidden = true
                                self.showStack.isHidden = false
                            } else {
                                self.tableView.isHidden = false
                                self.showStack.isHidden = true
                                UserDefaults.standard.setRecentWatchImage(value: success?.data?.last?.thumbnail ?? "", ForKey: "recentlyWatch")
                            }
                            self.isLoading = false
                            self.tableView.stopPullRefreshEver()
                    }
                } else if sessionError != nil {
                    Async.main {
                        self.isLoading = false
                        log.error("sessionError = \(sessionError?.errors?.error_text ?? "")")
                        self.view.makeToast(sessionError?.errors?.error_text ?? "")
                    }
                } else {
                    Async.main {
                        self.isLoading = false
                        log.error("error = \(error?.localizedDescription ?? "")")
                        self.view.makeToast(error?.localizedDescription ?? "")
                    }
                }
            })
        } else {
            self.view.makeToast(InterNetError)
        }
    }
    
    func viewModel(at index: Int) -> VideoDetail? {
        guard index >= 0 && index < self.recentlyWatchedArray.count else { return nil }
        print("Index :=> ",index, self.recentlyWatchedArray.count)
        self.fetchRecentlyWatchedLoadMore(indx : index)
        return self.recentlyWatchedArray[index]
    }
}

// MARK: - Extensions

// MARK: TableView Setup
extension RecentlyWatchVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isLoading {
            return 10
        } else {
            return self.recentlyWatchedArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isLoading {
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.playerNextTableItem.identifier) as! PlayerNextTableItem
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier:R.reuseIdentifier.playerNextTableItem.identifier) as! PlayerNextTableItem
            if let object = self.viewModel(at: indexPath.row) {
                cell.bind(object)
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
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
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.setTemplateWithSubviews(isLoading, animate: true, viewBackgroundColor: .systemBackground)
    }
    
}

// MARK: UITableViewDataSourcePrefetching
extension RecentlyWatchVC: UITableViewDataSourcePrefetching {
    
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            if self.recentlyWatchedArray.count == 0 {
                return
            }
            if let _ = self.viewModel(at: (indexPath as NSIndexPath).row) {
                print(String.init(format: "prefetchRowsAt #%i", indexPath.row))
            }
        }
    }
    
}
    
// MARK: StatusBarHiddenDelegate
extension RecentlyWatchVC: StatusBarHiddenDelegate {
    
    func handleUpdate(isStatusBarHidden: Bool) {
        self.isStatusBarHidden = isStatusBarHidden
    }
    
}

// MARK: Overriden Properties
extension RecentlyWatchVC {
    
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

