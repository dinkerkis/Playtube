
import UIKit

class ArticlesSectionSixTableItem: UITableViewCell {

    @IBOutlet weak var noCommentsLbl: UILabel!
    @IBOutlet weak var commentText: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.noCommentsLbl.text = NSLocalizedString("No Comments Yet", comment: "No Comments Yet")
        self.commentText.text = NSLocalizedString("Get the conversation started by leaving the first comment", comment: "Get the conversation started by leaving the first comment")
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
}
