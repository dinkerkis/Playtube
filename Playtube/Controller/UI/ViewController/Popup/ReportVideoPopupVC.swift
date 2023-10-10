
import UIKit
import PlaytubeSDK
import Async
class ReportVideoPopupVC: BaseVC {
    
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var reportLabel: UILabel!
    @IBOutlet weak var reportTextField: TJTextField!

    var videoID:Int? = 0

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.reportLabel.text = NSLocalizedString("Report", comment: "Report")
        self.submitButton.setTitle(NSLocalizedString("Submit", comment: "Submit"), for: .normal)
        self.titleLabel.text = NSLocalizedString("are you sure you want to report this video?", comment: "are you sure you want to report this video?")
        self.cancelButton.setTitle(NSLocalizedString("CANCEL", comment: "CANCEL"), for: .normal)
    }
    
    @IBAction func cancelPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func submitPressed(_ sender: Any) {
        self.reportVideo()
    }
    func reportVideo(){
        if Connectivity.isConnectedToNetwork(){
            self.showProgressDialog(text: NSLocalizedString("Loading...", comment: "Loading..."))
            let userID = AppInstance.instance.userId ?? 0
            let sessionID = AppInstance.instance.sessionId ?? ""
            let videoID = self.videoID ?? 0
            let reportText = self.reportTextField.text ?? ""
            Async.background{
                ReportManager.instance.reportVideo(User_id: userID, Session_Token: sessionID, id: videoID, text: reportText, completionBlock: { (success, sessionError, error) in
                    if success != nil{
                        Async.main{
                            self.dismissProgressDialog {
                                self.dismiss(animated: true, completion: {
                                    self.view.makeToast(NSLocalizedString("Video Reported successfully!!", comment: "Video Reported successfully!!"))
                                })
                            }
                        }
                    }else if sessionError != nil{
                        Async.main{
                            self.dismissProgressDialog {
                                log.error("responseError = \(sessionError?.errors!.error_text ?? "")")
                                self.view.makeToast(sessionError?.errors!.error_text)
                            }
                        }
                    }else {
                        self.dismissProgressDialog {
                            log.error("error = \(error?.localizedDescription ?? "")")
                            self.view.makeToast(error?.localizedDescription ?? "")
                        }
                    }
                })
            }
            
        }else{
            self.dismissProgressDialog {
                self.view.makeToast(InterNetError)
            }
        }
    }
}
