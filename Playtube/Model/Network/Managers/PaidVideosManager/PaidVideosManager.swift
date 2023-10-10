//
//  PaidVideosManager.swift
//  Playtube
//
//  Created by Ubaid Javaid on 9/17/20.
//  Copyright © 2020 Muhammad Haris Butt. All rights reserved.
//

import Foundation
import Alamofire
import PlaytubeSDK

class PaidVideosManager {
    
    static let sharedInstance = PaidVideosManager()
    
    private init() {
        
    }
    
    func getPaidVideos(completionBlock: @escaping (_ Success: PaidVideosModal.PaidVideos_SuccessModal?, _ AuthError: PaidVideosModal.PaidVideos_ErrorModal?, Error?) -> () ) {
        let params = [
            API.Params.ServerKey: API.SERVER_KEY.Server_Key,
            API.Params.session_token: AppInstance.instance.sessionId ?? "",
            API.Params.user_id: AppInstance.instance.userId ?? 0,
            API.Params.Comment_Type: "all"
        ] as [String : Any]
        AF.request(API.LIBRARY_VIDEOS_Methods.PaidVideoApi, method: .post, parameters: params, encoding: URLEncoding.default, headers: nil).responseJSON { (response) in
            if let res = response.value as? [String: Any] {
                guard let api_status = res["api_status"] as? String else { return }
                if api_status == "200" {
                    let data = try? JSONSerialization.data(withJSONObject: res, options: [])
                    let result = try? JSONDecoder().decode(PaidVideosModal.PaidVideos_SuccessModal.self, from: data!)
                    completionBlock(result, nil, nil)
                } else {
                    let data = try? JSONSerialization.data(withJSONObject: res, options: [])
                    let result = try? JSONDecoder().decode(PaidVideosModal.PaidVideos_ErrorModal.self, from: data!)
                    completionBlock(nil, result, nil)
                }
            } else {
                completionBlock(nil, nil, response.error)
            }
        }
    }
    
}
