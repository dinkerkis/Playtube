
import UIKit
import Async
import PlaytubeSDK
import GoogleMobileAds

class LibraryPlaylistVC: BaseVC {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var showStack: UIStackView!
    @IBOutlet weak var noVideoLbl: UILabel!
    var interstitial: GADInterstitialAd!
    var playlistsArray = [PlaylistModel.MyAllPlaylist]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.myChannelPlayListfetchData()
        self.noVideoLbl.text = NSLocalizedString("No videos found for now!", comment: "No videos found for now!")
    }
    
    private func setupUI(){
        self.title = NSLocalizedString("Playlist", comment: "Playlist")
        if AppSettings.shouldShowAddMobBanner{
            let request = GADRequest()
            GADInterstitialAd.load(withAdUnitID: AppSettings.interestialAddUnitId,
                                   request: request,
                                   completionHandler: { (ad, error) in
                                    if let error = error {
                                        print("Failed to load interstitial ad with error: \(error.localizedDescription)")
                                        return
                                    }
                                    self.interstitial = ad
                                   }
            )
        }
        
        self.tableView.separatorStyle = .none
        tableView.register(UINib(resource: R.nib.playlistTableItem), forCellReuseIdentifier: R.reuseIdentifier.playlistTableItem.identifier)
    }
    func CreateAd() -> GADInterstitialAd {
        GADInterstitialAd.load(withAdUnitID: AppSettings.interestialAddUnitId,
                               request: GADRequest(),
                               completionHandler: { (ad, error) in
                                if let error = error {
                                    print("Failed to load interstitial ad with error: \(error.localizedDescription)")
                                    return
                                }
                                self.interstitial = ad
                               }
        )
        return  self.interstitial
    }
    
    private func myChannelPlayListfetchData(){
        if Connectivity.isConnectedToNetwork(){
            self.showProgressDialog(text: NSLocalizedString("Loading...", comment: "Loading..."))
            let userID = AppInstance.instance.userId ?? 0
            let sessionID = AppInstance.instance.sessionId ?? ""
            Async.background({
                PlaylistManager.instance.getPlaylist(User_id: userID, Session_Token: sessionID, completionBlock: { (success, sessionError, error) in
                    if success != nil{
                        Async.main({
                            self.dismissProgressDialog {
                                log.debug("success")
                                self.playlistsArray = (success?.myAllPlaylists)!
                                if !self.playlistsArray.isEmpty{
                                    self.tableView.reloadData()
                                    self.showStack.isHidden = true
                                    self.tableView.isHidden = false
                                    UserDefaults.standard.setPlaylistImage(value: success?.myAllPlaylists?.last?.thumbnail ?? "", ForKey: "playlist")
                                }else{
                                    self.showStack.isHidden = false
                                    self.tableView.isHidden = true
                                }
                            }
                        })
                    }else if sessionError != nil{
                        Async.main({
                            self.dismissProgressDialog {
                                log.debug("sessionError = \(sessionError?.errors!.error_text)")
                                self.view.makeToast(sessionError?.errors!.error_text)
                            }
                        })
                    }else{
                        Async.main({
                            self.dismissProgressDialog {
                                log.debug("error = \(error?.localizedDescription)")
                                self.view.makeToast(error?.localizedDescription)
                            }
                        })
                    }
                })
            })
            
        }else {
            self.view.makeToast(InterNetError)
        }
    }
}

extension LibraryPlaylistVC:UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.playlistsArray.count 
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:R.reuseIdentifier.playlistTableItem.identifier) as! PlaylistTableItem
        let object = self.playlistsArray[indexPath.row]
        cell.parentController = self
        cell.index = indexPath.row
        cell.presentDelegate = self
        cell.bind(object)
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 115.0
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = R.storyboard.playlist.getPlaylistVideosVC()
        vc?.listID = self.playlistsArray[indexPath.row].listID ?? ""
        vc?.playlistName = self.playlistsArray[indexPath.row].name ?? ""
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
}
extension LibraryPlaylistVC:ShowPresentControllerDelegate{
    func showController(Index: Int) {
        if Index == 0{
            let vc = R.storyboard.playlist.createNewPlaylistVC()
            vc?.object = self.playlistsArray[Index]
            self.navigationController?.pushViewController(vc!, animated: true)
        }
    }
}
