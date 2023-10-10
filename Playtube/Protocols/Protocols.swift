import Foundation
import UIKit

protocol ShowCreatePlayListDelegate {
    func showCreatePlaylist(Status: Bool)
}

protocol ShowPresentControllerDelegate {
    func showController(Index: Int)
}

protocol IndexofCellDelegate {
    func indexofCell(Index: Int)
}

protocol EndStream {
    func endStramController()
}

protocol LikeDisLikeDelegate {
    func likeComments(id: Int, likebutton: UIButton, dislikebutton: UIButton, likeCount: Int?, dislikeCount: Int?, likeCountLabel: UILabel, dislikeCountLabel: UILabel)
    func disLikeComments(id: Int, dislikebutton: UIButton, likebutton: UIButton, likeCount: Int?, dislikeCount: Int?, likeCountLabel: UILabel, dislikeCountLabel: UILabel)
    func replyComments(index: Int)
}

protocol ShowArticlesDetailsDelegate {
    func didShowArticlesDetails(index: Int)
}

protocol ShowProfileDelegate {
    func didShowProfileDetails(index: Int)
}

protocol TimeByDelegate {
    func timeFilter(time: String)
}

protocol SortByDelegate {
    func SortFilter(sort: String)
}

protocol ChannelFilterDelegate {
    func filter(sort_by: String, time_by: String)
}

protocol FavCategoryDelegate {
    func fav_cat(id: [String], name: [String])
}

protocol ArticleCategoryDelegate {
    func articalCat(id: String, url: String)
}

protocol UploadVideoDelegate {
    func videoUploaded()
}

protocol WarningPopupVCDelegate {
    func warningPopupOKButtonPressed(_ sender: UIButton)
}

protocol PayStackEmailPopupVCDelegate {
    func handlePayStackPayNowButtonTap(email: String)
}
