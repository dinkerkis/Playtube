import UIKit
import Async
import PlaytubeSDK
import UIView_Shimmer

class GetPlaylistVideosVC: BaseVC {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var showStack: UIStackView!
    @IBOutlet weak var noPlaylist: UILabel!
    
    // MARK: - Properties
    
    var listID:String? = ""
    var playlistName:String? = ""
    var playlistVideosArray = [PlaylistVideosModel.Datum]()
    
    private var isLoading = true {
        didSet {
            tableView.reloadData()
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
        self.registerCell()
        self.noPlaylist.text = NSLocalizedString("No PlayList found", comment: "No PlayList found")
        isLoading = true
        self.fetchPlaylistVideos()
    }
    
    // Register Cell
    func registerCell() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.separatorStyle = .none
        tableView.register(UINib(resource: R.nib.trendingCell), forCellReuseIdentifier:  R.reuseIdentifier.trendingCell.identifier)
        self.tableView.addPullRefresh { [weak self] in
            self?.isLoading = true
            self?.fetchPlaylistVideos()
        }
    }

    @IBAction func btnBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    private func fetchPlaylistVideos() {
        Async.background {
            let userID = AppInstance.instance.userId ?? 0
            let sessionID = AppInstance.instance.sessionId ?? ""
            let listID = self.listID ?? ""
            PlaylistManager.instance.getPlaylistVideos(User_id: userID, Session_Token: sessionID, List_Id: listID, Limit: 10, completionBlock: { (success, sessionError, error) in
                if success != nil {
                    Async.main {
                        self.playlistVideosArray = success?.data ?? []
                        if self.playlistVideosArray.isEmpty {
                            self.tableView.isHidden = true
                            self.showStack.isHidden = false
                        } else {
                            log.verbose("success")
                            self.tableView.isHidden = false
                            self.showStack.isHidden = true
                        }
                        self.isLoading = false
                        self.tableView.stopPullRefreshEver()
                    }
                } else if sessionError != nil {
                    Async.main {
                        self.isLoading = false
                        self.tableView.stopPullRefreshEver()
                        log.error("sessionError = \(sessionError?.errors!.error_text ?? "")")
                        self.view.makeToast(sessionError?.errors!.error_text)
                    }
                } else {
                    Async.main {
                        self.isLoading = false
                        self.tableView.stopPullRefreshEver()
                        log.error("error = \(error?.localizedDescription ?? "")")
                        self.view.makeToast(error?.localizedDescription)
                    }
                }
            })
        }
    }
    
}

extension GetPlaylistVideosVC: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isLoading {
            return 10
        } else {
            return self.playlistVideosArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.isLoading {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TrendingCell", for: indexPath) as! TrendingCell
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TrendingCell", for: indexPath) as! TrendingCell
            guard let object = self.playlistVideosArray[indexPath.row].video else { return cell }
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
        guard let videoObject = self.playlistVideosArray[indexPath.row].video else { return }
        let newVC = self.tabBarController as! TabbarController
        // newVC.statusBarHiddenDelegate = self
        newVC.handleOpenVideoPlayer(for: videoObject)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
