//
//  GetCategoryVideoManager.swift
//  Playtube
//
//  Created by Ubaid Javaid on 6/1/20.
//  Copyright © 2020 Muhammad Haris Butt. All rights reserved.
//

import Foundation
import Alamofire
import PlaytubeSDK

class GetCategoryVideoManager {
    
    static let sharedInstance = GetCategoryVideoManager()
    
    private init() {
        
    }
    
    func getCatVideo(User_id: Int, Session_Token: String, cat_id: String, sub_id: String, Offset: NSNumber, Limit: NSNumber, completionBlock: @escaping (_ Success: CategoryVideoModal.categoryVideo_SuccessModal?, _ AuthError :CategoryVideoModal.categoryVideo_ErrorModal?, Error?) -> () ) {
        let params = [
            API.Params.user_id: User_id,
            API.Params.session_token: Session_Token,
            API.Params.ServerKey: API.SERVER_KEY.Server_Key
        ] as [String: Any]
        print("URL :=> \(API.GET_VIDEOS_BY_CATEGORY_Method.GET_VIDEOS_BY_CATEGORY_API)&category_id=\(cat_id)&sub_id=\(sub_id)&limit=\(Limit)&offset=\(Offset)")
        print("PARAM :=> ", params)
        AF.request("\(API.GET_VIDEOS_BY_CATEGORY_Method.GET_VIDEOS_BY_CATEGORY_API)&category_id=\(cat_id)&sub_id=\(sub_id)&limit=\(Limit)&offset=\(Offset)", method: .post, parameters: params, encoding: URLEncoding.default, headers: nil).responseJSON { (response) in
            if let Res = response.value as? [String: Any] {
                guard let api_status = Res["api_status"] as? String else { return }
                if api_status == "200" {
                    let data = try? JSONSerialization.data(withJSONObject: Res, options: [])
                    let result = try? JSONDecoder().decode(CategoryVideoModal.categoryVideo_SuccessModal.self, from: data!)
                    completionBlock(result, nil, nil)
                } else if api_status == "400" {
                    let data = try? JSONSerialization.data(withJSONObject: Res, options: [])
                    let result = try? JSONDecoder().decode(CategoryVideoModal.categoryVideo_ErrorModal.self, from: data!)
                    completionBlock(nil, result, nil)
                }
            } else {
                completionBlock(nil, nil, response.error)
            }
        }
    }
    
}
