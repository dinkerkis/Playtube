//
//  GoLiveManager.swift
//  Playtube
//
//  Created by Abdul Moid on 18/03/2021.
//  Copyright © 2021 Muhammad Haris Butt. All rights reserved.
//

import Foundation
import Alamofire
import PlaytubeSDK

class GoLiveManager: NSObject {
    
    static let instance = GoLiveManager()
    
    func createLiveStream(streamName: String, userid: Int, type: String, Session_Token: String, completionBlock: @escaping (_ Success: [String: Any]?, _ SessionError: [String: Any]?, Error?) -> () ) {
        let params = [
            API.Params.user_id: "\(userid)",
            API.Params.Comment_Type: type,
            API.Params.stream_name : streamName,
            API.Params.session_token  : Session_Token,
            API.Params.ServerKey: API.SERVER_KEY.Server_Key
        ] as [String : Any]
        AF.request(API.LiveStreamMethod.LiveStream, method: .post, parameters: params, encoding:URLEncoding.default , headers: nil).responseJSON { (response) in
            if let Res = response.value as? [String: Any] {
                log.verbose("Result = \(Res)")
                guard let apiStatus = Res["api_status"] as? String else { return }
                if apiStatus == "200" {
                    completionBlock(Res, nil, nil)
                } else if apiStatus == "400" {
                    completionBlock(nil, Res, nil)
                }
            } else {
                log.error("error = \(response.error?.localizedDescription ?? "")")
                completionBlock(nil, nil, response.error)
            }
        }
    }
    
    func endStream(postID: String, Session_Token: String, type: String, userid: Int, completionBlock: @escaping (_ Success: [String: Any]?, _ SessionError: [String: Any]?, Error? ) -> () ) {
        let params = [
            API.Params.user_id: "\(userid)",
            API.Params.Comment_Type: type,
            API.Params.session_token: Session_Token,
            API.Params.Post_Id: postID,
            API.Params.ServerKey: API.SERVER_KEY.Server_Key
        ] as [String : Any]
        AF.request(API.LiveStreamMethod.LiveStream, method: .post, parameters: params, encoding:URLEncoding.default , headers: nil).responseJSON { (response) in
            if let Res = response.value as? [String: Any] {
                log.verbose("Result = \(Res)")
                guard let apiStatus = Res["api_status"] as? String else { return }
                if apiStatus == "200" {
                    completionBlock(Res, nil, nil)
                } else if apiStatus == "400" {
                    completionBlock(nil, Res, nil)
                }
            } else {
                log.error("error = \(response.error?.localizedDescription ?? "")")
                completionBlock(nil, nil, response.error)
            }
        }
    }
    
    func commentOnStream(commnet: String, userid: Int, Session_Token: String, videoID: String, completionBlock: @escaping (_ Success:[String: Any]?, _ SessionError: [String: Any]?, Error?) -> () ) {
        let params = [
            API.Params.user_id: "\(userid)",
            API.Params.Comment_Type: "add",
            API.Params.Video_id: videoID,
            API.Params.session_token: Session_Token,
            API.Params.Text: commnet,
            API.Params.ServerKey: API.SERVER_KEY.Server_Key
        ] as [String : Any]
        AF.request(API.LiveStreamMethod.LiveStream, method: .post, parameters: params, encoding:URLEncoding.default , headers: nil).responseJSON { (response) in
            if let Res = response.value as? [String: Any] {
                log.verbose("Result = \(Res)")
                guard let apiStatus = Res["api_status"] as? String else { return }
                if apiStatus == "200" {
                    completionBlock(Res, nil, nil)
                } else if apiStatus == "400" {
                    completionBlock(nil, Res, nil)
                }
            } else {
                log.error("error = \(response.error?.localizedDescription ?? "")")
                completionBlock(nil,nil,response.error)
            }
        }
    }
    
    func checkLiveComments(userid: Int, Session_Token: String, postID: String, completionBlock: @escaping (_ Success: [String: Any]?, _ SessionError: [String: Any]?, Error?) -> () ) {
        let params = [
            API.Params.user_id: "\(userid)",
            API.Params.Comment_Type: "check_comments",
            API.Params.session_token : Session_Token,
            API.Params.Post_Id : postID,
            API.Params.ServerKey: API.SERVER_KEY.Server_Key
        ] as [String : Any]
        AF.request(API.LiveStreamMethod.LiveStream, method: .post, parameters: params, encoding:URLEncoding.default , headers: nil).responseJSON { (response) in
            if let Res = response.value as? [String: Any] {
                log.verbose("Result = \(Res)")
                guard let apiStatus = Res["api_status"]  as? String else {return}
                if apiStatus == "200" {
                    completionBlock(Res, nil, nil)
                } else if apiStatus == "400" {
                    completionBlock(nil, Res, nil)
                }
            } else {
                log.error("error = \(response.error?.localizedDescription ?? "")")
                completionBlock(nil,nil,response.error)
            }
        }
    }
    
}
