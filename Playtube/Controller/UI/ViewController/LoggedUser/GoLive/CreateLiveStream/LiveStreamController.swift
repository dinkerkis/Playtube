//
//  LiveStreamController.swift
//  Playtube
//
//  Created by Abdul Moid on 19/03/2021.
//  Copyright © 2021 Muhammad Haris Butt. All rights reserved.
//

import UIKit
import AgoraRtcKit
import AVKit

class LiveStreamController: BaseVC, UITextViewDelegate {
    
    @IBOutlet weak var userImage: RoundImage!
    @IBOutlet weak var viewLabel: RoundLabel!
    @IBOutlet weak var liveLabel: RoundLabel!
    @IBOutlet weak var timeLabel: RoundLabel!
    @IBOutlet weak var itemsView: UIView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var micBtn: UIButton!
    @IBOutlet weak var cameraBtn: UIButton!
    @IBOutlet weak var videoBtn: UIButton!
    @IBOutlet weak var magicBtn: UIButton!
    @IBOutlet weak var sendBtn: RoundButton!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var liveView: UIView!
    
    // Defines localView
    var localView: UIView!
    // Defines remoteView
    var remoteView: UIView!
    var isJoin = 0
    var isFrontCamera = 1
    var isCameraOff = 0
    var isMicOn = 1
    var isMagic = 0
    var count = 0
    var minute = 0
    
    // Defines agoraKit
    var agoraKit: AgoraRtcEngineKit?
    var localVideo: AgoraRtcVideoCanvas?
    var live_comments = [[String:Any]]()
    var liveData = [String:Any]()
    var streamName = ""
    var post_id = ""
    var video_id = ""
    var userImages = ""
    var postUrl = ""
    //    let status = Reach().connectionStatus()
    
    //Temp
    var comments = [String]()
    
    var timer: Timer?
    var postTimer: Timer?
    var secTimer: Timer?
    
    var frontCameraDeviceInput: AVCaptureDeviceInput?
    var backCameraDeviceInput: AVCaptureDeviceInput?
    var captureSession = AVCaptureSession()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.agoraKit?.delegate = self
        self.textView.delegate = self
        self.textView.text = NSLocalizedString("Add Comment here", comment: "Add Comment here")
        self.viewLabel.text = "0 Views"
        self.timeLabel.text = "\(minute)\(":")\(count)"
        self.sendBtn.tintColor = UIColor.hexStringToUIColor(hex: "000000")
        // This function initializes the local and remote video views
        initView()
        // The following functions are used when calling Agora APIs
        initializeAgoraEngine()
        setChannelProfile()
        setClientRole()
        setupLocalVideo()
        joinChannel()
        if (self.isJoin == 1){
            self.itemsView.isHidden = true
            self.stackView.isHidden = true
            self.timeLabel.isHidden = true
            self.liveLabel.isHidden = false
            self.userImage.isHidden = false
            let url = URL(string: self.userImages)
            //            self.userImage.kf.setImage(with: url)
        }
        else{
            self.liveLabel.isHidden = true
            self.userImage.isHidden = true
        }
        
