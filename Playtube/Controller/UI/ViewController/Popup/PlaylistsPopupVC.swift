import UIKit
import Async
import PlaytubeSDK

class PlaylistsPopupVC: BaseVC {
    
    @IBOutlet weak var createNewButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var playlistLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    
    var videoID: Int? = 0
    var listID: String? = ""
    var playlistArray = [PlaylistModel.MyAllPlaylist]()
    var delegate: ShowCreatePlayListDelegate?
    
    //MARK: - Life Cycle Functions -
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        tableView.removeObserver(self, forKeyPath: "contentSize")
        super.viewWillDisappear(true)
    }
    
    //MARK: - Selectors -
    @IBAction func createNewPressed(_ sender: Any) {
        self.view.endEditing(true)
        self.dismiss(animated: true) {
            self.delegate?.showCreatePlaylist(Status: true)
        }
    }
    
    @IBAction func cancelPressed(_ sender: Any) {
        self.view.endEditing(true)
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK: - Helper Functions -
    private func setupUI() {
        self.tableView.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
        self.tableView.separatorStyle = .none
        tableView.register(UINib(resource: R.nib.showPlaylistTableItem), forCellReuseIdentifier: R.reuseIdentifier.showPlaylistTableItem.identifier)
    }
    
    func addToPlaylist(videoID:Int, listID:String){
        if Connectivity.isConnectedToNetwork(){
            self.showProgressDialog(text: NSLocalizedString("Loading...", comment: "Loading..."))
            let userID = AppInstance.instance.userId ?? 0
            let sessionID = AppInstance.instance.sessionId ?? ""
            Async.background{
                PlaylistManager.instance.addToPlaylist(User_id: userID, Session_Token: sessionID, List_id: listID, Video_Id: videoID, completionBlock: { (success, sessionError, error) in
                    if success != nil{
                        Async.main{
                            self.dismissProgressDialog {
                                self.view.makeToast(success?.message)
                                self.dismiss(animated: true, completion: nil)
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

extension PlaylistsPopupVC: UITableViewDelegate, UITableViewDataSource {
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if(keyPath == "contentSize"){
            if let newvalue = change?[.newKey] {
                let newsize  = newvalue as! CGSize
                let spacing = (self.view.safeAreaBottom + self.view.safeAreaTop + 50.0)
                let mainHeight = self.view.frame.height - spacing
                if mainHeight > (newsize.height) {
                    self.tableViewHeight.constant = newsize.height
                }else {
                    self.tableViewHeight.constant = 200.0
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.playlistArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let  cell = tableView.dequeueReusableCell(withIdentifier:R.reuseIdentifier.showPlaylistTableItem.identifier ) as! ShowPlaylistTableItem
        let object = self.playlistArray[indexPath.row]
        cell.selectionStyle = .none
        cell.bind(object)
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let object = self.playlistArray[indexPath.row]
        self.addToPlaylist(videoID: self.videoID ?? 0, listID: object.listID ?? "")
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40.0
    }
}
