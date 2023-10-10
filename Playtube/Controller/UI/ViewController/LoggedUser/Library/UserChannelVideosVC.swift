import UIKit
import Async
import PlaytubeSDK
import GoogleMobileAds
import Refreshable

protocol UserChannelVideosVCDelegate: AnyObject {
    func scrollViewDidScroll(scrollView: UIScrollView, tableView: UITableView)
    func videoCount(count: Int)
}

class UserChannelVideosVC: BaseVC {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var showStack: UIStackView!
    @IBOutlet weak var noVideoLbl: UILabel!
    
    // MARK: - Properties
    
    private static var pageSize = 15
    private var currentPage = 0
    private var lastPage = 0
    weak var delegate: UserChannelVideosVCDelegate?
    private var isLoading = true {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    var channelVideos = [VideoDetail]()
    var interstitial: GADInterstitialAd!
    var channelId: Int? = 0
    var parentContorller: NewUserChannelVC!
    
    // MARK: - View Life Cycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.initialConfig()
    }
    
    // MARK: - Helper Functions
    
    // Initial Config
    func initialConfig() {
        self.registerCell()
        self.setupUI()
        self.isLoading = true
        self.fetchChannelVideos()
    }
    
    // Register Cell
    func registerCell() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
        if #available(iOS 10.0, *) {
            tableView.prefetchDataSource = self
        }
        self.tableView.separatorStyle = .none
        self.tableView.register(UINib(resource: R.nib.playerNextTableItem), forCellReuseIdentifier: R.reuseIdentifier.playerNextTableItem.identifier)
        self.tableView.addPullRefresh { [weak self] in
            UserChannelVideosVC.pageSize = 15
            self?.currentPage = 0
            self?.lastPage = 0
            self?.tableView.setLoadMoreEnable(true)
            self?.isLoading = true
            self?.fetchChannelVideos()
        }
    }
    
    static func userChannelVideosVC() -> UserChannelVideosVC {
        let newVC = R.storyboard.library.userChannelVideosVC()
        return newVC!
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
    
    private func fetchChannelVideosLoadmore(indx : Int) {
        if Connectivity.isConnectedToNetwork() {
            let targetCount = currentPage < 0 ? 0 : (currentPage + 1) * UserChannelVideosVC.pageSize - 10
            guard indx == targetCount else {
                //print("videModel :=> ",index , targetCount)
                return
            }
            currentPage += 1
            //self.showProgressDialog(text: NSLocalizedString("Loading...", comment: "Loading..."))
            let channelID = self.channelId ?? 0
            Async.background {
                MyChannelManager.instance.getChannelVideos(User_id: channelID, Offset:self.channelVideos[self.channelVideos.count-1].id!, Limit:10, completionBlock: { (success, sessionError, error) in
                    if success != nil {
                        Async.main {
                            self.dismissProgressDialog {
                                log.verbose("SUCCESS")
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                    self.tableView.beginUpdates()
                                    for i in (success?.data)! {
                                        self.tableView.insertRows(at: [IndexPath(row: self.channelVideos.count, section: 0)], with: .automatic)
                                        self.channelVideos.append(i)
                                    }
                                    self.tableView.endUpdates()
                                }
                            }
                        }
                    } else if sessionError != nil {
                        self.dismissProgressDialog {
                            self.view.makeToast(sessionError?.errors!.error_text ?? "")
                            log.verbose("sessionError = \(sessionError?.errors?.error_text ?? "")")
                        }
                    } else {
                        self.dismissProgressDialog {
                            self.view.makeToast(error?.localizedDescription ?? "")
                            log.verbose("error = \(error?.localizedDescription ?? "")")
                        }
                    }
                })
            }
        } else {
            self.view.makeToast(InterNetError)
        }
    }
    
    private func fetchChannelVideos() {
        if Connectivity.isConnectedToNetwork() {
            //self.showProgressDialog(text: NSLocalizedString("Loading...", comment: "Loading..."))
            let channelID = self.channelId ?? 0
            Async.background {
                MyChannelManager.instance.getChannelVideos(User_id: channelID, Offset:0, Limit:70, completionBlock: { (success, sessionError, error) in
                    if success != nil {
                        Async.main {
                            self.dismissProgressDialog {
                                log.verbose("SUCCESS")
                                self.channelVideos = success?.data ?? []
                                self.delegate?.videoCount(count:  self.channelVideos.count)
                                if !self.channelVideos.isEmpty {
                                    // self.tableView.reloadData()
                                    self.showStack.isHidden = true
                                    self.tableView.isHidden = false
                                } else {
                                    self.showStack.isHidden = false
                                    self.tableView.isHidden = true
                                }
                                self.isLoading = false
                                self.tableView.stopPullRefreshEver()
                            }
                        }
                    } else if sessionError != nil {
                        self.dismissProgressDialog {
                            self.view.makeToast(sessionError?.errors!.error_text ?? "")
                            log.verbose("sessionError = \(sessionError?.errors?.error_text ?? "")")
                        }
                    } else {
                        self.dismissProgressDialog {
                            self.view.makeToast(error?.localizedDescription ?? "")
                            log.verbose("error = \(error?.localizedDescription ?? "")")
                        }
                    }
                })
            }
        } else {
            self.view.makeToast(InterNetError)
        }
    }
    
    func viewModel(at index: Int) -> VideoDetail? {
        guard index >= 0 && index < self.channelVideos.count else { return nil }
        /*print("Index :=> ",index, self.channelVideos.count)*/
        //self.fetchChannelVideosLoadmore(indx : index)
        return self.channelVideos[index]
    }
}

// MARK: - Extensions

// MARK: TableView Setup
extension UserChannelVideosVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isLoading {
            return 10
        } else {
            return self.channelVideos.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isLoading {
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.playerNextTableItem.identifier, for: indexPath) as! PlayerNextTableItem
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.playerNextTableItem.identifier) as! PlayerNextTableItem
            if let object = self.viewModel(at: indexPath.row) {
                cell.bind(object)
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.setTemplateWithSubviews(isLoading, animate: true, viewBackgroundColor: .systemBackground)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if AppInstance.instance.addCount == AppSettings.interestialCount {
            interstitial.present(fromRootViewController: self)
            interstitial = CreateAd()
            AppInstance.instance.addCount = 0
        }
        AppInstance.instance.addCount = AppInstance.instance.addCount! + 1
        let videoObject = self.channelVideos[indexPath.row]
        (self.parentContorller.tabBarController as! TabbarController).handleOpenVideoPlayer(for: videoObject)
    }
    
}

// MARK: UITableViewDataSourcePrefetching
extension UserChannelVideosVC: UITableViewDataSourcePrefetching {
    
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            if self.channelVideos.count == 0 {
                return
            }
            if let _ = self.viewModel(at: (indexPath as NSIndexPath).row) {
                print(String.init(format: "prefetchRowsAt #%i", indexPath.row))
            }
        }
    }
    
}

// MARK: UIScrollViewDelegate
extension UserChannelVideosVC: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.delegate?.scrollViewDidScroll(scrollView: scrollView, tableView: self.tableView)
    }
    
}
