import UIKit
import Async
import PlaytubeSDK
import Toast_Swift

protocol UserChannelPlaylistVCDelegate: AnyObject {
    func scrollViewDidScroll(scrollView: UIScrollView, tableView: UITableView)
}

class UserChannelPlaylistVC: BaseVC {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var showStack: UIStackView!
    
    // MARK: - Properties
    
    weak var delegate: UserChannelPlaylistVCDelegate?
    private var isLoading = true {
        didSet {
            self.tableView.reloadData()
        }
    }
    var channelID: Int? = 0
    var playlistsArray: [PlaylistModel.MyAllPlaylist] = []
    var parentContorller: NewUserChannelVC!
    
    // MARK: - View Life Cycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initialConfig()
    }
    
    // MARK: - Helper Functions
    
    static func userChannelPlaylistVC() -> UserChannelPlaylistVC {
        let newVC = R.storyboard.library.userChannelPlaylistVC()
        return newVC!
    }
    
    // Initial Config
    func initialConfig() {
        self.registerCell()
        isLoading = true
        self.getChannelPlaylist()
    }
    
    // Register Cell
    func registerCell() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.separatorStyle = .none
        self.tableView.register(UINib(resource: R.nib.playlistTableItem), forCellReuseIdentifier: R.reuseIdentifier.playlistTableItem.identifier)
        self.tableView.addPullRefresh { [weak self] in
            self?.isLoading = true
            self?.getChannelPlaylist()
        }
    }
    
    private func getChannelPlaylist() {
        if Connectivity.isConnectedToNetwork() {
            // self.showProgressDialog(text: NSLocalizedString("Loading...", comment: "Loading..."))
            let channelId = self.channelID ?? 0
            Async.background {
                PlaylistManager.instance.getPlaylistWithChannelId(User_id: channelId, completionBlock: { (success, sessionError, error) in
                    if success != nil {
                        Async.main {
                            self.dismissProgressDialog {
                                log.debug("success")
                                self.playlistsArray = []
                                self.playlistsArray = success?.myAllPlaylists ?? []
                                if !self.playlistsArray.isEmpty {
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
                        Async.main {
                            self.dismissProgressDialog {
                                log.debug("sessionError = \(sessionError?.errors!.error_text ?? "")")
                                self.view.makeToast(sessionError?.errors!.error_text ?? "")
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

// MARK: - Extensions

// MARK: TableView Setup
extension UserChannelPlaylistVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isLoading {
            return 10
        } else {
            return self.playlistsArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isLoading {
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.playlistTableItem.identifier) as! PlaylistTableItem
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.playlistTableItem.identifier) as! PlaylistTableItem
            cell.delegate = self
            cell.presentDelegate = self
            cell.index = indexPath.row
            cell.parentController = self.parentContorller
            let object = self.playlistsArray[indexPath.row]
            cell.bind(object)
            return cell
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !isLoading {
            let vc = R.storyboard.playlist.getPlaylistVideosVC()
            vc?.listID = self.playlistsArray[indexPath.row].listID ?? ""
            vc?.playlistName = self.playlistsArray[indexPath.row].name ?? ""
            self.parentContorller.navigationController?.pushViewController(vc!, animated: true)
        }        
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.setTemplateWithSubviews(isLoading, animate: true, viewBackgroundColor: .systemBackground)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 128
    }
    
}

// MARK: PlaylistTableItemDelegate
extension UserChannelPlaylistVC: PlaylistTableItemDelegate {
    
    func handleRemovePlaylist(index: Int) {
        self.playlistsArray.remove(at: index)
        self.tableView.reloadData()
    }
    
}

// MARK: ShowPresentControllerDelegate
extension UserChannelPlaylistVC: ShowPresentControllerDelegate {
    
    func showController(Index: Int) {
        if Index == 0 {
            let vc = R.storyboard.playlist.createNewPlaylistVC()
            vc?.object = self.playlistsArray[Index]
            self.navigationController?.pushViewController(vc!, animated: true)
        }
    }
    
}

// MARK: UIScrollViewDelegate
extension UserChannelPlaylistVC: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        delegate?.scrollViewDidScroll(scrollView: scrollView, tableView: self.tableView)
    }
    
}
