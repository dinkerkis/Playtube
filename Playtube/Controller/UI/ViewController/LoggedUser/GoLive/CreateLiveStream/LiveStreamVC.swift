//
//  LiveStreamVC.swift
//  Playtube
//
//  Created by Abdul Moid on 18/03/2021.
//  Copyright © 2021 Muhammad Haris Butt. All rights reserved.
//

import UIKit
import AgoraRtcKit
import AVKit

class LiveStreamVC: BaseVC {
    
    var postID:String?
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var commnetTextField: UITextField!
    @IBOutlet weak var mircoClicked: UIButton!
    @IBOutlet weak var videoClicked: UIButton!
    @IBOutlet weak var filterButton: UIButton!
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var viewLabel: UILabel!
    @IBOutlet weak var timerLabel: UILabel!
    
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
    var agoraKit: AgoraRtcEngineKit?
    var localVideo: AgoraRtcVideoCanvas?
    var live_comments = [[String:Any]]()
    var liveData = [String:Any]()
    var streamName = ""
    var post_id = ""
    var userImages = ""
    var postUrl = ""
    //    let status = Reach().connectionStatus()
    
    var timer: Timer?
    var postTimer: Timer?
    var secTimer: Timer?
    
    var frontCameraDeviceInput: AVCaptureDeviceInput?
    var backCameraDeviceInput: AVCaptureDeviceInput?
    var captureSession = AVCaptureSession()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.createLive()
        self.showProgressDialog(text: NSLocalizedString("Loading...", comment: "Loading..."))
        self.initView()
        self.initializeAgoraEngine()
        self.setupLocalVideo()
    }
    
    
    func initView() {
        // Initializes the remote video view. This view displays video when a remote host joins the channel
        //remoteView = UIView()
        //self.view.addSubview(remoteView)
        
        // Initializes the local video view. This view displays video when the local user is a host
        
        if self.isJoin == 1{
            remoteView = UIView()
            self.view.addSubview(remoteView)
        }
        else{
            localView = UIView()
            self.view.addSubview(localView)
            self.localView.frame = self.view.frame
        }
    }
    
    func initializeAgoraEngine() {
        self.agoraKit = AgoraRtcEngineKit.sharedEngine(withAppId: "c55b9bda665042809b61dfeb3f3832e0", delegate: self)
    }
    
    func createLive() {
//        let userID = AppInstance.instance.userId ?? 0
//        let sessionID = AppInstance.instance.sessionId ?? ""
//        GoLiveManager.instance.createLiveStream(userid: userID, type: "create", Session_Token: sessionID) { (success, sessionError, err) in
//            if success != nil {
//                self.dismissProgressDialog {
//                    guard let post_id = success?["post_id"] as? Int else { return }
//                    self.postID = "\(post_id)"
//                    self.view.makeToast("You are live now")
//                }
//            }else if sessionError != nil{
//                
//            }else{
//                
//            }
//        }
    }
    
    @IBAction func closeClicked(_ sender: Any) {
        self.showProgressDialog(text: NSLocalizedString("Loading...", comment: "Loading..."))
        
        let sessionID = AppInstance.instance.sessionId ?? ""
        let userID = AppInstance.instance.userId ?? 0
        let post_ID = self.postID ?? ""
        
        GoLiveManager.instance.endStream(postID: post_ID, Session_Token: sessionID, type: "delete", userid: userID) { (success, sessionError, err) in
            if success != nil {
                self.dismissProgressDialog {
                    self.dismiss(animated: true, completion: nil)
                }
            }else if sessionError != nil{
                
            }else{
                
            }
        }
    }
    
    @IBAction func cameraClicked(_ sender: Any) {
        //..
    }
    
    @IBAction func filterClicked(_ sender: Any) {
        //..
    }
    
    @IBAction func videoClicked(_ sender: Any) {
        //..
    }
    
    @IBAction func micClicked(_ sender: Any) {
        //..
    }
    
    @IBAction func sendClicked(_ sender: Any) {
        //..
    }
    
    @IBAction func shareClicked(_ sender: Any) {
        //..
    }
}

extension LiveStreamVC: AgoraRtcEngineDelegate {
    
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
    
    @objc func getCommentsTimer(){
        if self.isJoin == 0{
            //            self.getLiveComments(role: "live", postId: Int(self.post_id) ?? 0, offset: "")
        }
        else{
            //            self.getLiveComments(role: "story", postId: Int(self.post_id) ?? 0, offset: "")
            
        }
    }
    @objc func getPostTimer(){
        //        self.getLiveComments(postId: Int(self.post_id) ?? 0, offset: "")
        //        self.getPost(postId: self.post_id)
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
    
    @objc func secTTimer() {
        if (self.count == 60){
            self.minute += 1
            self.count = 0
        }
        self.count = self.count + 1
        self.timerLabel.text = "\(minute)\(":")\(count)"
    }
}
