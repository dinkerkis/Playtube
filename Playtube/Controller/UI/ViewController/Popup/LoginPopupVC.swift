

import UIKit

class LoginPopupVC: BaseVC {

    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var loginLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        self.loginLabel.text = NSLocalizedString("Login", comment: "Login")
        self.cancelButton.setTitle(NSLocalizedString("Cancel", comment: "Cancel"), for: .normal)
        self.loginButton.setTitle(NSLocalizedString("LOGIN", comment: "LOGIN"), for: .normal)
        self.titleLabel.text = NSLocalizedString("Please login to continue", comment: "Please login to continue")
    }
    
    @IBAction func loginPressed(_ sender: Any) {
        let vc = R.storyboard.auth.login()
        appDelegate.window?.rootViewController = vc!
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)

    }

}
