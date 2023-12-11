import UIKit
import Async
import PlaytubeSDK

import UIView_Shimmer
import DropDown

class profilePlaylistCell : UITableViewCell, ShimmeringViewProtocol {
    
    @IBOutlet weak var moreBtn: UIButton!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var desLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var thumbnailImage: UIImageView!
    @IBOutlet weak var opacityView: UIView!
    
    private var dropDown = DropDown()
    var parentController: BaseVC!
    var object: PlaylistModel.MyAllPlaylist?
    var index: Int = 0
    var delegate: PlaylistTableItemDelegate?
    var presentDelegate: ShowPresentControllerDelegate?
    
    var shimmeringAnimatedItems: [UIView] {
        [
            opacityView,
            moreBtn,
            descriptionLabel,
            desLabel,
            nameLabel,
            countLabel,
            thumbnailImage
        ]
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.customizeDropDownFunc()
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func morePRessed(_ sender: Any) {
        self.dropDown.show()
        
    }
    func bind(_ object:PlaylistModel.MyAllPlaylist){
        self.object = object
        self.descriptionLabel.text = object.description ?? ""
        self.countLabel.text = "\(object.count ?? 0)"
        self.nameLabel.text = object.name ?? ""
        self.desLabel.text = "\(object.count ?? 0) Videos"
        let thumbnailImage = URL(string: object.thumbnail ?? "")
        self.thumbnailImage.sd_setImage(with: thumbnailImage , placeholderImage:R.image.maxresdefault())
    }
    private  func customizeDropDownFunc(){
        dropDown.dataSource = [NSLocalizedString("Edit", comment: "Edit"),NSLocalizedString("Delete", comment: "Delete")]
        dropDown.anchorView = self.moreBtn
        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            if index == 0{
                self.presentDelegate?.showController(Index: self.index)
            }else if index == 1{
                self.deletePlaylist()
            }
            log.verbose("Selected item: \(item) at index: \(index)")
        }
        dropDown.width = 200
        dropDown.direction = .bottom
        dropDown.backgroundColor = .white
        dropDown.textColor = .black
        dropDown.shadowOpacity = 0.2
        dropDown.bottomOffset = .init(x: 0, y: self.moreBtn.bounds.height)
    }
    
    private func deletePlaylist() {
        if Connectivity.isConnectedToNetwork() {
            self.parentController?.showProgressDialog(text: NSLocalizedString("Loading...", comment: "Loading..."))
            let userID = AppInstance.instance.userId ?? 0
            let sessionID = AppInstance.instance.sessionId ?? ""
            let listID = self.object?.listID ?? ""
            Async.background {
                PlaylistManager.instance.deletePlaylist(User_id: userID, Session_Token: sessionID, List_id: listID, completionBlock: { (success, sessionError, error) in
                    if success != nil {
                        Async.main {
                            self.parentController?.dismissProgressDialog {
                                log.debug("success")
                                self.delegate?.handleRemovePlaylist(index: self.index)
                            }
                        }
                    } else if sessionError != nil {
                        Async.main {
                            self.parentController?.dismissProgressDialog {
                                log.debug("sessionError = \(sessionError?.errors!.error_text ?? "")")
                                self.parentController?.view.makeToast(sessionError?.errors!.error_text)
                            }
                        }
                    } else {
                        Async.main {
                            self.parentController?.dismissProgressDialog {
                                log.debug("error = \(error?.localizedDescription ?? "")")
                                obj_appDelegate.window?.rootViewController?.view.makeToast(error?.localizedDescription)
                            }
                        }
                    }
                })
            }
        } else {
            self.parentController?.view.makeToast(InterNetError)
        }
    }
}

class ChannelPlaylistVC: BaseVC {
    
    @IBOutlet weak var tableView: UITableView!
    
    var scViewHeight = 0
    
    private var isLoading = true {
        didSet {
            //            DispatchQueue.main.async { [self] in
            //                if !self.playlistsArray.isEmpty {
            //                    self.showStack.isHidden = true
            //                    self.tableView.isHidden = false
            //                }else{
            //                    self.showStack.isHidden = false
            //                    self.tableView.isHidden = true
            //                }
            //                self.tableView.reloadData()
            //            }
        }
    }
    
    @IBOutlet weak var showStack: UIStackView!
    
