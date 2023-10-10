//
//  VideoOptionPopupVC.swift
//  Playtube
//
//  Created by iMac on 02/05/23.
//  Copyright © 2023 ScriptSun. All rights reserved.
//

import UIKit
import Toast_Swift
import PlaytubeSDK
import Async

class VideoOptionPopupVC: BaseVC {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var pullBar: UIView!
    @IBOutlet weak var borderView: UIView! {
        didSet {
            borderView.layer.cornerRadius = 3.5
            borderView.backgroundColor = UIColor(named: "Label_Colors_Tertiary")
        }
    }
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Properties
    
    var sheetHeight: CGFloat = 0
    var sheetBackgroundColor: UIColor = .white
    var sheetCornerRadius: CGFloat = 22
    private var hasSetOriginPoint = false
    private var originPoint: CGPoint?
    var optionArray: [String] = []
    var object: VideoDetail?
    
    // MARK: - View Life Cycles

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.initialConfig()
    }
    
    override func viewDidLayoutSubviews() {
        if !hasSetOriginPoint {
            hasSetOriginPoint = true
            originPoint = view.frame.origin
        }
    }
    
    // MARK: - Helper Functions
    
    // Initial Config
    func initialConfig() {
        self.setData()
        view.frame.size.height = sheetHeight
        view.isUserInteractionEnabled = true
        view.backgroundColor = sheetBackgroundColor
        view.roundCorners(corners: [.topLeft, .topRight], radius: sheetCornerRadius)
        self.registerCell()
        self.setPanGesture()
    }
    
    // Register Cell
    func registerCell() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(UINib(resource: R.nib.videoOptionCell), forCellReuseIdentifier: R.reuseIdentifier.videoOptionCell.identifier)
    }
    
    // Set Pan Gesture
    func setPanGesture() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panGestureRecognizerAction))
        view.addGestureRecognizer(panGesture)
    }
    
    // Gesture Recognizer
    @objc func panGestureRecognizerAction(sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: view)
        // Not allowing the user to drag the view upward
        guard translation.y >= 0 else { return }
        view.frame.origin = CGPoint(
            x: 0,
            y: self.originPoint!.y + translation.y
        )
        if sender.state == .ended {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    // Set Data
    func setData() {
        self.optionArray.append("Save to watch later")
        self.optionArray.append("Save to playlist")
        if object?.video_type == "video/mp4" {
            self.optionArray.append("Download video")
        }
        self.optionArray.append("Share")
        self.optionArray.append("Not interested")
        self.optionArray.append("Report")
        self.sheetHeight = CGFloat((self.optionArray.count * 48)) + (32 + self.view.safeAreaBottom)
    }

}

// MARK: - Extensions

