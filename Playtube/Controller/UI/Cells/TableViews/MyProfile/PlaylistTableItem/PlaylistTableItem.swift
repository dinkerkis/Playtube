import UIKit
import DropDown
import PlaytubeSDK
import Async
import UIView_Shimmer
import Toast_Swift
import SDWebImage

protocol PlaylistTableItemDelegate {
    func handleRemovePlaylist(index: Int)
}

class PlaylistTableItem: UITableViewCell, ShimmeringViewProtocol {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var optionButton: UIButton!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var desLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var thumbnailImage: UIImageView!
    @IBOutlet weak var trailingView: UIView!
    @IBOutlet weak var videoListImage: UIImageView!
    
    // MARK: - Properties
    
    private var dropDown = DropDown()
    var parentController: BaseVC!
    var object: PlaylistModel.MyAllPlaylist?
    var index: Int? = 0
    var delegate: PlaylistTableItemDelegate?
    var presentDelegate: ShowPresentControllerDelegate?
    var shimmeringAnimatedItems: [UIView] {
        [
            thumbnailImage,
            trailingView,
            countLabel,
            videoListImage,
            nameLabel,
            optionButton,
            desLabel,
            descriptionLabel
        ]
    }
    
    // MARK: - Intialize Functions
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.selectionStyle = .none
        self.customizeDropDownFunc()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // MARK: - Selectors
    
    @IBAction func optionButtonAction(_ sender: UIButton) {
        self.dropDown.show()
    }
    
    func bind(_ object: PlaylistModel.MyAllPlaylist) {
        self.object = object
        self.descriptionLabel.text = object.description ?? ""
        self.countLabel.text = "\(object.count ?? 0)"
        self.nameLabel.text = object.name ?? ""
        self.desLabel.text = "\(object.count ?? 0) Videos"
        let thumbnailImage = URL(string: object.thumbnail ?? "")
        self.thumbnailImage.sd_setImage(with: thumbnailImage , placeholderImage:R.image.maxresdefault())
    }
    
    private func customizeDropDownFunc() {
        dropDown.dataSource = [NSLocalizedString("Edit", comment: "Edit"),NSLocalizedString("Delete", comment: "Delete")]
        dropDown.anchorView = self.optionButton
        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            if index == 0 {
                self.presentDelegate?.showController(Index: self.index!)
            } else if index == 1 {
                self.deletePlaylist()
            }
            log.verbose("Selected item: \(item) at index: \(index)")
        }
        dropDown.width = 200
        dropDown.direction = .any
    }
    
    private func deletePlaylist() {
        if Connectivity.isConnectedToNetwork() {
            self.parentController?.showProgressDialog(text: NSLocalizedString("Loading...", comment: "Loading..."))
            let userID = AppInstance.instance.userId ?? 0
            let sessionID = AppInstance.instance.sessionId ?? ""
            let listID = self.object?.listID ?? ""
            Async.background {
                PlaylistManager.instance.deletePlaylist(User_id: userID, Session_Token: sessionID, List_id: listID, completionBlock: { (success, sessionError, error) in
                    if success != nil {
                        Async.main {
                            self.parentController?.dismissProgressDialog {
                                log.debug("success")
                                self.delegate?.handleRemovePlaylist(index: self.index ?? 0)
                            }
                        }
                    } else if sessionError != nil {
                        Async.main {
                            self.parentController?.dismissProgressDialog {
                                log.debug("sessionError = \(sessionError?.errors!.error_text ?? "")")
                                self.parentController?.view.makeToast(sessionError?.errors!.error_text)
                            }
                        }
                    } else {
                        Async.main {
                            self.parentController?.dismissProgressDialog {
                                log.debug("error = \(error?.localizedDescription ?? "")")
                                self.parentController?.view.makeToast(error?.localizedDescription)
                            }
                        }
                    }
                })
            }
        } else {
            self.parentController?.view.makeToast(InterNetError)
        }
    }
    
}
