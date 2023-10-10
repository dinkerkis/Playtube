import Async
import PlaytubeSDK
import DropDown
import UIView_Shimmer
import Refreshable
import Foundation

class TrendingVC: BaseVC {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var noDataView: UIView!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var notificationButton: UIButton!
    @IBOutlet weak var chatButton: UIButton!
    @IBOutlet weak var profileButton: UIButton!
    @IBOutlet weak var optionView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityInd: UIActivityIndicatorView!
    
    // MARK: - Properties
    
    var trendingArray : [VideoDetail] = []
    weak var statusBarHiddenDelegate: StatusBarHiddenDelegate?
    private var isLoading = true
    
    // MARK: - View Life Cycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initialConfig()
    }
    
    // MARK: - Selectors
    
    // Chat Button Action
    @IBAction func chatButtonAction(_ sender: UIButton) {
        self.view.endEditing(true)
        let vc = R.storyboard.chat.chatVC()
        self.navigationController?.pushViewController(vc!, animated: true)
    }
        
    // Profile Button Action
    @IBAction func profileButtonAction(_ sender: UIButton) {
        self.view.endEditing(true)
        let newVC = R.storyboard.loggedUser.newProfileVC()
        newVC?.channalData = AppInstance.instance.userProfile?.data
        self.navigationController?.pushViewController(newVC!, animated: true)
    }
        
    // Search Button Action
    @IBAction func searchButtonAction(_ sender: UIButton) {
        self.view.endEditing(true)
        let newVC = R.storyboard.loggedUser.searchVC()
        self.navigationController?.pushViewController(newVC!, animated: true)
    }
    
    // Notifiction Button Action
    @IBAction func notificationButtonAction(_ sender: UIButton) {
        self.view.endEditing(true)
        let vc = R.storyboard.notification.notificationVC()
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    // Popular Channel Button Action
    @IBAction func popularChannelButtonAction(_ sender: UIButton) {
        self.view.endEditing(true)
        let newVC = R.storyboard.loggedUser.popularChannelVC()
        self.navigationController?.pushViewController(newVC!, animated: true)
    }
    
    // Movies Button Action
    @IBAction func moviesButtonAction(_ sender: UIButton) {
        self.view.endEditing(true)
        if let vc = R.storyboard.loggedUser.moviesNewVC() {
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    // Articles Button Action
    @IBAction func articlesButtonAction(_ sender: UIButton) {
        self.view.endEditing(true)
        let vc = R.storyboard.loggedUser.newArticleVC()
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    // MARK: - Helper Functions
    
    // Initial Config
    func initialConfig() {
        self.registerCell()
        self.setupUI()
        isLoading = true
        self.fetchTrendingData(UserID: AppInstance.instance.userId ?? 0, SessionID: AppInstance.instance.sessionId ?? "")
        self.tableView.addPullRefresh { [weak self] in
            self?.isLoading = true
            self!.tableView.reloadData()
            self?.fetchTrendingData(UserID: AppInstance.instance.userId ?? 0, SessionID: AppInstance.instance.sessionId ?? "")
        }
    }
    
    // Register Cell
    func registerCell() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.separatorStyle = .none
        self.tableView.register(UINib(resource: R.nib.trendingCell), forCellReuseIdentifier: R.reuseIdentifier.trendingCell.identifier)
    }
    
    // Setup UI
    private func setupUI() {
        self.notificationButton.isHidden = AppInstance.instance.userType == 0
        self.profileButton.isHidden = AppInstance.instance.userType == 0
        self.chatButton.isHidden = AppInstance.instance.userType == 0
        self.optionView.isHidden = AppInstance.instance.userType == 0
    }
        
    func fetchTrendingData(UserID: Int, SessionID: String) {
        self.trendingArray.removeAll()
        if Connectivity.isConnectedToNetwork() {
            Async.background {
                TrendingManager.instance.getTrendingData(User_id: UserID, Session_Token: SessionID, Offset:0, completionBlock: { (success, sessionError, error) in
                    if success != nil {
                        if let data = success?.data {
                            self.trendingArray = AppInstance.instance.getNotInterestedData(data: data)
                        }
                        log.debug("success : \(self.trendingArray.count)")
                        if self.trendingArray.isEmpty || self.trendingArray.count == 0 {
                            self.noDataView.isHidden = false
                            self.tableView.isHidden = true
                        }else {
                            self.noDataView.isHidden = true
                            self.tableView.isHidden = false
                        }
                        self.isLoading = false
                        self.tableView.reloadData()
                        self.tableView.stopPullRefreshEver()
                    } else if sessionError != nil {
                        Async.main {
                            log.error("responseError = \(sessionError?.errors!.error_text ?? "")")
                            self.view.makeToast(sessionError?.errors!.error_text)
                        }
                    } else {
                        log.error("error = \(error?.localizedDescription ?? "")")
                        self.view.makeToast(error?.localizedDescription ?? "")
                    }
                })
            }
        } else {
            self.view.makeToast(InterNetError)
        }
    }
}

// MARK: - Extensions

// MARK: TableView Setup
extension TrendingVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isLoading {
            return 10
        } else {
            return self.trendingArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isLoading {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TrendingCell", for: indexPath) as! TrendingCell
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TrendingCell") as! TrendingCell
            let object = self.trendingArray[indexPath.row]
            cell.bind(object)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.setTemplateWithSubviews(isLoading, animate: true, viewBackgroundColor: .systemBackground)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !isLoading {
            let videoObject = self.trendingArray[indexPath.row]
            AppInstance.instance.addCount =  AppInstance.instance.addCount! + 1
            let newVC = self.tabBarController as! TabbarController
            newVC.statusBarHiddenDelegate = self
            newVC.handleOpenVideoPlayer(for: videoObject)
        }
    }
    
}

// MARK: StatusBarHiddenDelegate
extension TrendingVC: StatusBarHiddenDelegate {
    
    func handleUpdate(isStatusBarHidden: Bool) {
        self.statusBarHiddenDelegate?.handleUpdate(isStatusBarHidden: isStatusBarHidden)
    }
    
}
