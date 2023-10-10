//
//  UserActivityManager.swift
//  Playtube
//
//  Created by Ubaid Javaid on 9/17/20.
//  Copyright © 2020 Muhammad Haris Butt. All rights reserved.
//

import Foundation
import Alamofire
import PlaytubeSDK

class UserActivityManager {
    
    static let sharedInstance = UserActivityManager()
    
    private init() {
        
    }
    
    func getActivity(limit: Int, offsetInt: Int, profileId: Int, completionBlock: @escaping (_ Success: UserActivityModal.UserActivity_SuccessModal?, _ AuthError: UserActivityModal.UserActivity_ErrorModal?, Error?) -> () ) {
        let params = [
            API.Params.ServerKey: API.SERVER_KEY.Server_Key,
            API.Params.session_token: AppInstance.instance.sessionId ?? "",
            API.Params.user_id: AppInstance.instance.userId ?? 0,
            API.Params.Comment_Type: "user_activity",
            API.Params.profileId: profileId,
            API.Params.Limit: limit,
            API.Params.Offset: offsetInt
        ] as [String : Any]
        AF.request(API.Activity_Methods.ACTIVITY_API, method: .post, parameters: params, encoding: URLEncoding.default, headers: nil).responseJSON { (response) in
            if let res = response.value as? [String: Any] {
                guard let api_status = res["api_status"]  as? String else { return }
                if api_status == "200" {
                    let data = try? JSONSerialization.data(withJSONObject: res, options: [])
                    let result = try? JSONDecoder().decode(UserActivityModal.UserActivity_SuccessModal.self, from: data!)
                    completionBlock(result, nil, nil)
                } else {
                    let data = try? JSONSerialization.data(withJSONObject: res, options: [])
                    let result = try? JSONDecoder().decode(UserActivityModal.UserActivity_ErrorModal.self, from: data!)
                    completionBlock(nil, result, nil)
                }
            } else {
                completionBlock(nil, nil, response.error)
            }
        }
    }
    
    func likeDislikeActivity(type: String, id: Int, completionBlock: @escaping (_ Success: LikeDislikeModel.LikeDislikeSuccessModel?, _ AuthError: LikeDislikeModel.LikeDislikeErrorModel?, Error?) -> () ) {
        let params = [
            API.Params.ServerKey: API.SERVER_KEY.Server_Key,
            API.Params.session_token: AppInstance.instance.sessionId ?? "",
            API.Params.user_id: AppInstance.instance.userId ?? 0,
            API.Params.Comment_Type: type,
            API.Params.Id: id
        ] as [String: Any]
        AF.request(API.Activity_Methods.ACTIVITY_API, method: .post, parameters: params, encoding: URLEncoding.default, headers: nil).responseJSON { (response) in
            if let res = response.value as? [String: Any] {
                guard let api_status = res["api_status"]  as? String else {return}
                if api_status == "200" {
                    let data = try? JSONSerialization.data(withJSONObject: res, options: [])
                    let result = try? JSONDecoder().decode(LikeDislikeModel.LikeDislikeSuccessModel.self, from: data!)
                    completionBlock(result, nil, nil)
                } else {
                    let data = try? JSONSerialization.data(withJSONObject: res, options: [])
                    let result = try? JSONDecoder().decode(LikeDislikeModel.LikeDislikeErrorModel.self, from: data!)
                    completionBlock(nil, result, nil)
                }
            } else {
                completionBlock(nil, nil, response.error)
            }
        }
    }
    
