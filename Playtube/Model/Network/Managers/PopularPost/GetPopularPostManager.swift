//
//  GetPopularPostManager.swift
//  Playtube
//
//  Created by Ubaid Javaid on 9/5/20.
//  Copyright © 2020 Muhammad Haris Butt. All rights reserved.
//

import Foundation
import Alamofire
import PlaytubeSDK

class GetPopularPostManager {
    
    static let sharedInstance = GetPopularPostManager()
    
    private init() {
        
    }
    
    func getPopularPost(type: String, sortType: String, limit: Int, lastCount: Int, channelIds: String, completionBlock: @escaping (_ Success: popularChannelModal.getPopularChannel_SuccessModal?, _ AuthError: popularChannelModal.getPopularChannel_ErrorModal?, Error?) -> () ) {
        let params = [
            API.Params.ServerKey: API.SERVER_KEY.Server_Key,
            API.Params.session_token: AppInstance.instance.sessionId ?? "",
            API.Params.user_id: AppInstance.instance.userId ?? 0,
            API.Params.Comment_Type: type,
            API.Params.Limit: limit,
            API.Params.sortType: sortType,
            API.Params.lastCount: lastCount,
            "channels_ids": channelIds
        ] as [String : Any]
        print("PARAM :=> ", params)
        print("URL :=> ", API.PopularChannelMethods.PopularChannelsApi)
        AF.request(API.PopularChannelMethods.PopularChannelsApi, method: .post, parameters: params, encoding: URLEncoding.default, headers: nil).responseJSON { (response) in
            if let Res = response.value as? [String: Any] {
                guard let api_status = Res["api_status"]  as? String else { return }
                if api_status == "200" {
                    let data = try? JSONSerialization.data(withJSONObject: Res, options: [])
                    let result = try! JSONDecoder().decode(popularChannelModal.getPopularChannel_SuccessModal.self, from: data!)
                    completionBlock(result ,nil, nil)
                } else if api_status == "400" {
                    let data = try? JSONSerialization.data(withJSONObject: Res, options: [])
                    let result = try? JSONDecoder().decode(popularChannelModal.getPopularChannel_ErrorModal.self, from: data!)
                    completionBlock(nil, result, nil)
                }
            } else {
                completionBlock(nil, nil, response.error)
            }
        }
                
    }
    
}
