import UIKit
import Async
import PlaytubeSDK

protocol ChangeVideosVCDelegate: AnyObject {
    func scrollViewDidScroll(scrollView: UIScrollView, tableView: UITableView)
}

class ChangeVideosVC: BaseVC {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var showStack: UIStackView!
    @IBOutlet weak var noVideoLbl: UILabel!
    weak var delegate: ChangeVideosVCDelegate?
    
    private var isLoading = true
    var channelVideos = [VideoDetail]()
    var heightTableView:((_ count: Int, _ identifire: Int) -> ())?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(self.video_Upload(notification:)), name: Notification.Name("VideoUploded"), object: nil)
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(UINib(resource: R.nib.playerNextTableItem), forCellReuseIdentifier: R.reuseIdentifier.playerNextTableItem.identifier)
        isLoading = true
        
        /*DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.isLoading = false
        }*/
        
//        self.fetchMyChannelVideos()
        
        self.tableView.addPullRefresh { [weak self] in
            self?.isLoading = true
            self?.fetchMyChannelVideos()
            /*DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self?.isLoading = false
                self?.tableView.stopPullRefreshEver()
            }*/
        }
        //self.fetchMyChannelVideos()
        //self.noVideoLbl.text = NSLocalizedString("No videos found for now!", comment: "No videos found for now!")
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("videooooooo")
    }
    
    @objc func video_Upload(notification: NSNotification){
//        self.fetchMyChannelVideos()
    }
    
    func reloadTableView() {
        DispatchQueue.main.async {
            
            if !self.channelVideos.isEmpty {
                print("showTableView")
                self.isLoading = false
                self.showStack.isHidden = true
                self.tableView.isHidden = false
                
            }else{
                self.isLoading = false
                print("showStack")
                self.showStack.isHidden = false
                self.tableView.isHidden = true
            }
            self.tableView.reloadData()
        }
    }
    
    static func changeVideosVC() -> ChangeVideosVC {
        let newVC = R.storyboard.loggedUser.changeVideosVC()
        return newVC!
    }
    
    private func fetchMyChannelVideos(){
        if Connectivity.isConnectedToNetwork(){
            //self.showProgressDialog(text: NSLocalizedString("Loading...", comment: "Loading...")) 39678
            let userID = AppInstance.instance.userId ?? 0
            Async.background({
                MyChannelManager.instance.getChannelVideos(User_id: 39678, Offset:0, Limit:10, completionBlock: { (success, sessionError, error) in
                    if success != nil{
                        Async.main({
                            self.dismissProgressDialog { [self] in
                                log.verbose("SUCCESS")
                                self.channelVideos.removeAll()
                                self.channelVideos = success?.data ?? []
                                if !self.channelVideos.isEmpty{
                                    //self.tableView.reloadData()
                                    self.showStack.isHidden = true
                                    self.tableView.isHidden = false
                                }else{
                                    self.showStack.isHidden = false
                                    self.tableView.isHidden = true
                                }
                                self.isLoading = false
                                self.tableView.stopPullRefreshEver()
                                DispatchQueue.main.async {
                                    self.tableView.reloadData()
                                    NotificationCenter.default.post(name: NSNotification.Name("ReloadContainerView"), object: nil)
                                }
                            }                            
                        })
                    }else if sessionError != nil{
                        self.dismissProgressDialog {
                            self.view.makeToast(sessionError?.errors!.error_text ?? "")
                            log.verbose("sessionError = \(sessionError?.errors?.error_text ?? "")")
                        }
                        
                    }else{
                        self.dismissProgressDialog {
                            self.view.makeToast(error?.localizedDescription ?? "")
                            
                            log.verbose("error = \(error?.localizedDescription ?? "")")
                        }
                    }
                })
            })
        }else{
            self.view.makeToast(InterNetError)
        }
    }
}
extension ChangeVideosVC:UITableViewDelegate,UITableViewDataSource{
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        delegate?.scrollViewDidScroll(scrollView: scrollView, tableView: self.tableView)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isLoading {
            return 10
        } else{
            return self.channelVideos.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isLoading {
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.playerNextTableItem.identifier, for: indexPath) as! PlayerNextTableItem
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.playerNextTableItem.identifier, for: indexPath) as! PlayerNextTableItem
            let object = self.channelVideos[indexPath.row]
            cell.bind(object)
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
        AppInstance.instance.addCount = AppInstance.instance.addCount! + 1
        let videoObject = self.channelVideos[indexPath.row]
        let newVC = self.tabBarController as! TabbarController
        // newVC.statusBarHiddenDelegate = self
        newVC.handleOpenVideoPlayer(for: videoObject)
    }
}

extension ChangeVideosVC:ShowCreatePlayListDelegate{
    func showCreatePlaylist(Status: Bool) {
        let vc = R.storyboard.playlist.createNewPlaylistVC()
        self.navigationController?.pushViewController(vc!, animated: true)
    }
}
extension ChangeVideosVC:ShowPresentControllerDelegate{
    
    func showController(Index: Int) {
        if Index == 0{
            self.getPlaylist(index: Index)
        }
    }
    
    func getPlaylist(index:Int){
        if Connectivity.isConnectedToNetwork(){
            self.showProgressDialog(text: NSLocalizedString("Loading...", comment: "Loading..."))
            let userID = AppInstance.instance.userId ?? 0
            let sessionID = AppInstance.instance.sessionId ?? ""
            Async.background{
                PlaylistManager.instance.getPlaylist(User_id: userID, Session_Token: sessionID, completionBlock: { (success, sessionError, error) in
                    if success != nil{
                        Async.main{
                            self.dismissProgressDialog {
                                let vc = R.storyboard.popups.playlistsPopupVC()
                                vc?.videoID = self.channelVideos[index].id ?? 0
                                vc?.playlistArray = success?.myAllPlaylists ?? []
                                vc?.delegate = self
                                self.present(vc!, animated: true, completion: nil)
                            }
                        }
                    }else if sessionError != nil{
                        self.dismissProgressDialog {
                            log.verbose("sessionError = \(sessionError?.errors?.error_text ?? "")")
                            self.view.makeToast(sessionError?.errors?.error_text ?? "")
                        }
                        
                    }else{
                        self.dismissProgressDialog {
                            log.verbose("Error = \(error?.localizedDescription ?? "")")
                            self.view.makeToast(error?.localizedDescription ?? "")
                        }
                    }
                })
            }
        }else{
            self.dismissProgressDialog {
                self.view.makeToast(InterNetError)
            }
        }
    }
}