        setupTableView()
    }
    
    func setupTableView(){
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.separatorStyle = .none
        self.tableView.tableFooterView = UIView()
        self.tableView.register(UINib(nibName: "LiveTableViewCell", bundle: nil), forCellReuseIdentifier: "LiveTableViewCell")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if (self.isJoin == 1){
            self.timer = Timer.scheduledTimer(timeInterval: 3.0,
                                              target: self,
                                              selector: #selector(self.getCommentsTimer),
                                              userInfo: nil,
                                              repeats: true)
            self.postTimer = Timer.scheduledTimer(timeInterval: 5.0,
                                                  target: self,
                                                  selector: #selector(self.getPostTimer),
                                                  userInfo: nil,
                                                  repeats: true)
        }
        else{
            self.createLive(streamName: streamName)
        }
    }
    
    ///Network Connectivity.
    @objc func networkStatusChanged(_ notification: Notification) {
        if let userInfo = notification.userInfo {
            let status = userInfo["Status"] as! String
            print(status)
            
        }
        
    }
    
    @objc func getCommentsTimer(){
        if self.isJoin == 0{
            self.getLiveComments(role: "live", postId: Int(self.post_id) ?? 0, offset: "")
        }
        else{
            self.getLiveComments(role: "story", postId: Int(self.post_id) ?? 0, offset: "")
        }
    }
    @objc func getPostTimer(){
        //        self.getLiveComments(postId: Int(self.post_id) ?? 0, offset: "")
        self.getPost(postId: self.post_id)
    }
    
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if (self.textView.text == NSLocalizedString("Add Comment here", comment: "Add Comment here")){
            self.textView.text = nil
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if (self.textView.text == nil) || (self.textView.text == " ") || (self.textView.text.isEmpty == true){
            self.textView.text = NSLocalizedString("Add Comment here", comment: "Add Comment here")
        }
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        //           remoteView.frame = self.view.bounds
        if self.isJoin == 1{
            self.remoteView.frame = self.liveView.bounds
        }
        else{
            self.localView.frame = self.liveView.bounds
        }
        //            CGRect(x: self.view.bounds.width - 90, y: 0, width: 90, height: 0)
    }
    func initView() {
        // Initializes the remote video view. This view displays video when a remote host joins the channel
        //remoteView = UIView()
        //self.view.addSubview(remoteView)
        
        // Initializes the local video view. This view displays video when the local user is a host
        
        if self.isJoin == 1{
            remoteView = UIView()
            self.liveView.addSubview(remoteView)
        }
        else{
            localView = UIView()
            self.liveView.addSubview(localView)
        }
        
    }
    
    func initializeAgoraEngine() {
        self.agoraKit = AgoraRtcEngineKit.sharedEngine(withAppId: "c55b9bda665042809b61dfeb3f3832e0", delegate: self)
    }
    func setChannelProfile(){
        self.agoraKit?.setChannelProfile(.liveBroadcasting)
    }
    
    func setClientRole(){
        if (self.isJoin == 1){
            self.agoraKit?.setClientRole(.audience)
            self.agoraKit?.muteLocalAudioStream(true)
        }
        else{
            self.agoraKit?.setClientRole(.broadcaster)
            self.agoraKit?.muteLocalAudioStream(false)
        }
    }
    
    func leaveChannel() {
        self.agoraKit?.leaveChannel(nil)
    }
    
    
    func setupLocalVideo() {
        if self.isJoin == 0{
            agoraKit?.enableVideo()
            let videoCanvas = AgoraRtcVideoCanvas()
            videoCanvas.uid = 0
            videoCanvas.renderMode = .hidden
            videoCanvas.view = localView
            agoraKit?.setupLocalVideo(videoCanvas)
        }
        else{
            agoraKit?.enableVideo()
            self.agoraKit?.stopEchoTest()
        }
        self.secTimer =  Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.secTTimer), userInfo: nil, repeats: true)
    }
    
    @objc func secTTimer(){
        if (self.count == 60){
            self.minute += 1
            self.count = 0
        }
        self.count = self.count + 1
        self.timeLabel.text = "\(minute)\(":")\(count)"
    }
    
    func removeFromParent(_ canvas: AgoraRtcVideoCanvas?) -> UIView? {
        if let it = canvas, let view = it.view {
            let parent = view.superview
            if parent != nil {
                view.removeFromSuperview()
                return parent
            }
        }
        return nil
    }
    
    func joinChannel(){
        let number = UInt32.random(in: UInt32.min...UInt32.max)
        self.streamName = "\(number)"
        self.agoraKit?.joinChannel(byToken: nil, channelId: self.streamName, info: nil, uid: 0, joinSuccess: { (channel, uid, elapsed) in
            print(channel)
            if (self.isJoin == 1){
                self.timer = Timer.scheduledTimer(timeInterval: 3.0,
                                                  target: self,
                                                  selector: #selector(self.getCommentsTimer),
                                                  userInfo: nil,
                                                  repeats: true)
                self.postTimer = Timer.scheduledTimer(timeInterval: 5.0,
                                                      target: self,
                                                      selector: #selector(self.getPostTimer),
                                                      userInfo: nil,
                                                      repeats: true)
            }
            else{
                self.createLive(streamName: self.streamName)
            }
        })
    }
    
    
    private func getPost(postId: String){
        //
        //            performUIUpdatesOnMain {
        //                GetPostByIdManager.sharedInstance.getPost(post_id: postId) { (success, authError, error) in
        //                    if success != nil{
        //                        self.liveData = success!.post_data
        //                        if let views = self.liveData["videoViews"] as? String{
        //                            self.viewLabel.text = "\(views)\(" ")\("Views")"
        //                        }
        //                    }
        //                    else if authError != nil{
        //                        self.view.makeToast(authError?.errors.errorText)
        //                    }
        //                    else if error != nil{
        //                        self.view.makeToast(error?.localizedDescription)
        //                    }
        //                }
        //            }
        
    }
    
    
    private func createLive(streamName: String) {
        
        let userID = AppInstance.instance.userId ?? 0
        let sessionID = AppInstance.instance.sessionId ?? ""
        GoLiveManager.instance.createLiveStream(streamName: self.streamName,userid: userID, type: "create", Session_Token: sessionID) { (success, sessionError, err) in
            if success != nil {
                guard let post_id = success?["post_id"] as? Int else { return }
                self.post_id = "\(post_id)"
                self.view.makeToast("You are Live Now")
            }else{
                self.view.makeToast("Error")
            }
        }
    }
    
    private func getLiveComments(role:String,postId: Int,offset: String){
        let userID = AppInstance.instance.userId ?? 0
        let sessionID = AppInstance.instance.sessionId ?? ""
        GoLiveManager.instance.checkLiveComments(userid: userID, Session_Token: sessionID, postID: self.post_id) { (success, sessionErr, Err) in
            if success != nil {
                guard let commnet = success else { return }
                guard let commentData = commnet[""] as? [[String : Any]] else { return }
                self.live_comments = commentData
                self.tableView.reloadData()
            }else if sessionErr != nil {
                self.view.makeToast("Error getting comments")
            }else {
                self.view.makeToast("Error getting comments")
            }
        }
    }
    
    private func createComment(comment: String) {
        
        //Add temp comment to array
        self.comments.append(self.textView.text)
        self.tableView.reloadData()
        
        let userID = AppInstance.instance.userId ?? 0
        let sessionID = AppInstance.instance.sessionId ?? ""
        GoLiveManager.instance.commentOnStream(commnet: comment, userid: userID, Session_Token: sessionID, videoID: self.post_id) { (success, sessionErr, Err) in
            if success != nil {
                
                // when commnet is posted successfully
                self.textView.text = nil
                self.tableView.reloadData()
            }else if sessionErr != nil{
                self.view.makeToast("Error Posting commnet")
            }else {
                self.view.makeToast("Error Posting comment")
            }
        }
        //        switch status {
        //        case .unknown, .offline:
        //            self.view.makeToast(NSLocalizedString("Internet Connection Failed", comment: "Internet Connection Failed"))
        //        case .online(.wwan),.online(.wiFi):
        //            var text: String? = nil
        //            if (self.textView.text) == NSLocalizedString("Add a comment here", comment: "Add a comment here") || ((self.textView.text) == "") {
        //                self.view.makeToast(NSLocalizedString("Please enter comment text", comment: "Please enter comment text"))
        //            }
        //            else{
        //                var postId = ""
        //                if let post_id = self.liveData["post_id"] as? String{
        //                    postId = post_id
        //                }
        //                CreateCommentsManager.sharedInstance.createComment(audio_data: nil, data: nil, postId: postId, text: self.textView.text) { (success, authError, error) in
        //                    if (success != nil) {
        //                        self.textView.resignFirstResponder()
        //                        self.textView.text = NSLocalizedString("Add a comment here", comment: "Add a comment here")
        //                    }
        //                    else if (authError != nil) {
        //                        self.view.makeToast(authError?.errors.errorText)
        //                    }
        //
        //                    else if (error != nil){
        //                        self.view.makeToast(error?.localizedDescription)
        //                    }
        //
        //                }
        //            }
        //        }
    }
    
    func deleteLive(postId: String){
        let sessionID = AppInstance.instance.sessionId ?? ""
        let userID = AppInstance.instance.userId ?? 0
        GoLiveManager.instance.endStream(postID: postId, Session_Token: sessionID, type: "delete", userid: userID) { (success, sessionError, err) in
            if success != nil {
                self.leaveChannel()
                self.endLive()
                //                    self.dismiss(animated: true, completion: nil)
            }else if sessionError != nil{
                
            }else{
                
            }
        }
        
        //        switch status {
        //        case .unknown, .offline:
        //            self.view.makeToast(NSLocalizedString("Internet Connection Failed", comment: "Internet Connection Failed"))
        //        case .online(.wwan),.online(.wiFi):
        //            DeleteLiveManager.sharedInstance.deleteLive(post_id: Int(postId) ?? 0) { (success, authError, error) in
        //                if (success != nil){
        //                    print(success?.message)
        //                }
        //                else if (authError != nil){
        //                    print(authError?.errors?.errorText)
        //                }
        //                else if (error != nil){
        //                    print(error?.localizedDescription)
        //                }
        //            }
        //
        //        }
    }
    
    @IBAction func Send(_ sender: Any) {
        if !textView.text.isEmpty {
            self.createComment(comment: self.textView.text)
        }
    }
    
    @IBAction func Share(_ sender: Any) {
        //        self.selectedIndex = sender.tag
        //        let vc = StoryBoard.instantiateViewController(withIdentifier: "ShareVC") as! ShareController
        //        vc.delegate = self
        //        vc.modalPresentationStyle = .overFullScreen
        //        vc.modalTransitionStyle = .crossDissolve
        //        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func Camera(_ sender: Any) {
        if (self.isFrontCamera == 1){
            let backCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)
            self.agoraKit?.switchCamera()
            self.isFrontCamera = 2
        }
        else{
            let frontCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front)
            self.agoraKit?.switchCamera()
            self.isFrontCamera = 1
        }
    }
    
    
    @IBAction func Magic(_ sender: Any) {
        if (self.isMagic == 0){
            self.agoraKit?.setBeautyEffectOptions(true, options: .some(.init()))
            self.isMagic = 1
        }
        else{
            self.agoraKit?.setBeautyEffectOptions(false, options: .none)
            self.isMagic = 0
        }
    }
    
    @IBAction func Video(_ sender: Any) {
        if (self.isCameraOff == 0){
            self.videoBtn.setImage(UIImage(named: "VideoOff"), for: .normal)
            self.agoraKit?.disableVideo()
            self.isCameraOff = 1
        }
        else{
            self.videoBtn.setImage(UIImage(named: "VideoOn"), for: .normal)
            self.isCameraOff = 0
            self.agoraKit?.enableVideo()
        }
    }
    
    @IBAction func Mic(_ sender: Any) {
        if (self.isMicOn == 1){
            self.micBtn.setImage(UIImage(named: "micOff"), for: .normal)
            self.agoraKit?.disableAudio()
            self.isMicOn = 2
        }
        else{
            self.micBtn.setImage(UIImage(named: "mic"), for: .normal)
            //            self.agoraKit?.muteLocalAudioStream(false)
            self.agoraKit?.enableAudio()
            self.isMicOn = 1
        }
    }
    
    @IBAction func Cancel(_ sender: Any) {
        let vc = R.storyboard.popups.endStreamPopup()
        vc?.modalPresentationStyle = .overCurrentContext
        vc?.vc = self
        vc?.delegate = self
        vc?.commnet = "\(live_comments.count)"
        vc?.views = viewLabel.text ?? "0"
        vc?.lenght = timeLabel.text ?? "0"
        vc?.modalTransitionStyle = .crossDissolve
        self.present(vc!, animated: true, completion: nil)
        //        self.navigationController?.pushViewController(vc!, animated: true)
        // self.deleteLive(postId: self.post_id)
        
        //        let Storyboard = UIStoryboard(name: "Main", bundle: nil)
        //        let vc = Storyboard.instantiateViewController(withIdentifier: "EndLiveVC") as! EndLiveStreamController
        //        vc.delegate = self
        //        if (self.isJoin == 1){
        //            vc.readyText = NSLocalizedString("Ready to stop watching?", comment: "Ready to stop watching?")
        //            vc.textTxt = NSLocalizedString("Tap 'Yes' to exist live stream or 'No' to keep watching", comment: "Tap 'Yes' to exist live stream or 'No' to keep watching")
        //        }
        //        else{
        //            vc.readyText = NSLocalizedString("Ready to stop live Streaming?", comment: "Ready to stop live Streaming?")
        //            vc.textTxt = NSLocalizedString("Tap 'Yes' to end your stream or 'No' to continue", comment: "Tap 'Yes' to end your stream or 'No' to continue")
        //        }
        //        vc.modalPresentationStyle = .overFullScreen
        //        vc.modalTransitionStyle = .crossDissolve
        //        self.present(vc, animated: true, completion: nil)
        //        //        self.dismiss(animated: true) {
        //        //            self.leaveChannel()
        //        //        }
    }
    
    func endLive() {
        self.timer?.invalidate()
        self.postTimer?.invalidate()
        self.secTimer?.invalidate()
        if (self.isJoin == 1){
            self.leaveChannel()
        }
        else{
            self.leaveChannel()
            AgoraRtcEngineKit.destroy()
            self.deleteLive(postId: self.post_id)
        }
    }
}

