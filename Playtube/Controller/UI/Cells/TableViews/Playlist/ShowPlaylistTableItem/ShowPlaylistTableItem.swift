
import UIKit

class ShowPlaylistTableItem: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    func bind(_ object:PlaylistModel.MyAllPlaylist){
        self.nameLabel.text = object.name ?? ""
    }
}
