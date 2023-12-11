import UIKit
import Async
import PlaytubeSDK

class WatchOfflineVC: BaseVC {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var showStack: UIStackView!
    @IBOutlet weak var noVideoLbl: UILabel!
    
    // MARK: - Properties
    
    var offlineDownloadVideos: [VideoDetail] = []
    var isStatusBarHidden: Bool = false {
        didSet {
            if oldValue != self.isStatusBarHidden {
                self.setNeedsStatusBarAppearanceUpdate()
            }
        }
    }
    private var isLoading = true {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
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
    
    //MARK: - Helper Functions
    
    // Initial Config
    func initialConfig() {
        self.noVideoLbl.text = NSLocalizedString("No videos found for now!", comment: "No videos found for now!")
        self.registerCell()
        self.isLoading = true
        self.getOfflineVideos()
    }
    
    // Register Cell
    func registerCell() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(UINib(resource: R.nib.trendingCell), forCellReuseIdentifier: R.reuseIdentifier.trendingCell.identifier)
        self.tableView.addPullRefresh { [weak self] in
            self?.isLoading = true
            self?.getOfflineVideos()
        }
    }
    
    func getOfflineVideos() {
        let allData =  UserDefaults.standard.getOfflineDownload(Key: Local.OFFLINE_DOWNLOAD.offline_download)
        if allData.isEmpty {
            self.tableView.isHidden = true
            self.showStack.isHidden = false
        } else {
            self.tableView.isHidden = false
            self.showStack.isHidden = true
            log.verbose("all data = \(allData)")
            for data in allData {
                let videoObject = try? PropertyListDecoder().decode(VideoDetail.self ,from: data)
                if videoObject != nil {
                    log.verbose("videoObject = \(videoObject?.id ?? 0)")
                    self.offlineDownloadVideos.append(videoObject!)
                    UserDefaults.standard.setOfflineImage(value: (offlineDownloadVideos.last?.thumbnail)!, ForKey: "libraryOfflineDownloadImage")
                } else {
                    log.verbose("Nil values cannot be append in Array!")
                }
            }
            self.offlineDownloadVideos.reverse()
            self.isLoading = false
            self.tableView.stopPullRefreshEver()
        }        
    }
    
}

// MARK: - Extensions

// MARK: TableView Setup
extension WatchOfflineVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.offlineDownloadVideos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.trendingCell.identifier) as! TrendingCell
        let object = self.offlineDownloadVideos[indexPath.row]
        cell.bind(object)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        if AppInstance.instance.addCount == AppSettings.interestialCount {
//            AppInstance.instance.addCount = 0
//        }
//        AppInstance.instance.addCount = AppInstance.instance.addCount! + 1
        var videoObject = self.offlineDownloadVideos[indexPath.row]
        let newVC = self.tabBarController as! TabbarController
         newVC.statusBarHiddenDelegate = self
        self.handleFetchVideoFromCachingManagerUsing(urlString: videoObject.video_location ?? "") { url in
            guard let urlUnwrapped = url else { return }
            videoObject.video_location = urlUnwrapped.absoluteString
        }
        newVC.handleOpenVideoPlayer(for: videoObject)
    }
    
}

extension WatchOfflineVC {
    
    fileprivate func handleFetchVideoFromCachingManagerUsing(urlString: String, completion: @escaping (URL?) -> ()) {
        CacheManager.shared.getFileWith(stringUrl: urlString) { result in
            switch result {
            case .success(let url):
                // do some magic with path to saved video
                completion(url)
                break;
            case .failure(let error):
                // handle errror
                completion(nil)
                print(error, "failed to find value of key\(urlString) in cache and also synchroniously failed to fetch video from our remote server, most likely a network issue like lack of connectivity or database failure")
                break;
            }
        }
    }
    
}

// MARK: StatusBarHiddenDelegate
extension WatchOfflineVC: StatusBarHiddenDelegate {
    
    func handleUpdate(isStatusBarHidden: Bool) {
        self.isStatusBarHidden = isStatusBarHidden
    }
    
}

// MARK: Overriden Properties
extension WatchOfflineVC {
    
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
