import Foundation
import Alamofire
import PlaytubeSDK
import UIKit

class PlayVideoManager: NSObject {
    
    static let instance = PlayVideoManager()
    
    func getVideosDetailsByVideoId(User_id: Int, Session_Token: String, VideoId: String, completionBlock: @escaping (_ Success: PlayVideoModel.PlayVideoSuccessModel?, _ SessionError: PlayVideoModel.PlayVideoErrorModel?, Error?) -> () ) {
        let params = [
            API.Params.user_id : User_id,
            API.Params.session_token : Session_Token,
            API.Params.ServerKey : API.SERVER_KEY.Server_Key,
            "android_id" : (UIDevice.current.identifierForVendor?.uuidString ?? "")
        ] as [String : Any]
        print("URL: => ", API.PLAY_VIDEO_Methods.PLAY_VIDEO_API + VideoId)
        print("PARAM: => ", params)
        AF.request(API.PLAY_VIDEO_Methods.PLAY_VIDEO_API + "\(VideoId)", method: .post, parameters: params, encoding: URLEncoding.default , headers: nil).responseJSON(completionHandler: { (response) in
            print(API.PLAY_VIDEO_Methods.PLAY_VIDEO_API + "\(VideoId)")
            if let Res = response.value as? [String: Any] {
                //print("Response >>>>>", Res)
                guard let api_status = Res["api_status"] as? String else { return }
                if api_status == "200" {
                    let data = try? JSONSerialization.data(withJSONObject: Res, options: [])
                    let result = try! JSONDecoder().decode(PlayVideoModel.PlayVideoSuccessModel.self, from: data!)
                    completionBlock(result, nil, nil)
                } else if api_status == "400" {
                    let data = try? JSONSerialization.data(withJSONObject: Res, options: [])
                    let result = try? JSONDecoder().decode(PlayVideoModel.PlayVideoErrorModel.self, from: data!)
                    completionBlock(nil, result, nil)
                }
            } else {
                completionBlock(nil, nil, response.error)
            }
        })
    }
    
    func fetchComments(User_id: Int, Session_Token: String, VideoId: Int, completionBlock: @escaping (_ Success: CommentModel.CommentSuccessModel?, _ SessionError: CommentModel.CommentErrorModel?, Error?) -> () ) {
        let params = [
            API.Params.user_id : User_id,
            API.Params.session_token : Session_Token,
            API.Params.ServerKey : API.SERVER_KEY.Server_Key,
            API.Params.Video_id : VideoId,
            API.Params.Comment_Type : API.Params.Fetch_Comment
        ] as [String : Any]
        print("URL: => ", API.COMMENT_Methods.COMMENT_API)
        print("PARAM: => ", params)
        AF.request(API.COMMENT_Methods.COMMENT_API, method: .post, parameters: params, encoding: URLEncoding.default, headers: nil).responseJSON { (response) in
            if let Res = response.value as? [String: Any] {
                // print("Response >>>>>", Res)
                guard let api_status = Res["api_status"] as? String else { return }
                if api_status == "200" {
                    let data = try? JSONSerialization.data(withJSONObject: Res, options: [])
                    let result = try? JSONDecoder().decode(CommentModel.CommentSuccessModel.self, from: data!)
                    completionBlock(result, nil, nil)
                } else if api_status == "400" {
                    let data = try? JSONSerialization.data(withJSONObject: Res, options: [])
                    let result = try? JSONDecoder().decode(CommentModel.CommentErrorModel.self, from: data!)
                    completionBlock(nil, result, nil)
                }
            } else {
                completionBlock(nil, nil, response.error)
            }
        }
    }
    
    func addComments(User_id: Int, Session_Token: String, VideoId: Int, Comment_Text: String, completionBlock: @escaping (_ Success: AddCommentModel.AddCommentSuccessModel?, _ SessionError: AddCommentModel.AddCommentErrorModel?, Error?) -> () ) {
        let params = [
            API.Params.Text : Comment_Text,
            API.Params.user_id : User_id,
            API.Params.session_token : Session_Token,
            API.Params.ServerKey : API.SERVER_KEY.Server_Key,
            API.Params.Video_id : VideoId,
            API.Params.Comment_Type : API.Params.Add_Comment
        ] as [String : Any]
        AF.request(API.COMMENT_Methods.COMMENT_API, method: .post, parameters: params, encoding: URLEncoding.default, headers: nil).responseJSON { (response) in
            if let Res = response.value as? [String: Any] {
                // print("Response >>>>>", Res)
                guard let api_status = Res["api_status"] as? String else { return }
                if api_status == "200" {
                    let data = try? JSONSerialization.data(withJSONObject: Res, options: [])
                    let result = try? JSONDecoder().decode(AddCommentModel.AddCommentSuccessModel.self, from: data!)
                    completionBlock(result, nil, nil)
                } else if api_status == "400" {
                    let data = try? JSONSerialization.data(withJSONObject: Res, options: [])
                    let result = try? JSONDecoder().decode(AddCommentModel.AddCommentErrorModel.self, from: data!)
                    completionBlock(nil, result, nil)
                }
            } else {
                completionBlock(nil, nil, response.error)
            }
        }
    }
    
