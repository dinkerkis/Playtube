//
//  NotInterestManager.swift
//  Playtube
//
//  Created by iMac on 02/06/23.
//  Copyright © 2023 ScriptSun. All rights reserved.
//

import Foundation
import PlaytubeSDK
import Alamofire

class NotInterestManager: NSObject {
    
    static let instance = NotInterestManager()
    /*
     s:50f59e4a8c63ddc5ff228f0b6f83d1b3bab1dd4816855179111d445668cbab7ef39826437b89fab349
     user_id:39066
     server_key:a04e6916b6006e72a6e654e3dc0c755b
     type:fetch
     limit:50
     */
    
    func getNotInterestDataAPI(completionBlock: @escaping (_ Success: NotInterestVideoModel.NotInterestVideoSuccessModel?, _ SessionError: NotInterestVideoModel.NotInterestVideoErrorModel?, Error?) -> ()) {
        let params = [
            API.Params.user_id: AppInstance.instance.userId ?? "",
            API.Params.session_token: AppInstance.instance.sessionId ?? "",
            API.Params.ServerKey: API.SERVER_KEY.Server_Key,
            API.Params.Comment_Type: "fetch",
            API.Params.Limit: 50
        ] as [String: Any]
        print("url => ", API.NOT_INTEREST_Methods.NOT_INTERESTED_API)
        print("params =>", params)
        AF.request(API.NOT_INTEREST_Methods.NOT_INTERESTED_API, method: .post, parameters: params, encoding: URLEncoding.default, headers: nil).responseJSON { (response) in
            if let Res = response.value as? [String: Any] {
                guard let api_status = Res["api_status"] as? String else { return }
                if api_status == "200" {
                    let data = try? JSONSerialization.data(withJSONObject: Res, options: [])
                    let result = try! JSONDecoder().decode(NotInterestVideoModel.NotInterestVideoSuccessModel.self, from: data!)
                    completionBlock(result, nil, nil)
                } else if api_status == "400" {
                    let data = try? JSONSerialization.data(withJSONObject: Res, options: [])
                    let result = try? JSONDecoder().decode(NotInterestVideoModel.NotInterestVideoErrorModel.self, from: data!)
                    completionBlock(nil, result, nil)
                }
            } else {
                completionBlock(nil, nil, response.error)
            }
        }
    }
    
    func addNotInterestAPI(videoID: Int, completionBlock: @escaping (_ Success: AddNotInterestVideoModel.AddNotInterestVideoSuccessModel?, _ SessionError: AddNotInterestVideoModel.AddNotInterestVideoErrorModel?, Error?) -> ()) {
        let params = [
            API.Params.user_id: AppInstance.instance.userId ?? "",
            API.Params.session_token: AppInstance.instance.sessionId ?? "",
            API.Params.ServerKey: API.SERVER_KEY.Server_Key,
            API.Params.Comment_Type: "add",
            API.Params.Video_id: videoID
        ] as [String: Any]
        print("url => ", API.NOT_INTEREST_Methods.NOT_INTERESTED_API)
        print("params =>", params)
        AF.request(API.NOT_INTEREST_Methods.NOT_INTERESTED_API, method: .post, parameters: params, encoding: URLEncoding.default, headers: nil).responseJSON { (response) in
            if let Res = response.value as? [String: Any] {
                guard let api_status = Res["api_status"] as? String else { return }
                if api_status == "200" {
                    let data = try? JSONSerialization.data(withJSONObject: Res, options: [])
                    let result = try! JSONDecoder().decode(AddNotInterestVideoModel.AddNotInterestVideoSuccessModel.self, from: data!)
                    completionBlock(result, nil, nil)
                } else if api_status == "400" {
                    let data = try? JSONSerialization.data(withJSONObject: Res, options: [])
                    let result = try? JSONDecoder().decode(AddNotInterestVideoModel.AddNotInterestVideoErrorModel.self, from: data!)
                    completionBlock(nil, result, nil)
                }
            } else {
                completionBlock(nil, nil, response.error)
            }
        }
    }    
}