//extension LiveStreamController: SharePostDelegate{
//
//    func sharePost() {
//        let vc = self.StoryBoard.instantiateViewController(withIdentifier : "SharePostVC") as! SharePostController
//        vc.posts.append(self.liveData)
//        //        vc.posts =  [self.postArray[self.selectedIndex]]
//        vc.modalTransitionStyle = .coverVertical
//        vc.modalPresentationStyle = .fullScreen
//        self.present(vc, animated: true, completion: nil)
//    }
//
//
//    func sharePostTo(type:String) {
//        if (type == "group") || (type == "page"){
//            let Storyboard = UIStoryboard(name: "GroupsAndPages", bundle: nil)
//            let vc = Storyboard.instantiateViewController(withIdentifier : "MyGroups&PagesVC") as! MyGroupsandMyPagesController
//            vc.type = type
//            vc.delegate = self
//            vc.modalPresentationStyle = .overFullScreen
//            vc.modalTransitionStyle = .crossDissolve
//            self.present(vc, animated: true, completion: nil)
//        }
//        else {
//            let vc = self.StoryBoard.instantiateViewController(withIdentifier : "SharePopUpVC") as! SharePopUpController
//            vc.delegate = self
//            vc.modalPresentationStyle = .overFullScreen
//            vc.modalTransitionStyle = .crossDissolve
//            self.present(vc, animated: true, completion: nil)
//        }
//    }
//
//
//    func sharePostLink() {
//
//        // text to share
//        var text = self.postUrl
//        //        if let postUrl =  self.postArray[selectedIndex]["url"] as? String{
//        //            text = postUrl
//        //        }
//        // set up activity view controller
//        let textToShare = [ text ]
//        let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
//        activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
//
//        // exclude some activity types from the list (optional,)
//        activityViewController.excludedActivityTypes = [ UIActivity.ActivityType.airDrop, UIActivity.ActivityType.postToFacebook, UIActivity.ActivityType.assignToContact,UIActivity.ActivityType.mail,UIActivity.ActivityType.postToTwitter,UIActivity.ActivityType.message,UIActivity.ActivityType.postToFlickr,UIActivity.ActivityType.postToVimeo,UIActivity.ActivityType.init(rawValue: "net.whatsapp.WhatsApp.ShareExtension"),UIActivity.ActivityType.init(rawValue: "com.google.Gmail.ShareExtension"),UIActivity.ActivityType.init(rawValue: "com.toyopagroup.picaboo.share"),UIActivity.ActivityType.init(rawValue: "com.tinyspeck.chatlyio.share")]
//
//        // present the view controller
//        self.present(activityViewController, animated: true, completion: nil)
//    }
//
//
//    func selectPageandGroup(data: [String : Any],type : String) {
//        let vc = self.StoryBoard.instantiateViewController(withIdentifier : "SharePostVC") as! SharePostController
//        //        vc.posts = [self.postArray[self.selectedIndex]]
//        vc.posts.append(self.liveData)
//        if type == "group"{
//            if let groupName = data["group_name"] as? String{
//                vc.groupName = groupName
//            }
//            if let groupId = data["id"] as? String{
//                vc.groupId = groupId
//            }
//            if let image  = data["avatar"] as? String{
//                let trimmedString = image.trimmingCharacters(in: .whitespaces)
//                vc.imageUrl = trimmedString
//            }
//            vc.isGroup = true
//        }
//        else {
//            if let pageName = data["page_title"] as? String{
//                vc.pageName = pageName
//            }
//            if let pageId = data["id"] as? String{
//                vc.pageId = pageId
//            }
//            if let image  = data["avatar"] as? String{
//                vc.imageUrl = image
//            }
//            vc.isPage = true
//        }
//        vc.modalTransitionStyle = .coverVertical
//        vc.modalPresentationStyle = .fullScreen
//        self.present(vc, animated: true, completion: nil)
//    }
//}