    func addCommentReply(User_id: Int, Session_Token: String, VideoId: Int, Comment_Id: Int, Type: String, Comment_Text: String, completionBlock: @escaping (_ Success: CommentReplyModel.CommentReplySuccessModel?, _ SessionError: CommentReplyModel.CommentReplyErrorModel?, Error?) -> () ) {
        let params = [
            API.Params.Text : Comment_Text,
            API.Params.user_id : User_id,
            API.Params.session_token : Session_Token,
            API.Params.ServerKey : API.SERVER_KEY.Server_Key,
            API.Params.Video_id : VideoId,
            API.Params.Comment_Type : Type,
            API.Params.Comment_Id : Comment_Id
        ] as [String : Any]
        AF.request(API.COMMENT_Methods.COMMENT_API, method: .post, parameters: params, encoding: URLEncoding.default, headers: nil).responseJSON { (response) in
            if let Res = response.value as? [String: Any] {
                // print("Response >>>>>", Res)
                guard let api_status = Res["api_status"]  as? String else { return }
                if api_status == "200" {
                    let data = try? JSONSerialization.data(withJSONObject: Res, options: [])
                    let result = try? JSONDecoder().decode(CommentReplyModel.CommentReplySuccessModel.self, from: data!)
                    completionBlock(result, nil, nil)
                } else if api_status == "400" {
                    let data = try? JSONSerialization.data(withJSONObject: Res, options: [])
                    let result = try? JSONDecoder().decode(CommentReplyModel.CommentReplyErrorModel.self, from: data!)
                    completionBlock(nil, result, nil)
                }
            } else {
                completionBlock(nil, nil, response.error)
            }
        }
    }
    
    func likeComments(User_id: Int, Session_Token: String, Type: String, Comment_Id: Int, completionBlock: @escaping (_ Success: LikeCommentModel.LikeCommentSuccessModel?, _ SessionError: LikeCommentModel.LikeCommentErrorModel?, Error?) -> () ) {
        let params = [
            API.Params.Comment_Id : Comment_Id,
            API.Params.user_id : User_id,
            API.Params.session_token : Session_Token,
            API.Params.ServerKey : API.SERVER_KEY.Server_Key,
            API.Params.Comment_Type : Type
        ] as [String : Any]
        AF.request(API.COMMENT_Methods.COMMENT_API, method: .post, parameters: params, encoding:URLEncoding.default , headers: nil).responseJSON { (response) in
            if let Res = response.value as? [String: Any] {
                // print("Response >>>>>", Res)
                guard let api_status = Res["api_status"] as? String else { return }
                if api_status == "200" {
                    let data = try? JSONSerialization.data(withJSONObject: Res, options: [])
                    let result = try? JSONDecoder().decode(LikeCommentModel.LikeCommentSuccessModel.self, from: data!)
                    completionBlock(result, nil, nil)
                }else if api_status == "400" {
                    let data = try? JSONSerialization.data(withJSONObject: Res, options: [])
                    let result = try? JSONDecoder().decode(LikeCommentModel.LikeCommentErrorModel.self, from: data!)
                    completionBlock(nil, result, nil)
                }
            } else {
                completionBlock(nil, nil, response.error)
            }
        }
        
    }
    
