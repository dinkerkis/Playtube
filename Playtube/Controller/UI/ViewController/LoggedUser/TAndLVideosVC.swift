import UIKit
import PlaytubeSDK
import Async
import Toast_Swift

class TAndLVideosVC: BaseVC {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var titleLabel: UILabel!
    
    // MARK: - Properties
    
    var stockVideosArray: [VideoDetail] = []
    var topVideosArray: [VideoDetail] = []
    var latestVideosArray: [VideoDetail] = []
    var getStringStatus: String? =  ""
    private var isLoading = true {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
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
        self.registerCell()
        self.isLoading = true
        if self.getStringStatus == "topvideos" || self.getStringStatus == "latestvideos" {
            self.titleLabel.text = self.getStringStatus == "topvideos" ? "Top Videos" : "Latest Videos"
            self.fetchHomeData(UserID: AppInstance.instance.userId ?? 0, SessionID: AppInstance.instance.sessionId ?? "")
        } else {
            self.titleLabel.text = "Stock Videos"
            self.getStockVideos()
        }
    }
    
    // Register Cell
    func registerCell() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(UINib(resource: R.nib.trendingCell), forCellReuseIdentifier: R.reuseIdentifier.trendingCell.identifier)
        self.tableView.addPullRefresh { [weak self] in
            self?.isLoading = true
            if self?.getStringStatus == "topVideos" || self?.getStringStatus == "latestvideos" {
                self?.fetchHomeData(UserID: AppInstance.instance.userId ?? 0, SessionID: AppInstance.instance.sessionId ?? "")
            } else {
                self?.getStockVideos()
            }
        }
    }
    
    func getStockVideos() {
        let userID = AppInstance.instance.userId ?? 0
        let sessionID = AppInstance.instance.sessionId ?? ""
        HomeManager.instance.getStockVidoes(User_id: "\(userID)", Session_Token: sessionID, Offset: 0, Limit: 15) { (success, sessionError, Err) in
            if success != nil {
                guard let stock = success else { return }
                self.stockVideosArray = AppInstance.instance.getNotInterestedData(data: stock)
                self.isLoading = false
                self.tableView.stopPullRefreshEver()
            }
        }
    }
    
    func fetchHomeData(UserID: Int, SessionID: String) {
        if Connectivity.isConnectedToNetwork() {
            //self.showProgressDialog(text: NSLocalizedString("Loading...", comment: "Loading..."))
            Async.background {
                HomeManager.instance.getHomeDataWithLimit(User_id: UserID, Session_Token: SessionID, Limit: 32, completionBlock: { (success, sessionError, error) in
                    if success != nil {
                        Async.main {
                            self.dismissProgressDialog {
                                if self.getStringStatus == "topvideos" {
                                    self.topVideosArray = []
                                    if let data = success?.data?.top {
                                        self.topVideosArray = AppInstance.instance.getNotInterestedData(data: data)
                                    }
                                } else {
                                    self.latestVideosArray = []
                                    if let data = success?.data?.latest {
                                        self.latestVideosArray = AppInstance.instance.getNotInterestedData(data: data)
                                    }
                                }
                                self.isLoading = false
                                self.tableView.stopPullRefreshEver()
                            }
                        }
                    } else if sessionError != nil {
                        self.dismissProgressDialog {
                            log.verbose("sessionError = \(sessionError?.errors?.error_text ?? "")")
                            self.view.makeToast(sessionError?.errors?.error_text ?? "")
                        }
                    } else {
                        self.dismissProgressDialog {
                            log.verbose("Error = \(error?.localizedDescription ?? "")")
                            self.view.makeToast(error?.localizedDescription ?? "")
                        }
                    }
                })
            }
        } else {
            self.dismissProgressDialog {
                self.view.makeToast(InterNetError)
            }
        }
    }
    
}

// MARK: - Extensions

// MARK: TableView Setup
extension TAndLVideosVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isLoading {
            return 10
        } else {
            if self.getStringStatus == "topvideos" {
                return topVideosArray.count
            } else if self.getStringStatus == "latestvideos" {
                return latestVideosArray.count
            } else {
                return stockVideosArray.count
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.isLoading {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TrendingCell", for: indexPath) as! TrendingCell
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TrendingCell", for: indexPath) as! TrendingCell
            if self.getStringStatus == "topvideos" {
                let object = self.topVideosArray[indexPath.row]
                cell.bind(object)
            } else if self.getStringStatus == "latestvideos" {
                let object = self.latestVideosArray[indexPath.row]
                cell.bind(object)
            } else {
                let object = self.stockVideosArray[indexPath.row]
                cell.bind(object)
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isLoading {
            return
        } else {
            AppInstance.instance.addCount = AppInstance.instance.addCount! + 1
            let newVC = self.tabBarController as! TabbarController
            newVC.statusBarHiddenDelegate = self
            if self.getStringStatus == "topvideos" {
                let videoObject = self.topVideosArray[indexPath.row]
                newVC.handleOpenVideoPlayer(for: videoObject)
            } else if self.getStringStatus == "latestvideos" {
                let videoObject = self.latestVideosArray[indexPath.row]
                newVC.handleOpenVideoPlayer(for: videoObject)
            } else {
                let videoObject = self.stockVideosArray[indexPath.row]
                newVC.handleOpenVideoPlayer(for: videoObject)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.setTemplateWithSubviews(isLoading, animate: true, viewBackgroundColor: .systemBackground)
    }
    
}

// MARK: StatusBarHiddenDelegate
extension TAndLVideosVC: StatusBarHiddenDelegate {
    
    func handleUpdate(isStatusBarHidden: Bool) {
        self.isStatusBarHidden = isStatusBarHidden
    }
    
}

//MARK: Overriden Properties
extension TAndLVideosVC {
    
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
