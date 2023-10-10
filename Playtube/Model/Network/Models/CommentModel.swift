import Foundation

class CommentModel {
    
    struct CommentSuccessModel: Codable {
        
        let apiStatus, apiVersion, successType: String
        let data: [Comment]?
        
        enum CodingKeys: String, CodingKey {
            case apiStatus = "api_status"
            case apiVersion = "api_version"
            case successType = "success_type"
            case data
        }
        
    }
    
    struct CommentErrorModel: Codable {
        
        let apiStatus, apiVersion: String?
        let errors: Errors?
        
        enum CodingKeys: String, CodingKey {
            case apiStatus = "api_status"
            case apiVersion = "api_version"
            case errors
        }
        
    }
    
}

class AddCommentModel {
    
    struct AddCommentSuccessModel: Codable {
        let apiStatus, apiVersion, successType, message: String?
        let id: Int?
        
        enum CodingKeys: String, CodingKey {
            case apiStatus = "api_status"
            case apiVersion = "api_version"
            case successType = "success_type"
            case message, id
        }
    }
    
    struct AddCommentErrorModel: Codable {
        let apiStatus, apiVersion: String?
        let errors: Errors
        
        enum CodingKeys: String, CodingKey {
            case apiStatus = "api_status"
            case apiVersion = "api_version"
            case errors
        }
    }
    
}

class LikeCommentModel {
    
    struct LikeCommentSuccessModel: Codable {
        let apiStatus, apiVersion, successType: String?
        let liked: Int?
        
        enum CodingKeys: String, CodingKey {
            case apiStatus = "api_status"
            case apiVersion = "api_version"
            case successType = "success_type"
            case liked
        }
    }
    struct LikeCommentErrorModel: Codable {
        let apiStatus, apiVersion: String?
        let errors: Errors?
        
        enum CodingKeys: String, CodingKey {
            case apiStatus = "api_status"
            case apiVersion = "api_version"
            case errors
        }
    }
    
}

class DislikeCommentModel {
    
    struct DislikeCommentSuccessModel: Codable {
        let apiStatus, apiVersion, successType: String?
        let dislike: Int?
        
        enum CodingKeys: String, CodingKey {
            case apiStatus = "api_status"
            case apiVersion = "api_version"
            case successType = "success_type"
            case dislike
        }
    }
    struct DislikeCommentErrorModel: Codable {
        let apiStatus, apiVersion: String?
        let errors: Errors?
        
        enum CodingKeys: String, CodingKey {
            case apiStatus = "api_status"
            case apiVersion = "api_version"
            case errors
        }
    }
    
}


class RepliesModel {
    
    struct RepliesSuccessModel: Codable {
        
        let apiStatus, apiVersion, successType: String
        let data: [ReplyComment]?
        
        enum CodingKeys: String, CodingKey {
            case apiStatus = "api_status"
            case apiVersion = "api_version"
            case successType = "success_type"
            case data
        }
        
    }
    
    struct RepliesErrorModel: Codable {
        let apiStatus, apiVersion: String?
        let errors: Errors?
        
        enum CodingKeys: String, CodingKey {
            case apiStatus = "api_status"
            case apiVersion = "api_version"
            case errors
        }
    }
    
}

class CommentReplyModel {
    
    struct CommentReplySuccessModel: Codable {
        let apiStatus, apiVersion, successType, message: String?
        let replyID: Int
        
        enum CodingKeys: String, CodingKey {
            case apiStatus = "api_status"
            case apiVersion = "api_version"
            case successType = "success_type"
            case message
            case replyID = "reply_id"
        }
    }
    
    struct CommentReplyErrorModel: Codable {
        let apiStatus, apiVersion: String?
        let errors: Errors?
        
        enum CodingKeys: String, CodingKey {
            case apiStatus = "api_status"
            case apiVersion = "api_version"
            case errors
        }
    }
    
}

struct Comment: Codable {
    let id, userID, videoID, postID: Int?
    let activityID: Int?
    let text: String?
    let time: Int?
    let pinned: String?
    let likes, disLikes: Int?
    let commentUserData: Owner?
    let isLikedComment: Int?
    let isCommentOwner: Bool?
    let repliesCount: Int?
    let commentReplies: [ReplyComment]?
    let isDislikedComment: Int?
    let textTime: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case userID = "user_id"
        case videoID = "video_id"
        case postID = "post_id"
        case activityID = "activity_id"
        case text, time, pinned, likes
        case disLikes = "dis_likes"
        case commentUserData = "comment_user_data"
        case isLikedComment = "is_liked_comment"
        case isCommentOwner = "is_comment_owner"
        case repliesCount = "replies_count"
        case commentReplies = "comment_replies"
        case isDislikedComment = "is_disliked_comment"
        case textTime = "text_time"
    }
}

struct ReplyComment: Codable {
    let id, userID, commentID, videoID: Int?
    let postID: Int?
    let text, time: String?
    let replyUserData: Owner?
    let isReplyOwner: Bool?
    let isLikedReply, isDislikedReply, replyLikes, replyDislikes: Int?
    let textTime: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case userID = "user_id"
        case commentID = "comment_id"
        case videoID = "video_id"
        case postID = "post_id"
        case text, time
        case replyUserData = "reply_user_data"
        case isReplyOwner = "is_reply_owner"
        case isLikedReply = "is_liked_reply"
        case isDislikedReply = "is_disliked_reply"
        case replyLikes = "reply_likes"
        case replyDislikes = "reply_dislikes"
        case textTime = "text_time"
    }
    
}