    func dislikeComments(User_id: Int, Session_Token: String, Type: String, Comment_Id: Int, completionBlock: @escaping (_ Success: DislikeCommentModel.DislikeCommentSuccessModel?, _ SessionError: DislikeCommentModel.DislikeCommentErrorModel?, Error?) -> () ) {
        let params = [
            API.Params.Comment_Id : Comment_Id,
            API.Params.user_id : User_id,
            API.Params.session_token : Session_Token,
            API.Params.ServerKey : API.SERVER_KEY.Server_Key,
            API.Params.Comment_Type : Type
        ] as [String : Any]
        AF.request(API.COMMENT_Methods.COMMENT_API, method: .post, parameters: params, encoding: URLEncoding.default, headers: nil).responseJSON { (response) in
            if let Res = response.value as? [String: Any] {
                // print("Response >>>>>", Res)
                guard let api_status = Res["api_status"]  as? String else { return }
                if api_status == "200" {
                    let data = try? JSONSerialization.data(withJSONObject: Res, options: [])
                    let result = try? JSONDecoder().decode(DislikeCommentModel.DislikeCommentSuccessModel.self, from: data!)
                    completionBlock(result, nil, nil)
                } else if api_status == "400" {
                    let data = try? JSONSerialization.data(withJSONObject: Res, options: [])
                    let result = try? JSONDecoder().decode(DislikeCommentModel.DislikeCommentErrorModel.self, from: data!)
                    completionBlock(nil, result, nil)
                }
            } else {
                completionBlock(nil, nil, response.error)
            }
        }
    }
    
    func likeCommentReplies(User_id: Int, Session_Token: String, Type: String, Reply_Id: Int, completionBlock: @escaping (_ Success: LikeCommentModel.LikeCommentSuccessModel?, _ SessionError: LikeCommentModel.LikeCommentErrorModel?, Error?) -> () ) {
        let params = [
            API.Params.reply_id : Reply_Id,
            API.Params.user_id : User_id,
            API.Params.session_token : Session_Token,
            API.Params.ServerKey : API.SERVER_KEY.Server_Key,
            API.Params.Comment_Type : Type
        ] as [String : Any]
        AF.request(API.COMMENT_Methods.COMMENT_API, method: .post, parameters: params, encoding: URLEncoding.default, headers: nil).responseJSON { (response) in
            if let Res = response.value as? [String: Any] {
                // print("Response >>>>>", Res)
                guard let api_status = Res["api_status"] as? String else { return }
                if api_status == "200" {
                    let data = try? JSONSerialization.data(withJSONObject: Res, options: [])
                    let result = try? JSONDecoder().decode(LikeCommentModel.LikeCommentSuccessModel.self, from: data!)
                    completionBlock(result, nil, nil)
                } else if api_status == "400" {
                    let data = try? JSONSerialization.data(withJSONObject: Res, options: [])
                    let result = try? JSONDecoder().decode(LikeCommentModel.LikeCommentErrorModel.self, from: data!)
                    completionBlock(nil, result, nil)
                }
            } else {
                completionBlock(nil, nil, response.error)
            }
        }
    }
    
    func dislikeCommentReplies(User_id: Int, Session_Token: String, Type: String, Reply_id: Int, completionBlock: @escaping (_ Success: DislikeCommentModel.DislikeCommentSuccessModel?, _ SessionError: DislikeCommentModel.DislikeCommentErrorModel?, Error?) -> () ) {
        let params = [
            API.Params.reply_id : Reply_id,
            API.Params.user_id : User_id,
            API.Params.session_token : Session_Token,
            API.Params.ServerKey : API.SERVER_KEY.Server_Key,
            API.Params.Comment_Type : Type
        ] as [String : Any]
        AF.request(API.COMMENT_Methods.COMMENT_API, method: .post, parameters: params, encoding: URLEncoding.default, headers: nil).responseJSON { (response) in
            if let Res = response.value as? [String: Any] {
                // print("Response >>>>>", Res)
                guard let api_status = Res["api_status"] as? String else { return }
                if api_status == "200" {
                    let data = try? JSONSerialization.data(withJSONObject: Res, options: [])
                    let result = try? JSONDecoder().decode(DislikeCommentModel.DislikeCommentSuccessModel.self, from: data!)
                    completionBlock(result, nil, nil)
                } else if api_status == "400" {
                    let data = try? JSONSerialization.data(withJSONObject: Res, options: [])
                    let result = try? JSONDecoder().decode(DislikeCommentModel.DislikeCommentErrorModel.self, from: data!)
                    completionBlock(nil, result, nil)
                }
            } else {
                completionBlock(nil, nil, response.error)
            }
        }
    }
    