    @IBOutlet weak var noPlayListLbl: UILabel!
    var playlistsArray = [PlaylistModel.MyAllPlaylist]()
    var parentVC: NewProfileVC?
    var heightTableView:((_ count: Int, _ identifire: Int) -> ())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.setupUI()
        NotificationCenter.default.addObserver(self, selector: #selector(self.video_Upload(notification:)), name: Notification.Name("VideoUploded"), object: nil)
        
        //self.scViewHeight = Int(self.scView.frame.height)
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        isLoading = true
        //        self.myChannelPlayListfetchData()
        
        /* self.tableView.addPullRefresh { [weak self] in
         self?.isLoading = true
         self?.myChannelPlayListfetchData()
         }*/
        
        //self.noPlayListLbl.text = NSLocalizedString("No Playlist found for now!", comment: "No Playlist found for now!")
    }
    
    @objc func video_Upload(notification: NSNotification){
        let parentViewController = self.parent as! NewProfileVC
        //        parentViewController.moveToViewController(at: 0)
    }
    
    func reloadTableView() {
        DispatchQueue.main.async {
            self.isLoading = false
            if !self.playlistsArray.isEmpty {
                print("showTableView")
                self.showStack.isHidden = true
                self.tableView.isHidden = false
            }else{
                print("showStack")
                self.showStack.isHidden = false
                self.tableView.isHidden = true
            }
            self.tableView.reloadData()
        }
    }
    
    static func channelPlaylistVC() -> ChannelPlaylistVC {
        let newVC = R.storyboard.loggedUser.channelPlaylistVC()
        return newVC!
    }
    
    private func myChannelPlayListfetchData(){
        if Connectivity.isConnectedToNetwork(){
            //self.showProgressDialog(text: NSLocalizedString("Loading...", comment: "Loading..."))
            let userID = AppInstance.instance.userId ?? 0
            let sessionID = AppInstance.instance.sessionId ?? ""
            Async.background({
                PlaylistManager.instance.getPlaylist(User_id: userID, Session_Token: sessionID, completionBlock: { (success, sessionError, error) in
                    if success != nil{
                        Async.main({ [self] in
                            log.debug("success")
                            self.playlistsArray = (success?.myAllPlaylists)!
                            if !self.playlistsArray.isEmpty {
                                self.showStack.isHidden = true
                                self.tableView.isHidden = false
                            }else{
                                self.showStack.isHidden = false
                                self.tableView.isHidden = true
                            }
                            self.isLoading = false
                            itemsCount = self.playlistsArray.count
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                                print(self.playlistsArray.count)
                                NotificationCenter.default.post(name: NSNotification.Name("ReloadContainerView"), object: nil)
                            }
                            self.tableView.stopPullRefreshEver()
                            
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

extension ChannelPlaylistVC: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isLoading
        {
            return 10
        }
        else{
            return self.playlistsArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isLoading
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "profilePlaylistCell", for: indexPath) as! profilePlaylistCell
            return cell
        }
        else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "profilePlaylistCell", for: indexPath) as! profilePlaylistCell
            let object = self.playlistsArray[indexPath.row]
            cell.index = indexPath.row
            cell.delegate = self
            cell.presentDelegate = self
            cell.parentController = self.parentVC
            cell.bind(object)
            return cell
        }

    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        if AppInstance.instance.addCount == AppSettings.interestialCount {
//            AppInstance.instance.addCount = 0
//        }
//        
//        AppInstance.instance.addCount = AppInstance.instance.addCount! + 1
        let vc = R.storyboard.playlist.getPlaylistVideosVC()
        vc?.listID = self.playlistsArray[indexPath.row].listID ?? ""
        vc?.playlistName = self.playlistsArray[indexPath.row].name ?? ""
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    func tableView(_ tableView: UITableView,
                   willDisplay cell: UITableViewCell,
                   forRowAt indexPath: IndexPath) {
        cell.setTemplateWithSubviews(isLoading, animate: true, viewBackgroundColor: .systemBackground)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
}

// MARK: PlaylistTableItemDelegate
extension ChannelPlaylistVC: PlaylistTableItemDelegate {
    func handleRemovePlaylist(index: Int) {
        self.playlistsArray.remove(at: index)
        self.tableView.reloadData()
    }
    
}

extension ChannelPlaylistVC: ShowPresentControllerDelegate {
    func showController(Index: Int) {
        if Index == 0 {
            let vc = R.storyboard.playlist.createNewPlaylistVC()
            vc?.object = self.playlistsArray[Index]
            self.navigationController?.pushViewController(vc!, animated: true)
        }
    }
}
