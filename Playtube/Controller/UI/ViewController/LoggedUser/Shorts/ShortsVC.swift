import UIKit
import AVKit
import Async
import PlaytubeSDK
import Toast_Swift

class ShortsVC: UIViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: - Properties
    
    var shortsVideosArray: [VideoDetail] = []
    var isFromTabbar = false
    var currentIndexPath = IndexPath(item: 0, section: 0)
    fileprivate var isPlaying = false
    lazy var player: AVPlayer = {
        let player = AVPlayer()
        return player
    }()
    lazy var playerLayer: AVPlayerLayer = {
        let playerLayer = AVPlayerLayer()
        return playerLayer
    }()
    var currentPlayingIndex = 0
    
    // MARK: - View Life Cycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("reloadShortData"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.reloadShortData(_:)), name: NSNotification.Name("reloadShortData"), object: nil)
        self.initialConfig()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidAppear(animated)
        player.pause()
    }
    
    // MARK: - Selectors
    
    @IBAction func backButtonAction(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Helper Functions -
    
    // InitialConfig
    func initialConfig() {
        self.setupCollectionView()
        if isFromTabbar {
            self.fetchShortsData(UserID: AppInstance.instance.userId ?? 0, SessionID: AppInstance.instance.sessionId ?? "")
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.collectionView.scrollToItem(at: self.currentIndexPath, at: .centeredVertically, animated: false)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    guard let cell = self.collectionView.cellForItem(at: self.currentIndexPath) as? ShortsVideoCell else {return}
                    self.handleSetUpVideoPlayer(cell: cell, videoUrlString: self.shortsVideosArray[self.currentIndexPath.item].video_location ?? "")
                }
            }
        }
    }
    
    @objc func reloadShortData(_ notification: NotificationCenter) {
        self.fetchShortsData(UserID: AppInstance.instance.userId ?? 0, SessionID: AppInstance.instance.sessionId ?? "")
    }
    
    // Register Cell
    func setupCollectionView() {
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
    }
    
    func fetchShortsData(UserID: Int, SessionID: String) {
        if Connectivity.isConnectedToNetwork() {
            Async.background {
                ShortsManager.instance.getShortsData(User_id: UserID, Session_Token: SessionID, Limit: 10, Offset: "", completionBlock: { success, sessionError, error in
                    if success != nil {
                        DispatchQueue.main.async {
                            self.shortsVideosArray = []
                            if let data = success?.data {
                                self.shortsVideosArray = AppInstance.instance.getNotInterestedData(data: data)
                            }
                            self.collectionView.reloadData()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                guard let cell = self.collectionView.cellForItem(at: self.currentIndexPath) as? ShortsVideoCell else {return}
                                self.handleSetUpVideoPlayer(cell: cell, videoUrlString: self.shortsVideosArray[self.currentIndexPath.item].video_location ?? "")
                            }
                        }
                    } else if sessionError != nil {
                        Async.main {
                            log.error("responseError = \(sessionError?.errors!.error_text ?? "")")
                            self.view.makeToast(sessionError?.errors!.error_text)
                        }
                    } else {
                        log.error("error = \(error?.localizedDescription ?? "")")
                        self.view.makeToast(error?.localizedDescription ?? "")
                    }
                })
            }
        } else {
            self.view.makeToast(InterNetError)
        }
    }
    
}

// MARK: - Extensions

// MARK: Collection View Setup
extension ShortsVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.shortsVideosArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: "ShortsVideoCell", for: indexPath) as! ShortsVideoCell
        let object = self.shortsVideosArray[indexPath.row]
        cell.fetchVideoDetails(object: object)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.collectionView.frame.width, height: self.collectionView.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let pageNumber = Int(targetContentOffset.pointee.y / self.collectionView.frame.height)
        let indexPath = IndexPath(item: pageNumber, section: 0)
        currentIndexPath = indexPath
        guard let cell = collectionView.cellForItem(at: indexPath) as? ShortsVideoCell else {return}
        self.handleSetUpVideoPlayer(cell: cell, videoUrlString: self.shortsVideosArray[indexPath.item].video_location ?? "")
    }
    
}

extension ShortsVC {
    
    func handleSetUpVideoPlayer(cell: ShortsVideoCell, videoUrlString: String) {
        if currentPlayingIndex == currentIndexPath.row && currentPlayingIndex != 0 {
            return
        }
        handleFetchVideoFromCachingManagerUsing(urlString: videoUrlString) {[weak self] (url) in
            guard let self = self, let urlUnwrapped = url else {return}
            self.initializeVideoPlayer(url: urlUnwrapped, cell: cell)
        }
    }
    
    fileprivate func removePeriodicTimeObserver() {
        isPlaying = false
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player.currentItem)
    }
    
    fileprivate func handleFetchVideoFromCachingManagerUsing(urlString: String, completion: @escaping (URL?) -> ()) {
        CacheManager.shared.getFileWith(stringUrl: urlString) { result in
            switch result {
            case .success(let url):
                // do some magic with path to saved video
                completion(url)
                break;
            case .failure(let error):
                // handle errror
                completion(nil)
                print(error, "failed to find value of key\(urlString) in cache and also synchroniously failed to fetch video from our remote server, most likely a network issue like lack of connectivity or database failure")
                break;
            }
        }
    }
    
    fileprivate  func initializeVideoPlayer(url: URL, cell: ShortsVideoCell) {
        removePeriodicTimeObserver()
        player.replaceCurrentItem(with: nil)
        let player = AVPlayer(url: url)
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = cell.bounds
        playerLayer.videoGravity = AVLayerVideoGravity.resizeAspect
        self.player = player
        self.playerLayer = playerLayer
        cell.postImageView.layer.addSublayer(playerLayer)
        player.play()
        isPlaying = true
        self.currentPlayingIndex = self.currentIndexPath.row
        let timeScale = CMTimeScale(NSEC_PER_SEC)
        let time = CMTime(seconds: 0.001, preferredTimescale: timeScale)
        NotificationCenter.default.addObserver(self, selector: #selector(playerDidPlayToEndTime), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player.currentItem)
    }
    
    @objc fileprivate func playerDidPlayToEndTime(notification: Notification) {
        player.seek(to: CMTime.zero)
        player.play()
    }
    
}