// MARK: TableView Setup
extension VideoOptionPopupVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.optionArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.videoOptionCell.identifier, for: indexPath) as! VideoOptionCell
        cell.setData(content: self.optionArray[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.dismiss(animated: true) {
            switch self.optionArray[indexPath.row] {
            case "Save to watch later":
                if AppInstance.instance.getUserSession() {
                    self.setWatchLater()
                } else {
                    let warningPopupVC = R.storyboard.popups.warningPopupVC()
                    warningPopupVC?.delegate = self
                    warningPopupVC?.okText = "YES"
                    warningPopupVC?.cancelText = "NO"
                    warningPopupVC?.titleText  = "Warning"
                    warningPopupVC?.messageText = "Please sign in to add to WatchLater videos"
                    self.appDelegate.window?.rootViewController?.present(warningPopupVC!, animated: true, completion: nil)
                }
            case "Save to playlist":
                if AppInstance.instance.getUserSession() {
                    self.getPlaylist()
                } else {
                    let warningPopupVC = R.storyboard.popups.warningPopupVC()
                    warningPopupVC?.delegate = self
                    warningPopupVC?.okText = "YES"
                    warningPopupVC?.cancelText = "NO"
                    warningPopupVC?.titleText  = "Warning"
                    warningPopupVC?.messageText = "Please sign in to add to playlist videos"
                    self.appDelegate.window?.rootViewController?.present(warningPopupVC!, animated: true, completion: nil)
                }
            case "Download video":
                if AppInstance.instance.getUserSession() {
                    self.downloadVideo()
                }  else {
                    let warningPopupVC = R.storyboard.popups.warningPopupVC()
                    warningPopupVC?.delegate = self
                    warningPopupVC?.okText = "YES"
                    warningPopupVC?.cancelText = "NO"
                    warningPopupVC?.titleText  = "Warning"
                    warningPopupVC?.messageText = "Please sign in to download video"
                    self.appDelegate.window?.rootViewController?.present(warningPopupVC!, animated: true, completion: nil)
                }
            case "Share":
                if AppInstance.instance.getUserSession() {
                    self.shareVideo()
                }  else {
                    let warningPopupVC = R.storyboard.popups.warningPopupVC()
                    warningPopupVC?.delegate = self
                    warningPopupVC?.okText = "YES"
                    warningPopupVC?.cancelText = "NO"
                    warningPopupVC?.titleText  = "Warning"
                    warningPopupVC?.messageText = "Please sign in to share video"
                    self.appDelegate.window?.rootViewController?.present(warningPopupVC!, animated: true, completion: nil)
                }
            case "Not interested":
                if AppInstance.instance.getUserSession() {
                    self.setNotInterested()
                }  else {
                    let warningPopupVC = R.storyboard.popups.warningPopupVC()
                    warningPopupVC?.delegate = self
                    warningPopupVC?.okText = "YES"
                    warningPopupVC?.cancelText = "NO"
                    warningPopupVC?.titleText  = "Warning"
                    warningPopupVC?.messageText = "You ca  set not interested only after you log in"
                    self.appDelegate.window?.rootViewController?.present(warningPopupVC!, animated: true, completion: nil)
                }
            case "Report":
                if AppInstance.instance.getUserSession() {
                    let vc = R.storyboard.popups.reportVideoPopupVC()
                    vc?.videoID = self.object?.id ?? 0
                    self.appDelegate.window?.rootViewController?.present(vc!, animated: true, completion: nil)
                } else {
                    let warningPopupVC = R.storyboard.popups.warningPopupVC()
                    warningPopupVC?.delegate = self
                    warningPopupVC?.okText = "YES"
                    warningPopupVC?.cancelText = "NO"
                    warningPopupVC?.titleText  = "Warning"
                    warningPopupVC?.messageText = "You can add report only after you log in"
                    self.appDelegate.window?.rootViewController?.present(warningPopupVC!, animated: true, completion: nil)
                }
            default:
                break
            }
        }
    }
    
}

// MARK: Helper Functions
extension VideoOptionPopupVC {
    
    func setWatchLater() {
        if object != nil {
            log.verbose("Check = \(UserDefaults.standard.getWatchLater(Key: Local.WATCH_LATER.watch_Later))")
            let objectToEncode = object
            let data = try? PropertyListEncoder().encode(objectToEncode)
            var getWatchLaterData = UserDefaults.standard.getWatchLater(Key: Local.WATCH_LATER.watch_Later)
            if UserDefaults.standard.getWatchLater(Key: Local.WATCH_LATER.watch_Later).contains(data!) {
                self.appDelegate.window?.rootViewController?.view.makeToast(NSLocalizedString("Already added in watch later", comment: "Already added in watch later"))
            } else {
                getWatchLaterData.append(data!)
                UserDefaults.standard.setWatchLater(value: getWatchLaterData, ForKey: Local.WATCH_LATER.watch_Later)
                self.appDelegate.window?.rootViewController?.view.makeToast(NSLocalizedString("Added to watch later", comment: "Added to watch later"))
            }
        }
    }
    