extension LiveStreamController: AgoraRtcEngineDelegate, UITableViewDelegate, UITableViewDataSource {
    
    // Monitors the firstRemoteVideoDecodedOfUid callback
    // The SDK triggers the callback when it has received and decoded the first video frame from a remote host
    func rtcEngine(_ engine: AgoraRtcEngineKit, firstRemoteVideoDecodedOfUid uid: UInt, size: CGSize, elapsed: Int) {
        //        if (self.isJoin == 1){
        let videoCanvas = AgoraRtcVideoCanvas()
        videoCanvas.uid = uid
        videoCanvas.renderMode = .hidden
        videoCanvas.view = self.remoteView
        // Sets the remote video view
        self.agoraKit?.setupRemoteVideo(videoCanvas)
        self.timer = Timer.scheduledTimer(timeInterval: 3.0,
                                          target: self,
                                          selector: #selector(self.getCommentsTimer),
                                          userInfo: nil,
                                          repeats: true)
        self.postTimer = Timer.scheduledTimer(timeInterval: 5.0,
                                              target: self,
                                              selector: #selector(self.getPostTimer),
                                              userInfo: nil,
                                              repeats: true)
        //        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "LiveTableViewCell", for: indexPath) as! LiveTableViewCell
        cell.commentLabel.text = comments[indexPath.row]
        let profileImage = URL(string: AppInstance.instance.userProfile?.data?.avatar ?? "")
        cell.profileImageView.sd_setImage(with: profileImage , placeholderImage:R.image.maxresdefault())
        return cell
        //        let index = self.live_comments[indexPath.row]
        //        let cell = tableView.dequeueReusableCell(withIdentifier: "liveCommentsCell") as! LiveCommentCell
        //        cell.selectionStyle = .none
        //        if let publisher = index["publisher"] as? [String:Any] {
        //            if let name  = publisher["name"] as? String{
        //                cell.userName.text = name
        //            }
        //            if let image = publisher["avatar"] as? String{
        //                let url = URL(string: image)
        //                cell.proimage.kf.setImage(with: url)
        //            }
        //        }
        //        if let text = index["text"] as? String{
        //            cell.textLbl.text = text.htmlToString
        //        }
        //        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}

extension LiveStreamController: EndStream {
    func endStramController() {
        self.dismiss(animated: true, completion: nil)
    }
}

