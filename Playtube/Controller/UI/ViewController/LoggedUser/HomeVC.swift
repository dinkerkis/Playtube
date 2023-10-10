import UIKit
import Async
import PlaytubeSDK
import GoogleMobileAds
import DropDown
import UIView_Shimmer
import Toast_Swift

class HomeVC: BaseVC {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityInd: UIActivityIndicatorView!
    
    // MARK: - Properties
    var stockArray: [VideoDetail] = []
    var featuredArray: [VideoDetail] = []
    var topVideosArray: [VideoDetail] = []
    var latestVideosArray: [VideoDetail] = []
    var otherVideosArray: [VideoDetail] = []
    var shortsVideosArray: [VideoDetail] = []
    var isLoading = false
    var categories: [CategoryStruct] = []
    var isStatusBarHidden: Bool = false {
        didSet {
            if oldValue != self.isStatusBarHidden {
                self.setNeedsStatusBarAppearanceUpdate()
            }
        }
    }
    var isCategory = false
    var categoryVideos: [VideoDetail] = []
    var categoryId = ""
    
    // MARK: - View Life Cycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initialConfig()
    }
    
    // MARK: - Helper Functions
    
    // Initial Config
    func initialConfig() {
        self.registerCell()
        self.loadCat()        
        self.definesPresentationContext = true
    }
    
    // Register Cell
    func registerCell() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
        if #available(iOS 15.0, *) {
            self.tableView.sectionHeaderTopPadding = 0
            UITableView.appearance().isPrefetchingEnabled = false
        }
        self.tableView.register(UINib(resource: R.nib.homeHeaderAndCategoryCell), forCellReuseIdentifier: R.reuseIdentifier.homeHeaderAndCategoryCell.identifier)
        self.tableView.register(UINib(resource: R.nib.homeCollectionViewCell), forCellReuseIdentifier: R.reuseIdentifier.homeCollectionViewCell.identifier)
        self.tableView.register(UINib(resource: R.nib.trendingCell), forCellReuseIdentifier: R.reuseIdentifier.trendingCell.identifier)
    }
    
    func loadCat() {
        self.categories = []
        let category = AppInstance.instance.categories.sorted { element1, element2 in
            element1.key.localizedStandardCompare(element2.key) == .orderedAscending
        }
        for (key, value) in category {
            let cat1 = CategoryStruct(cat_Name: value.htmlAttributedString ?? "", cate_id: key)
            self.categories.append(cat1)
        }
        self.getStockVideos()
        self.tableView.addPullRefresh { [weak self] in
            self?.getStockVideos()
        }
    }
    
    func getStockVideos() {
        self.isLoading = true
        self.tableView.reloadData()
        let userID = AppInstance.instance.userId ?? 0
        let sessionID = AppInstance.instance.sessionId ?? ""
        HomeManager.instance.getStockVidoes(User_id: "\(userID)", Session_Token: sessionID, Offset: 0, Limit: 15) { (success, sessionErr, Err) in
            if success != nil {
                guard let stock = success else { return }
                self.stockArray = []
                self.stockArray = AppInstance.instance.getNotInterestedData(data: stock)
            }
            self.fetchShortsData(UserID: AppInstance.instance.userId ?? 0, SessionID: AppInstance.instance.sessionId ?? "")
        }
    }
    
    func fetchShortsData(UserID: Int, SessionID: String) {
        if Connectivity.isConnectedToNetwork() {
            Async.background {
                ShortsManager.instance.getShortsData(User_id: UserID, Session_Token: SessionID, Limit: 10, Offset: "", completionBlock: { success, sessionError, error in
                    if success != nil {
                        DispatchQueue.main.async {
                            self.shortsVideosArray = []
                            if let data = success?.data {
                                self.shortsVideosArray = AppInstance.instance.getNotInterestedData(data: data)
                            }
                        }
                    } else if sessionError != nil {
                        Async.main {
                            log.error("responseError = \(sessionError?.errors!.error_text ?? "")")
                            // self.view.makeToast(sessionError?.errors!.error_text)
                        }
                    } else {
                        log.error("error = \(error?.localizedDescription ?? "")")
                        self.view.makeToast(error?.localizedDescription ?? "")
                    }
                    self.fetchHomeData(UserID: AppInstance.instance.userId ?? 0, SessionID: AppInstance.instance.sessionId ?? "")
                })
            }
        } else {
            self.view.makeToast(InterNetError)
        }
    }
    
    func fetchHomeData(UserID: Int, SessionID: String) {
        if Connectivity.isConnectedToNetwork() {
            HomeManager.instance.getHomeDataWithLimit(User_id: UserID, Session_Token: SessionID, Limit: 15, completionBlock: { (success, sessionError, error) in
                if success != nil {
                    DispatchQueue.main.async {
                        self.otherVideosArray = []
                        self.featuredArray = []
                        var featuredVideos:[VideoDetail] = []
                        if let data = success?.data?.featured {
                            featuredVideos = AppInstance.instance.getNotInterestedData(data: data)
                        }
                        if featuredVideos.count != 0 {
                            for video in featuredVideos {
                                if self.featuredArray.count <= 10 {
                                    self.featuredArray.append(video)
                                } else {
                                    self.otherVideosArray.append(video)
                                }
                            }
                        }
                        self.topVideosArray = []
                        var topVideos:[VideoDetail] = []
                        if let data = success?.data?.top {
                            topVideos = AppInstance.instance.getNotInterestedData(data: data)
                        }
                        if topVideos.count != 0 {
                            for video in topVideos {
                                if self.topVideosArray.count <= 10 {
                                    self.topVideosArray.append(video)
                                } else {
                                    self.otherVideosArray.append(video)
                                }
                            }
                        }
                        self.latestVideosArray = []
                        var latestVideos:[VideoDetail] = []
                        if let data = success?.data?.latest {
                            latestVideos = AppInstance.instance.getNotInterestedData(data: data)
                        }
                        if latestVideos.count != 0 {
                            for video in latestVideos {
                                if self.latestVideosArray.count <= 10 {
                                    self.latestVideosArray.append(video)
                                } else {
                                    self.otherVideosArray.append(video)
                                }
                            }
                        }
                        self.isLoading = false
                        self.tableView.reloadData()
                        log.verbose("other videos = \(self.otherVideosArray.count)")
                        self.tableView.stopPullRefreshEver()
                    }
                } else if sessionError != nil {
                    Async.main {
                        self.dismissLoaderOnly(loader: self.activityInd)
                        log.error("responseError = \(sessionError?.errors!.error_text ?? "")")
                        self.view.makeToast(sessionError?.errors!.error_text)
                    }
                } else {
                    self.dismissLoaderOnly(loader: self.activityInd)
                    log.error("error = \(error?.localizedDescription ?? "")")
                    self.view.makeToast(error?.localizedDescription ?? "")
                }
            })
        } else {
            self.dismissLoaderOnly(loader: self.activityInd)
            self.view.makeToast(InterNetError)
        }
    }
    
    private func getCategoryVideo(cate_id: String, subCat: String?) {
        self.categoryVideos.removeAll()
        self.isCategory = true
        self.isLoading = true
        self.tableView.reloadData()
        if Connectivity.isConnectedToNetwork() {
            Async.background {
                GetCategoryVideoManager.sharedInstance.getCatVideo(User_id:AppInstance.instance.userId ?? 0, Session_Token: AppInstance.instance.sessionId ?? "", cat_id: cate_id, sub_id: subCat ?? "", Offset: 0, Limit: 15) { (success, authError, Error) in
                    if success != nil {
                        Async.main {
                            self.dismissProgressDialog {
                                if let data = success?.data {
                                    self.categoryVideos = AppInstance.instance.getNotInterestedData(data: data)
                                }
                                self.isLoading = false
                                self.tableView.stopPullRefreshEver()
                                self.tableView.reloadData()
                            }
                        }
                    } else if authError != nil {
                        Async.main {
                            self.dismissProgressDialog {
                                self.view.makeToast(authError?.errors.error_text)
                            }
                        }
                    } else if Error != nil {
                        Async.main {
                            self.dismissProgressDialog {
                                self.view.makeToast(Error?.localizedDescription)
                            }
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Extensions

// MARK: TableView Setup
extension HomeVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            if isCategory {
                if isLoading {
                    return 10
                } else {
                    return self.categoryVideos.count
                }
            } else {
                if isLoading {
                    return 11
                } else {
                    return 1 + self.otherVideosArray.count
                }
            }
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = self.tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.homeHeaderAndCategoryCell.identifier, for: indexPath) as! HomeHeaderAndCategoryCell
            cell.categories = self.categories
            cell.delegate = self
            return cell
        case 1:
            if isCategory {
                if isLoading {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "TrendingCell") as! TrendingCell
                    return cell
                } else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "TrendingCell") as! TrendingCell
                    let object = self.categoryVideos[indexPath.row]
                    cell.bind(object)
                    return cell
                }
            } else {
                if indexPath.row == 0 {
                    let cell = self.tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.homeCollectionViewCell.identifier, for: indexPath) as! HomeCollectionViewCell
                    cell.parentContorller = self
                    cell.statusBarHiddenDelegate = self
                    cell.delegate = self
                    cell.isLoading = self.isLoading
                    cell.featuredArray = self.featuredArray
                    cell.stockArray = self.stockArray
                    cell.topVideosArray = self.topVideosArray
                    cell.shortsVideosArray = self.shortsVideosArray
                    cell.latestVideosArray = self.latestVideosArray
                    cell.setupUI()
                    cell.reloadData()
                    return cell
                } else {
                    if self.isLoading {
                        let cell = tableView.dequeueReusableCell(withIdentifier: "TrendingCell", for: indexPath) as! TrendingCell
                        return cell
                    } else {
                        let cell = tableView.dequeueReusableCell(withIdentifier: "TrendingCell", for: indexPath) as! TrendingCell
                        let object = self.otherVideosArray[indexPath.row - 1]
                        cell.bind(object)
                        return cell
                    }
                }
            }
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isCategory {
            if isLoading {
                return
            } else {
                AppInstance.instance.addCount = AppInstance.instance.addCount! + 1
                let videoObject = self.categoryVideos[indexPath.row]
                let newVC = self.tabBarController as! TabbarController
                newVC.statusBarHiddenDelegate = self
                newVC.handleOpenVideoPlayer(for: videoObject)
            }
        } else {
            if self.isLoading {
                return
            } else {
                if indexPath.section == 1 && indexPath.row != 0 {
                    let videoObject = self.otherVideosArray[indexPath.row - 1]
                    AppInstance.instance.addCount =  AppInstance.instance.addCount! + 1
                    let newVC = self.tabBarController as! TabbarController
                    newVC.statusBarHiddenDelegate = self
                    newVC.handleOpenVideoPlayer(for: videoObject)
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if isCategory {
            if indexPath.section == 1 {
                cell.setTemplateWithSubviews(isLoading, animate: true, viewBackgroundColor: .systemBackground)
            }
        } else {
            if indexPath.section == 1 && indexPath.row != 0 {
                cell.setTemplateWithSubviews(isLoading, animate: true, viewBackgroundColor: .systemBackground)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch section {
        case 0:
            return UIView()
        case 1:
            let homeHeaderView = HomeHeaderView.init(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 90))
            homeHeaderView.delegate = self
            return homeHeaderView
        default:
            return UIView()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0:
            return 0
        case 1:
            if AppInstance.instance.userType == 1 {
                return 0
            } else {
                return UITableView.automaticDimension
            }
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
}

// MARK: HomeHeaderAndCategoryCellDelegate Methods
extension HomeVC: HomeHeaderAndCategoryCellDelegate {
    
    func handleChatButtonTap(sender: UIButton) {
        let vc = R.storyboard.chat.chatVC()
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    func handleSearchButtonTap(sender: UIButton) {
        let newVC = R.storyboard.loggedUser.searchVC()
        self.navigationController?.pushViewController(newVC!, animated: true)
    }
    
    func handleNotificationButtonTap(sender: UIButton) {
        let vc = R.storyboard.notification.notificationVC()
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    func handleProfileButtonTap(sender: UIButton) {
        let newVC = R.storyboard.loggedUser.newProfileVC()
        newVC?.channalData = AppInstance.instance.userProfile?.data
        self.navigationController?.pushViewController(newVC!, animated: true)
    }
    
    func handleCategoryTap(category: CategoryStruct) {
        if category.cat_Name == "For You" {
            self.isLoading = false
            self.isCategory = false
            self.tableView.reloadData()
        } else {
            self.categoryId = category.cate_id
            self.getCategoryVideo(cate_id: self.categoryId, subCat: "")
        }
    }
    
}

// MARK:  HomeHeaderViewDelegate Methods
extension HomeVC: HomeHeaderViewDelegate {
    
    func handleSignInMessageTap(sender: UIButton) {
        let vc = R.storyboard.auth.loginVC()
        let newVC = self.tabBarController as! TabbarController
        newVC.navigationController?.pushViewController(vc!, animated: true)
    }
    
}

// MARK: HomeCollectionViewCellDelegate Methods
extension HomeVC: HomeCollectionViewCellDelegate {
    
    func handleStockViewMoreButtonTap(sender: UIButton) {
        let vc = R.storyboard.loggedUser.tAndLVideosVC()
        vc?.getStringStatus = "stockvideos"
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    func handleShortsViewMoreButtonTap(sender: UIButton) {
        let vc = R.storyboard.loggedUser.shortsVC()
        vc?.isFromTabbar = true
        self.tabBarController?.navigationController?.pushViewController(vc!, animated: true)
    }
    
    func handleTopViewMoreButtonTap(sender: UIButton) {
        let vc = R.storyboard.loggedUser.tAndLVideosVC()
        vc?.getStringStatus = "topvideos"
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    func handleLatestViewMoreButtonTap(sender: UIButton) {
        let vc = R.storyboard.loggedUser.tAndLVideosVC()
        vc?.getStringStatus = "latestvideos"
        self.navigationController?.pushViewController(vc!, animated: true)
    }    
    
}

// MARK: StatusBarHiddenDelegate
extension HomeVC: StatusBarHiddenDelegate {
    
    func handleUpdate(isStatusBarHidden: Bool) {
        self.isStatusBarHidden = isStatusBarHidden
    }
    
}

// MARK: Overriden Properties
extension HomeVC {
    
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