    func setNotInterested() {
        if object != nil {
            log.verbose("Check = \(UserDefaults.standard.getNotInterested(Key: Local.NOT_INTERESTED.not_interested))")
            let objectToEncode = object
            if Connectivity.isConnectedToNetwork() {
                NotInterestManager.instance.addNotInterestAPI(videoID: objectToEncode?.id ?? 0) { success, sessionError, error in
                    if success != nil {
                        Async.main {
                            log.debug("Success: \(success?.message ?? "")")
                            AppInstance.instance.getNotInterestedDataAPI()
                            self.appDelegate.window?.rootViewController?.view.makeToast(success?.message)
                        }
                    } else if sessionError != nil {
                        // self.dismissLoaderOnly(loader: self.activityInd)
                        log.verbose("sessionError = \(sessionError?.errors?.error_text ?? "")")
                        self.view.makeToast(sessionError?.errors?.error_text ?? "")
                    } else {
                        // self.dismissLoaderOnly(loader: self.activityInd)
                        log.verbose("Error = \(error?.localizedDescription ?? "")")
                        self.view.makeToast(error?.localizedDescription ?? "")
                    }
                }
            } else {
                // self.dismissLoaderOnly(loader: self.activityInd)
                self.view.makeToast(InterNetError)
            }
        }
    }
    
    func downloadVideo() {
        if object != nil {
            log.verbose("Check = \(UserDefaults.standard.getOfflineDownload(Key: Local.OFFLINE_DOWNLOAD.offline_download))")
            let objectToEncode = object
            let data = try? PropertyListEncoder().encode(objectToEncode)
            var getOfflineVideosData = UserDefaults.standard.getOfflineDownload(Key: Local.OFFLINE_DOWNLOAD.offline_download)
            if UserDefaults.standard.getWatchLater(Key: Local.OFFLINE_DOWNLOAD.offline_download).contains(data!) {
                self.appDelegate.window?.rootViewController?.view.makeToast(NSLocalizedString("Already added in offline videos", comment: "Already added in offline videos"))
            } else {
                print("Video Url >>>>", (self.object?.video_location ?? ""))
                VideoDownloader().downloadVideo(videoURLString: (self.object?.video_location ?? ""))
                getOfflineVideosData.append(data!)
                UserDefaults.standard.setOfflineDownload(value: getOfflineVideosData, ForKey: Local.OFFLINE_DOWNLOAD.offline_download)
                self.appDelegate.window?.rootViewController?.view.makeToast(NSLocalizedString("Added to offline videos", comment: "Added to offline videos"))
            }
        }
    }
        
    func shareVideo() {
        // text to share
        let someText: String = "Share Video"
        let url = self.object?.url ?? ""
        print(url)
        // set up activity view controller
        let textToShare = [ someText, url ]
        let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.appDelegate.window?.rootViewController?.view
        // exclude some activity types from the list (optional,)
        activityViewController.excludedActivityTypes = [
            UIActivity.ActivityType.airDrop,
            UIActivity.ActivityType.postToFacebook,
            UIActivity.ActivityType.assignToContact,
            UIActivity.ActivityType.mail,
            UIActivity.ActivityType.postToTwitter,
            UIActivity.ActivityType.message,
            UIActivity.ActivityType.postToFlickr,
            UIActivity.ActivityType.postToVimeo,
            UIActivity.ActivityType.postToTencentWeibo,
            UIActivity.ActivityType.init(rawValue: "net.whatsapp.WhatsApp.ShareExtension"),
            UIActivity.ActivityType.init(rawValue: "com.google.Gmail.ShareExtension"),
            UIActivity.ActivityType.init(rawValue: "com.toyopagroup.picaboo.share"),
            UIActivity.ActivityType.init(rawValue: "com.tinyspeck.chatlyio.share")
        ]
        activityViewController.completionWithItemsHandler = { activity, completed, items, error in
            if !completed {
                return
            } else {
                if self.object != nil {
                    log.verbose("Check = \(UserDefaults.standard.getSharedVideos(Key: Local.SHARED_VIDEOS.shared_videos))")
                    let objectToEncode = self.object
                    let data = try? PropertyListEncoder().encode(objectToEncode)
                    var getSharedVideosData = UserDefaults.standard.getSharedVideos(Key: Local.SHARED_VIDEOS.shared_videos)
                    if UserDefaults.standard.getSharedVideos(Key: Local.SHARED_VIDEOS.shared_videos).contains(data!) {
                        self.appDelegate.window?.rootViewController?.view.makeToast(NSLocalizedString("Already added in shared videos", comment: "Already added in shared videos"))
                    } else {
                        getSharedVideosData.append(data!)
                        UserDefaults.standard.setSharedVideos(value: getSharedVideosData, ForKey: Local.SHARED_VIDEOS.shared_videos)
                        self.appDelegate.window?.rootViewController?.view.makeToast(NSLocalizedString("Added to shared videos", comment: "Added to shared videos"))
                    }
                }
                
            }
        }
        // present the view controller
        self.appDelegate.window?.rootViewController?.present(activityViewController, animated: true, completion: nil)
    }
    