    func fetchActivityComments(user_id: Int, session_Token: String, activity_id: Int, completionBlock: @escaping (_ Success: CommentModel.CommentSuccessModel?, _ SessionError: CommentModel.CommentErrorModel?, Error?) -> () ) {
        let params = [
            API.Params.session_token : session_Token,
            API.Params.user_id : user_id,
            API.Params.Comment_Type : API.Params.Fetch_Comment,
            API.Params.activity_id : activity_id,
            API.Params.ServerKey : API.SERVER_KEY.Server_Key
        ] as [String : Any]
        print("URL: => ", API.Activity_Methods.ACTIVITY_API)
        print("PARAM: => ", params)
        AF.request(API.Activity_Methods.ACTIVITY_API, method: .post, parameters: params, encoding: URLEncoding.default, headers: nil).responseJSON { (response) in
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
    
    func createActivityComments(user_id: Int, session_Token: String, activity_id: Int, comment_Text: String, completionBlock: @escaping (_ Success: AddCommentModel.AddCommentSuccessModel?, _ SessionError: AddCommentModel.AddCommentErrorModel?, Error?) -> () ) {
        let params = [
            API.Params.session_token : session_Token,
            API.Params.user_id : user_id,
            API.Params.Comment_Type : "create_comment",
            API.Params.activity_id : activity_id,
            API.Params.ServerKey : API.SERVER_KEY.Server_Key,
            API.Params.Text : comment_Text
        ] as [String : Any]
        print("URL: => ", API.Activity_Methods.ACTIVITY_API)
        print("PARAM: => ", params)
        AF.request(API.Activity_Methods.ACTIVITY_API, method: .post, parameters: params, encoding: URLEncoding.default, headers: nil).responseJSON { (response) in
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
    
    func fetchActivityReplyComments(user_id: Int, session_Token: String, comment_Id: Int, completionBlock: @escaping (_ Success: RepliesModel.RepliesSuccessModel?, _ SessionError: RepliesModel.RepliesErrorModel?, Error?) -> () ) {
        let params = [
            API.Params.session_token : session_Token,
            API.Params.user_id : user_id,
            API.Params.Comment_Type : "fetch_replies",
            API.Params.Comment_Id : comment_Id,
            API.Params.ServerKey : API.SERVER_KEY.Server_Key
        ] as [String : Any]
        print("URL: => ", API.Activity_Methods.ACTIVITY_API)
        print("PARAM: => ", params)
        AF.request(API.Activity_Methods.ACTIVITY_API, method: .post, parameters: params, encoding: URLEncoding.default, headers: nil).responseJSON { (response) in
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
    
    func activityReplyComments(user_id: Int, session_Token: String, activity_id: Int, comment_Id: Int, comment_Text: String, completionBlock: @escaping (_ Success: AddCommentModel.AddCommentSuccessModel?, _ SessionError: AddCommentModel.AddCommentErrorModel?, Error?) -> () ) {
        let params = [
            API.Params.session_token : session_Token,
            API.Params.user_id : user_id,
            API.Params.Comment_Type : "reply_comment",
            API.Params.activity_id : activity_id,
            API.Params.ServerKey : API.SERVER_KEY.Server_Key,
            API.Params.Comment_Id: comment_Id,
            API.Params.Text : comment_Text
        ] as [String : Any]
        print("URL: => ", API.Activity_Methods.ACTIVITY_API)
        print("PARAM: => ", params)
        AF.request(API.Activity_Methods.ACTIVITY_API, method: .post, parameters: params, encoding: URLEncoding.default, headers: nil).responseJSON { (response) in
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
    
    func likeActivityReplyComments(User_id: Int, Session_Token: String, Type: String, reply_id: Int, completionBlock: @escaping (_ Success: LikeCommentModel.LikeCommentSuccessModel?, _ SessionError: LikeCommentModel.LikeCommentErrorModel?, Error?) -> () ) {
        let params = [
            API.Params.reply_id: reply_id,
            API.Params.user_id: User_id,
            API.Params.session_token: Session_Token,
            API.Params.ServerKey: API.SERVER_KEY.Server_Key,
            API.Params.Comment_Type: Type
            ] as [String: Any]
        AF.request(API.COMMENT_Methods.COMMENT_API, method: .post, parameters: params, encoding: URLEncoding.default, headers: nil).responseJSON { (response) in
            if let Res = response.value as? [String: Any] {
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
    
    func dislikeActivityReplyComments(User_id: Int, Session_Token: String, Type: String, reply_id: Int, completionBlock: @escaping (_ Success: DislikeCommentModel.DislikeCommentSuccessModel?, _ SessionError: DislikeCommentModel.DislikeCommentErrorModel?, Error?) -> () ) {
        let params = [
            API.Params.reply_id : reply_id,
            API.Params.user_id : User_id,
            API.Params.session_token : Session_Token,
            API.Params.ServerKey : API.SERVER_KEY.Server_Key,
            API.Params.Comment_Type : Type
            ] as [String : Any]
        AF.request(API.COMMENT_Methods.COMMENT_API, method: .post, parameters: params, encoding:URLEncoding.default, headers: nil).responseJSON { (response) in
            if let Res = response.value as? [String: Any] {
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
    
}
