//
//  PlayListCell.swift
//  Playtube
//
//  Created by iMac on 18/05/23.
//  Copyright © 2023 ScriptSun. All rights reserved.
//

import UIKit
import UIView_Shimmer
import SDWebImage

class PlayListCell: UITableViewCell, ShimmeringViewProtocol {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var videoCountLabel: UILabel!
    @IBOutlet weak var playlistNameLabel: UILabel!
    @IBOutlet weak var imgPlaylist: UIImageView!
    
    // MARK: - Properties
    
    var shimmeringAnimatedItems: [UIView] {
        [
            imgPlaylist,
            playlistNameLabel,
            videoCountLabel
        ]
    }
    
    // MARK: - Initialize Function

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // MARK: - Helper Functions
    
    // Set Data
    func setData(object: PlaylistModel.MyAllPlaylist) {
        self.playlistNameLabel.text = object.name ?? ""
        self.videoCountLabel.text = "\(object.count ?? 0) videos"
        let thumbnailImage = URL(string: object.thumbnail ?? "")
        self.imgPlaylist.sd_setShowActivityIndicatorView(true)
        self.imgPlaylist.sd_setIndicatorStyle(.medium)
        DispatchQueue.global(qos: .userInteractive).async {
            self.imgPlaylist.sd_setImage(with: thumbnailImage)
        }
    }
    
}