    func getPlaylist() {
        if Connectivity.isConnectedToNetwork() {
            // self.showLoaderOnly(loader: self.activityInd)
            let userID = AppInstance.instance.userId ?? 0
            let sessionID = AppInstance.instance.sessionId ?? ""
            Async.background {
                PlaylistManager.instance.getPlaylist(User_id: userID, Session_Token: sessionID, completionBlock: { (success, sessionError, error) in
                    if success != nil {
                        Async.main {
                            // self.dismissLoaderOnly(loader: self.activityInd)
                            let vc = R.storyboard.popups.playlistsPopupVC()
                            vc?.videoID = (self.object?.id)
                            vc?.playlistArray = success?.myAllPlaylists ?? []
                            vc?.delegate = self
                            self.appDelegate.window?.rootViewController?.present(vc!, animated: true, completion: nil)
                        }
                    } else if sessionError != nil {
                        // self.dismissLoaderOnly(loader: self.activityInd)
                        log.verbose("sessionError = \(sessionError?.errors?.error_text ?? "")")
                        self.view.makeToast(sessionError?.errors?.error_text ?? "")
                    } else {
                        // self.dismissLoaderOnly(loader: self.activityInd)
                        log.verbose("Error = \(error?.localizedDescription ?? "")")
                        self.view.makeToast(error?.localizedDescription ?? "")
                    }
                })
            }
        } else {
            // self.dismissLoaderOnly(loader: self.activityInd)
            self.view.makeToast(InterNetError)
        }
    }
    
}

// MARK: WarningPopupVCDelegate Methods
extension VideoOptionPopupVC: WarningPopupVCDelegate {
    
    func warningPopupOKButtonPressed(_ sender: UIButton) {
        let vc = R.storyboard.auth.loginVC()
        (self.appDelegate.window?.rootViewController as? UINavigationController)?.pushViewController(vc!, animated: true)
    }
    
}

// MARK: ShowCreatePlayListDelegate Methods
extension VideoOptionPopupVC: ShowCreatePlayListDelegate {
    
    func showCreatePlaylist(Status: Bool) {
        let vc = R.storyboard.playlist.createNewPlaylistVC()
        (self.appDelegate.window?.rootViewController as? UINavigationController)?.pushViewController(vc!, animated: true)
    }
    
}


class VideoDownloader: NSObject, URLSessionDelegate, URLSessionDownloadDelegate {
    
    lazy var backgroundSession: URLSession = {
        let backgroundSessionIdentifier = "com.example.app.backgroundsession"
        let configuration = URLSessionConfiguration.background(withIdentifier: backgroundSessionIdentifier)
        return URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
    }()
    
    func downloadVideo(videoURLString: String) {
        guard let videoURL = URL(string: videoURLString) else {
            print("Invalid URL")
            return
        }
        let downloadTask = backgroundSession.downloadTask(with: videoURL)
        downloadTask.resume()
    }
    
    // URLSessionDownloadDelegate methods
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        let documentsURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        let destinationURL = documentsURL.appendingPathComponent(downloadTask.originalRequest?.url?.lastPathComponent ?? "")
        do {
            try FileManager.default.moveItem(at: location, to: destinationURL)
            print("Video downloaded successfully. Saved at: \(destinationURL)")
            // You can perform additional operations with the downloaded video here
        } catch {
            print("Error moving video to destination: \(error)")
        }
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            print("Error downloading video: \(error)")
        }
    }
}
