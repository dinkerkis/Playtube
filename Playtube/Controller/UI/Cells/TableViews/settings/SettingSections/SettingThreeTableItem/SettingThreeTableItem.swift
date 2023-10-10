import UIKit

protocol PauseHistoryDelegate {
    func handlePauseHistorySwitchTap(_ sender: UISwitch)
}

protocol PictureInPictureDelegate {
    func handlePictureInPictureSwitchTap(_ sender: UISwitch)
}

class SettingThreeTableItem: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imgLeft: UIImageView!
    @IBOutlet weak var `switch`: UISwitch!
    
    var pauseHistoryDelegate: PauseHistoryDelegate?
    var pictureInPictureDelegate: PictureInPictureDelegate?
    var type = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func switchPressed(_ sender: UISwitch) {
        if type == "pause_history" {
            self.pauseHistoryDelegate?.handlePauseHistorySwitchTap(sender)
        }
        if type == "picture_in_picture" {
            self.pictureInPictureDelegate?.handlePictureInPictureSwitchTap(sender)
        }
    }
    
}
