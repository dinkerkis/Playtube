import UIKit
import Async
import PlaytubeSDK

import UIView_Shimmer

class WatchLaterVC: BaseVC {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var showStack: UIStackView!
    @IBOutlet weak var noVideoLbl: UILabel!
    
    // MARK: - Properties
    
    private var isLoading = true {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    var watchLaterVideos: [VideoDetail] = []
    
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
        self.getWatchLaterVideos()
    }
    
    // Register Cell
    func registerCell() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(UINib(resource: R.nib.trendingCell), forCellReuseIdentifier: R.reuseIdentifier.trendingCell.identifier)
        self.tableView.addPullRefresh { [weak self] in
            self?.isLoading = true
            self?.getWatchLaterVideos()
        }
    }

    func getWatchLaterVideos() {
        let allData =  UserDefaults.standard.getSharedVideos(Key: Local.WATCH_LATER.watch_Later)
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
                    self.watchLaterVideos.append(videoObject!)
                } else {
                    log.verbose("Nil values cannot be append in Array!")
                }
            }
            self.watchLaterVideos = AppInstance.instance.getNotInterestedData(data: watchLaterVideos)
            self.watchLaterVideos.reverse()
            self.isLoading = false
            self.tableView.stopPullRefreshEver()
        }
    }
}

// MARK: -  Extensions

// MARK: TableView Setup
extension WatchLaterVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isLoading {
            return 10
        } else {
            return self.watchLaterVideos.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isLoading {
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.trendingCell.identifier, for: indexPath) as! TrendingCell
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.trendingCell.identifier, for: indexPath) as! TrendingCell
            let object = self.watchLaterVideos[indexPath.row]
            cell.bind(object)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.setTemplateWithSubviews(isLoading, animate: true, viewBackgroundColor: .systemBackground)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        if AppInstance.instance.addCount == AppSettings.interestialCount {
//            AppInstance.instance.addCount = 0
//        }
//        AppInstance.instance.addCount = AppInstance.instance.addCount! + 1
        let videoObject = self.watchLaterVideos[indexPath.row]
        let newVC = self.tabBarController as! TabbarController
        newVC.statusBarHiddenDelegate = self
        newVC.handleOpenVideoPlayer(for: videoObject)
    }
    
}

// MARK: StatusBarHiddenDelegate
extension WatchLaterVC: StatusBarHiddenDelegate {
    
    func handleUpdate(isStatusBarHidden: Bool) {
        self.isStatusBarHidden = isStatusBarHidden
    }
    
}

// MARK: Overriden Properties
extension WatchLaterVC {
    
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
