//
//  ShortsManager.swift
//  Playtube
//
//  Created by CODEWRYTERS on 10/10/22.
//  Copyright © 2022 Muhammad Haris Butt. All rights reserved.
//

import UIKit
import Alamofire
import PlaytubeSDK

class ShortsManager: NSObject {
    
    static let instance = ShortsManager()
    
    func getShortsData(User_id: Int, Session_Token: String, Limit: Int, Offset: String, completionBlock: @escaping (_ Success: ShortsModel.ShortsSuccessModel?, _ SessionError: ShortsModel.ShortsErrorModel?, Error?) -> ()) {
        let params = [
            API.Params.user_id: User_id,
            "s": Session_Token,
            API.Params.ServerKey: API.SERVER_KEY.Server_Key,
            API.Params.Comment_Type: "get_shorts",
            API.Params.Limit: Limit,
            API.Params.Offset: Offset
        ] as [String: Any]
        print("url => ", API.SHORTS_VIDEOS_Methods.GET_SHORTS_VIDEOS_API)
        print("params =>", params)
        AF.request(API.SHORTS_VIDEOS_Methods.GET_SHORTS_VIDEOS_API, method: .post, parameters: params, encoding: URLEncoding.default, headers: nil).responseJSON { (response) in
            if let Res = response.value as? [String: Any] {
                guard let api_status = Res["api_status"] as? String else { return }
                if api_status == "200" {
                    let data = try? JSONSerialization.data(withJSONObject: Res, options: [])
                    let result = try! JSONDecoder().decode(ShortsModel.ShortsSuccessModel.self, from: data!)
                    completionBlock(result, nil, nil)
                } else if api_status == "400" {
                    let data = try? JSONSerialization.data(withJSONObject: Res, options: [])
                    let result = try? JSONDecoder().decode(ShortsModel.ShortsErrorModel.self, from: data!)
                    completionBlock(nil, result, nil)
                }
            } else {
                completionBlock(nil, nil, response.error)
            }
        }
        
    }
    
    func getUserShortsData(User_id: Int, Session_Token: String, profile_id: Int, Limit: Int, Offset: String, completionBlock: @escaping (_ Success: ShortsModel.ShortsSuccessModel?, _ SessionError: ShortsModel.ShortsErrorModel?, Error?) -> ()) {
        let params = [
            API.Params.user_id: User_id,
            "s": Session_Token,
            API.Params.ServerKey: API.SERVER_KEY.Server_Key,
            API.Params.Comment_Type: "get_user_shorts",
            API.Params.Limit: Limit,
            API.Params.Offset: Offset,
            API.Params.profileId: profile_id
        ] as [String: Any]
        print("url => ", API.SHORTS_VIDEOS_Methods.GET_SHORTS_VIDEOS_API)
        print("params =>", params)
        AF.request(API.SHORTS_VIDEOS_Methods.GET_SHORTS_VIDEOS_API, method: .post, parameters: params, encoding: URLEncoding.default, headers: nil).responseJSON { (response) in
            if let Res = response.value as? [String: Any] {
                guard let api_status = Res["api_status"] as? String else { return }
                if api_status == "200" {
                    let data = try? JSONSerialization.data(withJSONObject: Res, options: [])
                    let result = try! JSONDecoder().decode(ShortsModel.ShortsSuccessModel.self, from: data!)
                    completionBlock(result, nil, nil)
                } else if api_status == "400" {
                    let data = try? JSONSerialization.data(withJSONObject: Res, options: [])
                    let result = try? JSONDecoder().decode(ShortsModel.ShortsErrorModel.self, from: data!)
                    completionBlock(nil, result, nil)
                }
            } else {
                completionBlock(nil, nil, response.error)
            }
        }
        
    }
}
