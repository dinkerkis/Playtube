import UIKit
import PlaytubeSDK
import Async
import UIView_Shimmer
import Toast_Swift

class LilbraryLikedVC: BaseVC {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var showStack: UIStackView!
    @IBOutlet weak var noVideoLbl: UILabel!
    
    // MARK: - Properties
    var likedVideosArray: [VideoDetail] = []
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
        self.noVideoLbl.text = NSLocalizedString("No videos found for now!", comment: "No videos found for now!")
        self.registerCell()
        self.isLoading = true
        self.getLikedVideos()
    }
    
    // Register Cell
    func registerCell() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(UINib(resource: R.nib.trendingCell), forCellReuseIdentifier: R.reuseIdentifier.trendingCell.identifier)
        self.tableView.addPullRefresh { [weak self] in
            self?.isLoading = true
            self?.getLikedVideos()
        }
    }
}

// MARK: - Extensions

// MARK: Api Call
extension LilbraryLikedVC {
    
    private func getLikedVideos() {
        if Connectivity.isConnectedToNetwork() {
            //self.showProgressDialog(text: NSLocalizedString("Loading...", comment: "Loading..."))
            let userID = AppInstance.instance.userId ?? 0
            let sessionID = AppInstance.instance.sessionId ?? ""
            Async.background {
                LibraryManager.instance.getLikedVideos(User_id: userID, Session_Token: sessionID, completionBlock: { (success, sessionError, error) in
                    if success != nil {
                        Async.main {
                            log.debug("success")
                            if let data = success?.data {
                                self.likedVideosArray = AppInstance.instance.getNotInterestedData(data: data)
                            }
                            if !self.likedVideosArray.isEmpty {
                                self.showStack.isHidden = true
                                self.tableView.isHidden = false
                                UserDefaults.standard.setLikedImage(value: success?.data?.last?.thumbnail ?? "", ForKey: "liked")
                            } else {
                                self.showStack.isHidden = false
                                self.tableView.isHidden = true
                            }
                            self.isLoading = false
                            self.tableView.stopPullRefreshEver()
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
    
}

// MARK: TableView Setup
extension LilbraryLikedVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isLoading {
            return 10
        } else {
            return self.likedVideosArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isLoading {
            let cell = self.tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.trendingCell.identifier, for: indexPath) as! TrendingCell
            return cell
        } else {
            let cell = self.tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.trendingCell.identifier, for: indexPath) as! TrendingCell
            let object = self.likedVideosArray[indexPath.row]
            cell.bind(object)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !self.isLoading {
//            if AppInstance.instance.addCount == AppSettings.interestialCount {
//                AppInstance.instance.addCount = 0
//            }
//            AppInstance.instance.addCount = AppInstance.instance.addCount! + 1
            let videoObject = self.likedVideosArray[indexPath.row]
            let newVC = self.tabBarController as! TabbarController
            newVC.statusBarHiddenDelegate = self
            newVC.handleOpenVideoPlayer(for: videoObject)
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.setTemplateWithSubviews(isLoading, animate: true, viewBackgroundColor: .systemBackground)
    }
    
}

// MARK: StatusBarHiddenDelegate
extension LilbraryLikedVC: StatusBarHiddenDelegate {
    
    func handleUpdate(isStatusBarHidden: Bool) {
        self.isStatusBarHidden = isStatusBarHidden
    }
    
}

// MARK: Overriden Properties
extension LilbraryLikedVC {
    
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