    func fetchReplies(User_id: Int, Session_Token: String, Type: String, Comment_Id: Int, completionBlock: @escaping (_ Success: RepliesModel.RepliesSuccessModel?, _ SessionError: RepliesModel.RepliesErrorModel?, Error?) -> () ) {
        let params = [
            API.Params.Comment_Id : Comment_Id,
            API.Params.user_id : User_id,
            API.Params.session_token : Session_Token,
            API.Params.ServerKey : API.SERVER_KEY.Server_Key,
            API.Params.Comment_Type : Type
        ] as [String : Any]
        AF.request(API.COMMENT_Methods.COMMENT_API, method: .post, parameters: params, encoding:URLEncoding.default , headers: nil).responseJSON { (response) in
            if let Res = response.value as? [String: Any] {
                // print("Response >>>>>", Res)
                guard let api_status = Res["api_status"] as? String else { return }
                if api_status == "200" {
                    let data = try? JSONSerialization.data(withJSONObject: Res, options: [])
                    let result = try? JSONDecoder().decode(RepliesModel.RepliesSuccessModel.self, from: data!)
                    completionBlock(result, nil, nil)
                } else if api_status == "400" {
                    let data = try? JSONSerialization.data(withJSONObject: Res, options: [])
                    let result = try? JSONDecoder().decode(RepliesModel.RepliesErrorModel.self, from: data!)
                    completionBlock(nil, result, nil)
                }
            } else {
                completionBlock(nil, nil, response.error)
            }
        }
    }
    
    func subUnsubChannel(User_id: Int, Session_Token: String, Channel_Id: Int, completionBlock: @escaping (_ Success: SubscribeModel.SubscribeSuccessModel?, _ SessionError: SubscribeModel.SubscribeErrorModel?, Error?) -> () ) {
        let params = [
            API.Params.user_id : User_id,
            API.Params.session_token : Session_Token,
            API.Params.ServerKey : API.SERVER_KEY.Server_Key,
        ] as [String : Any]
        AF.request(API.SUBSCRIBE_Methods.SUBSCRIBE_CHANNEL_API + "\(Channel_Id)", method: .post, parameters: params, encoding: URLEncoding.default, headers: nil).responseJSON { (response) in
            if let Res = response.value as? [String: Any] {
                // print("Response >>>>>", Res)
                guard let api_status = Res["api_status"] as? String else { return }
                if api_status == "200" {
                    let data = try? JSONSerialization.data(withJSONObject: Res, options: [])
                    let result = try? JSONDecoder().decode(SubscribeModel.SubscribeSuccessModel.self, from: data!)
                    completionBlock(result, nil, nil)
                } else if api_status == "400" {
                    let data = try? JSONSerialization.data(withJSONObject: Res, options: [])
                    let result = try? JSONDecoder().decode(SubscribeModel.SubscribeErrorModel.self, from: data!)
                    completionBlock(nil, result, nil)
                }
            } else {
                completionBlock(nil, nil, response.error)
            }
        }
    }
    
    func likeDislikeVideos(User_id: Int, Session_Token: String, Video_Id: Int, Like_Type: String, completionBlock: @escaping (_ Success: LikeDislikeModel.LikeDislikeSuccessModel?, _ SessionError: LikeDislikeModel.LikeDislikeErrorModel?, Error?) -> () ) {
        let params = [
            API.Params.Action : Like_Type,
            API.Params.Video_id : Video_Id,
            API.Params.user_id : User_id,
            API.Params.session_token : Session_Token,
            API.Params.ServerKey : API.SERVER_KEY.Server_Key,
        ] as [String : Any]
        AF.request(API.PLAY_VIDEO_Methods.LIKE_DISLIKE_API, method: .post, parameters: params, encoding: URLEncoding.default, headers: nil).responseJSON { (response) in
            if let Res = response.value as? [String: Any] {
                // print("Response >>>>>", Res)
                guard let api_status = Res["api_status"] as? String else { return }
                if api_status == "200" {
                    let data = try? JSONSerialization.data(withJSONObject: Res, options: [])
                    let result = try? JSONDecoder().decode(LikeDislikeModel.LikeDislikeSuccessModel.self, from: data!)
                    completionBlock(result, nil, nil)
                } else if api_status == "400" {
                    let data = try? JSONSerialization.data(withJSONObject: Res, options: [])
                    let result = try? JSONDecoder().decode(LikeDislikeModel.LikeDislikeErrorModel.self, from: data!)
                    completionBlock(nil, result, nil)
                }
            } else {
                completionBlock(nil, nil, response.error)
            }
        }
    }
    
}
