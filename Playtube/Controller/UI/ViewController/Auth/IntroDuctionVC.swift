import UIKit
import AVFoundation

class IntroDuctionVC: UIViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var registerBtn: UIButton!
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var skipBtn: UIButton!
    @IBOutlet weak var startLabel: UILabel!
    
    // MARK: - Properties
    
    var avPlayer: AVPlayer!
    var avPlayerLayer: AVPlayerLayer!
    var paused: Bool = false
    var agree = false
    let storyBoard = UIStoryboard(name: "Auth", bundle: nil)
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let theURL = URL(fileURLWithPath: Bundle.main.path(forResource: "MainVideo", ofType: ".mp4")!)
        
        avPlayer = AVPlayer(url: theURL)
        avPlayerLayer = AVPlayerLayer(player: avPlayer)
        avPlayerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        avPlayer.volume = 25
        avPlayer.actionAtItemEnd = .none
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
        } catch {
            print("Setting category to AVAudioSessionCategoryPlayback failed.")
        }
        avPlayerLayer.frame = view.layer.bounds
        // view.backgroundColor = .clear
        // view.layer.insertSublayer(avPlayerLayer, at: 0)        
        NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidReachEnd(notification:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: avPlayer.currentItem)
        // self.startLabel.text = NSLocalizedString("Let's get started!", comment: "Let's get started!")
        // self.loginBtn.setTitle(NSLocalizedString("LOGIN", comment: "LOGIN"), for: .normal)
        // self.loginBtn.setTitleColor(.fontcolor, for: .normal)
        // self.loginBtn.backgroundColor = .buttonColor
        // self.registerBtn.setTitle(NSLocalizedString("REGISTER", comment: "REGISTER"), for: .normal)
        // self.registerBtn.setTitleColor(.fontcolor, for: .normal)
        // self.registerBtn.backgroundColor = .buttonColor
        // self.skipBtn.setTitle(NSLocalizedString("SKIP", comment: "SKIP"), for: .normal)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        avPlayer.play()
        paused = false
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        avPlayer.pause()
        paused = true
    }
    
    // MARK: - Selectors
    
    @IBAction func registerButtonAction(_ sender: Any) {
        let vc = R.storyboard.auth.registerVC()
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    @IBAction func logiInButtonAction(_ sender: Any) {
        let vc = R.storyboard.auth.loginVC()
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    @IBAction func skipButtonAction(_ sender: Any) {
        AppInstance.instance.userType = 0
        let vc = R.storyboard.loggedUser.tabBarNav()
        obj_appDelegate.window?.rootViewController = vc
    }
    
    // MARK: - Helper Functions
    
    // video player func
    @objc func playerItemDidReachEnd(notification: Notification) {
        let p: AVPlayerItem = notification.object as! AVPlayerItem
        p.seek(to: CMTime.zero, completionHandler: nil)
    }
    
}
