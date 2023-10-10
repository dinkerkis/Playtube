import UIKit
import PlaytubeSDK
import Async
import Alamofire

class VerificationVC: BaseVC {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var selectedImage: UIImageView!
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var verification: UILabel!
    @IBOutlet weak var verificationText: UILabel!
    @IBOutlet weak var selectPicBtn: UIButton!
    @IBOutlet weak var submitBtn: UIButton!
    
    // MARK: - Properties
    
    private let imagePickerController = UIImagePickerController()
    private var imageData: Data? = nil
    
    // MARK: - View Life Cycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initialConfig()
    }
    
    // MARK: - Selectors
    
    // Submit Button Action
    @IBAction func submitButtonAction(_ sender: UIButton) {
        if (self.firstNameTextField.text ?? "").isEmptyStr {
            self.view.makeToast(NSLocalizedString("Please enter first name.", comment: "Please enter first name."))
        } else if (self.lastNameTextField.text ?? "").isEmptyStr {
            self.view.makeToast(NSLocalizedString("Please enter last name.", comment: "Please enter last name."))
        } else if (self.messageTextField.text ?? "").isEmptyStr {
            self.view.makeToast(NSLocalizedString("Please enter a message.", comment: "Please enter a message."))
        } else if imageData == nil {
            self.view.makeToast(NSLocalizedString("Please select recent picutre of your passport or id.", comment: "Please select recent picutre of your passport or id."))
        } else {
            self.showProgressDialog(text: NSLocalizedString("Loading...", comment: "Loading..."))
            let firstName = self.firstNameTextField.text ?? ""
            let lastName = self.lastNameTextField.text ?? ""
            let message = self.messageTextField.text ?? ""
            let userID = AppInstance.instance.userId ?? 0
            let sessionID = AppInstance.instance.sessionId ?? ""
            let imageData = self.imageData ?? Data()
            self.showProgressDialog(text: NSLocalizedString("Loading...", comment: "Loading..."))
            Async.background {
                VerificationManager.instance.verifyUser(User_id: userID, Session_Token: sessionID, FirstName: firstName, LastName: lastName, Message: message, Identity: imageData, completionBlock: { (success, sessionError, error) in
                    if success != nil {
                        Async.main {
                            self.dismissProgressDialog {
                                self.view.makeToast(success?.message)
                                log.debug("Success = \(success?.message ?? "")")
                            }
                        }
                    } else if sessionError != nil {
                        Async.main {
                            self.dismissProgressDialog {
                                self.view.makeToast(sessionError?.errors.error_text)
                                log.error("SessionError = \(sessionError?.errors.error_text ?? "")")
                            }
                        }
                    } else {
                        Async.main {
                            self.dismissProgressDialog {
                                log.error("error = \(error?.localizedDescription ?? "")")
                                self.view.makeToast(error?.localizedDescription)
                            }
                        }
                    }
                })
            }
        }
    }
    
    // Back Button Action
    @IBAction func backButtonAction(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    // Select Picture Button Action
    @IBAction func selectPictureButtonAction(_ sender: UIButton) {
        let alert = UIAlertController(title: "", message: NSLocalizedString("Select Source", comment: "Select Source"), preferredStyle: .alert)
        let camera = UIAlertAction(title: NSLocalizedString("Camera", comment: "Camera"), style: .default) { (action) in
            self.imagePickerController.delegate = self
            self.imagePickerController.allowsEditing = true
            self.imagePickerController.sourceType = .camera
            self.present(self.imagePickerController, animated: true, completion: nil)
        }
        let gallery = UIAlertAction(title: NSLocalizedString("Gallery", comment: "Gallery"), style: .default) { (action) in
            self.imagePickerController.delegate = self
            self.imagePickerController.allowsEditing = true
            self.imagePickerController.sourceType = .photoLibrary
            self.present(self.imagePickerController, animated: true, completion: nil)
        }
        let cancel = UIAlertAction(title:NSLocalizedString("Cancel", comment: "Cancel"), style: .destructive, handler: nil)
        alert.addAction(camera)
        alert.addAction(gallery)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }
    
    // Cancel Button Action
    @IBAction func cancelButtonAction(_ sender: UIButton) {
        self.selectedImage.image = UIImage(named: "maxresdefault")
        self.imageData = nil
    }
    
    // MARK: - Helper Functions
    
    // Initial Config
    func initialConfig() {
        self.firstNameTextField.placeholder = NSLocalizedString("First Name", comment: "First Name")
        self.lastNameTextField.placeholder = NSLocalizedString("Last Name", comment: "Last Name")
        self.messageTextField.placeholder = NSLocalizedString("Message", comment: "Message")
        self.selectPicBtn.setTitle(NSLocalizedString("Select Passport/Id", comment: "Select Pictures"), for: .normal)
        self.verification.text = NSLocalizedString("Verification", comment: "Verification")
        self.verificationText.text = NSLocalizedString("Please select a recent picture of your passport or id", comment: "Lütfen pasaportunuzun veya kimliğinizin yeni bir resmini seçin.")
        self.submitBtn.setTitle(NSLocalizedString("Submit Request", comment: "Submit Request"), for: .normal)
    }
    
}

// MARK: - Extensions

// MARK: UIImagePickerControllerDelegate Methods
extension  VerificationVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        log.verbose("Imageselected = \(image)")
        self.selectedImage.image = image
        self.imageData = image.jpegData(compressionQuality: 0.1)
        self.dismiss(animated: true, completion: nil)
    }
    
}
