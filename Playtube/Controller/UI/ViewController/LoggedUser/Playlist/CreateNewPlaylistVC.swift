

import UIKit
import Async
import PlaytubeSDK
class CreateNewPlaylistVC: BaseVC {
    
    @IBOutlet weak var privateBtn: UIButton!
    @IBOutlet weak var playlistNameTextFieldTF: TJTextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var publicBtn: UIButton!
    
    private var privacyCount:Int? = nil
    var object:PlaylistModel.MyAllPlaylist?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    @IBAction func btnBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnSave(_ sender: Any) {
        if(self.playlistNameTextFieldTF.text?.isEmpty)!{
            self.view.makeToast(NSLocalizedString("Please enter playlist name", comment: "Please enter playlist name"))
        }else if self.descriptionTextView.text.isEmpty{
            self.view.makeToast(NSLocalizedString("Please enter playlist description", comment: "Please enter playlist description"))
        }else{
            if self.object != nil{
                self.updatePlaylist()
            }else{
                self.createPlaylist()
            }
        }
    }
    
    private func setupUI(){
        if self.object != nil{
            self.title = NSLocalizedString("update Playlist", comment: "update Playlist")
            self.playlistNameTextFieldTF.text = self.object?.name ?? ""
            self.descriptionTextView.text = self.object?.description ?? ""
            if self.object?.privacy == 1{
                self.privateBtn.setImage(R.image.radio_button_off(), for: .normal)
                self.publicBtn.setImage(R.image.radio_button_on(), for: .normal)
                self.privacyCount = 1
                
            }else{
                self.privateBtn.setImage(R.image.radio_button_on(), for: .normal)
                self.publicBtn.setImage(R.image.radio_button_off(), for: .normal)
                self.privacyCount = 0
                
            }
            
        }else{
            self.title = NSLocalizedString("Create Playlist", comment: "Create Playlist")
            self.privateBtn.setImage(R.image.radio_button_off(), for: .normal)
            self.publicBtn.setImage(R.image.radio_button_off(), for: .normal)
        }
        
        
        let save = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(self.Save))
        self.navigationItem.rightBarButtonItem = save
    }
    
    @IBAction func radioButton(_ sender: UIButton) {
        if sender.tag == 0{
            self.privateBtn.setImage(R.image.radio_button_on(), for: .normal)
            self.publicBtn.setImage(R.image.radio_button_off(), for: .normal)
            self.privacyCount = 0
        }else{
            self.publicBtn.setImage(R.image.radio_button_on(), for: .normal)
            self.privateBtn.setImage(R.image.radio_button_off(), for: .normal)
            self.privacyCount = 1
        }
    }
    @objc func Save(){        
        if(self.playlistNameTextFieldTF.text?.isEmpty)!{
            self.view.makeToast(NSLocalizedString("Please enter playlist name", comment: "Please enter playlist name"))
        }else if self.descriptionTextView.text.isEmpty{
            self.view.makeToast(NSLocalizedString("Please enter playlist description", comment: "Please enter playlist description"))
        }else{
            if self.object != nil{
                self.updatePlaylist()
            }else{
                self.createPlaylist()
            }
        }
    }
    private func createPlaylist(){
        
        if Connectivity.isConnectedToNetwork(){
            //self.showProgressDialog(text: NSLocalizedString("Loading...", comment: "Loading..."))
            let playlistName = self.playlistNameTextFieldTF.text ?? ""
            let description = self.descriptionTextView.text ?? ""
            let privacyCount = self.privacyCount ?? 0
            let userID = AppInstance.instance.userId ?? 0
            let sessionID = AppInstance.instance.sessionId ?? ""
            Async.background{
                PlaylistManager.instance.addPlaylist(User_id: userID, Session_Token: sessionID, Name: playlistName, Description: description, Privacy: privacyCount
                    , completionBlock: { (success, sessionError, error) in
                        if success != nil{
                            Async.main{
                                self.dismissProgressDialog {
                                    NotificationCenter.default.post(name: Notification.Name("updatePlaylist"), object: nil)
                                    self.navigationController?.popViewController(animated: true)
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
    private func updatePlaylist(){
        
        if Connectivity.isConnectedToNetwork(){
            self.showProgressDialog(text: NSLocalizedString("Loading...", comment: "Loading..."))
            let playlistName = self.playlistNameTextFieldTF.text ?? ""
            let description = self.descriptionTextView.text ?? ""
            let privacyCount = self.privacyCount ?? 0
            let userID = AppInstance.instance.userId ?? 0
            let sessionID = AppInstance.instance.sessionId ?? ""
            let listID = self.object?.listID ?? ""
            Async.background{
                PlaylistManager.instance.updatePlaylist(User_id: userID, Session_Token: sessionID, List_id: listID, Name: playlistName, Description: description, Privacy: privacyCount, completionBlock: { (success, sessionError, error) in
                    if success != nil{
                        Async.main{
                            self.dismissProgressDialog {
                                self.navigationController?.popViewController(animated: true)
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
