
import UIKit

class EmailVerificationVC: UIViewController {

    @IBOutlet weak var okayButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        self.emailLabel.text = NSLocalizedString("Email verification", comment: "Email verification")
        self.titleLabel.text = NSLocalizedString("A verification link has been sent to your email", comment: "A verification link has been sent to your email")
        
        self.okayButton.setTitle(NSLocalizedString("Okay", comment: "Okay"), for: .normal)
    }
    
    
    @IBAction func okayPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
