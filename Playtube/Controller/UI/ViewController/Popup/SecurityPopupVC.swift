import UIKit
import SwiftEventBus
import PlaytubeSDK

class SecurityPopupVC: UIViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var errorTextLabel: UILabel!
    
    // MARK: - Properties
    
    var errorText: String? = ""
    var titleText: String? = ""
    
    // MARK: - View Life Cycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupUI()
    }
    
    // MARK: - Selectors
    
    @IBAction func okPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Helper Functions
    
    private func setupUI() {
        self.titleLabel.text = titleText ?? "Security"
        self.errorTextLabel.text = errorText ?? "N/A"
    }
    
}
