
import UIKit
import PlaytubeSDK
import Async


class LogoutPopupVC: BaseVC {
    // MARK: - IBOutlets
    @IBOutlet weak var logoutLAbel: UILabel!
    @IBOutlet weak var sureLabel: UILabel!
    @IBOutlet weak var pullBar: UIView!
    @IBOutlet weak var borderView: UIView! {
        didSet {
            borderView.layer.cornerRadius = 3.5
            borderView.backgroundColor = UIColor(named: "Label_Colors_Tertiary")
        }
    }
    
    // MARK: - Properties -
    var sheetHeight: CGFloat = 200
    var sheetBackgroundColor: UIColor = .white
    var sheetCornerRadius: CGFloat = 22
    private var hasSetOriginPoint = false
    private var originPoint: CGPoint?
    var parentVC: BaseVC?
    
    // MARK: - View Life Cycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initialConfig()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.logoutLAbel.text = NSLocalizedString("Logout", comment: "Logout")
        self.sureLabel.text = NSLocalizedString("Are you sure you want to logout?", comment: "Are you sure you want to logout?")
    }
    
    override func viewDidLayoutSubviews() {
        if !hasSetOriginPoint {
            hasSetOriginPoint = true
            originPoint = view.frame.origin
        }
    }
    
    //MARK: - Selectors -
        /// Cancel Button Action
    @IBAction func yesPressed(_ sender: UIButton) {
        self.view.endEditing(true)
        self.dismiss(animated: true)
        self.parentVC?.showProgressDialog(text: NSLocalizedString("Loading...", comment: "Loading..."))
        let timer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(self.update), userInfo: nil, repeats: false)
    }
    @IBAction func cancelPressed(_ sender: UIButton) {
        self.view.endEditing(true)
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func update() {
        self.view.endEditing(true)
        self.parentVC?.dismissProgressDialog {
            UserDefaults.standard.clearUserDefaults()
            let vc = R.storyboard.auth.login()
            obj_appDelegate.window?.rootViewController = vc!
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    // MARK: - Helper Functions -
    
    // Initial Config
    func initialConfig() {
        view.frame.size.height = sheetHeight
        view.isUserInteractionEnabled = true
        view.backgroundColor = sheetBackgroundColor
        view.roundCorners(corners: [.topLeft, .topRight], radius: sheetCornerRadius)
        self.setPanGesture()
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
}

/*
 
 
 @IBOutlet weak var noButton: UIButton!
 @IBOutlet weak var yesButton: UIButton!
 @IBOutlet weak var logoutLAbel: UILabel!
 @IBOutlet weak var sureLabel: UILabel!

 override func viewDidLoad() {
     super.viewDidLoad()
     
     self.yesButton.setTitle(NSLocalizedString("YES", comment: "YES"), for: .normal)
     
     self.noButton.setTitle(NSLocalizedString("NO", comment: "NO"), for: .normal)
 }
 override func viewWillAppear(_ animated: Bool) {
     self.logoutLAbel.text = NSLocalizedString("Logout", comment: "Logout")
     self.sureLabel.text = NSLocalizedString("Are you sure you want to logout?", comment: "Are you sure you want to logout?")
 }
 @IBAction func yesPressed(_ sender: Any) {
     self.showProgressDialog(text: NSLocalizedString("Loading...", comment: "Loading..."))
     let timer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(self.update), userInfo: nil, repeats: false)
 }
 @IBAction func noPressed(_ sender: Any) {
     self.dismiss(animated: true, completion: nil)
 }
 @objc func update() {
     UserDefaults.standard.clearUserDefaults()
     let vc = R.storyboard.auth.login()
     appDelegate.window?.rootViewController = vc!
     self.dismiss(animated: true, completion: nil)
     
 }
 
 */
