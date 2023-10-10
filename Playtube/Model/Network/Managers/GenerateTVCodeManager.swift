//
//  GenerateTVCodeManager.swift
//  Playtube
//
//  Created by iMac on 25/05/23.
//  Copyright © 2023 ScriptSun. All rights reserved.
//

import Foundation
import PlaytubeSDK
import Alamofire

class GenerateTVCodeManager: NSObject {
    
    static let instance = GenerateTVCodeManager()
    
    func generateTVCodeAPI(completionBlock: @escaping (_ Success: GenerateTVCodeModel.GenerateTVCodeSuccessModel?, _ SessionError: GenerateTVCodeModel.GenerateTVCodeErrorModel?, Error?) -> ()) {
        let params = [
            API.Params.user_id: AppInstance.instance.userId ?? "",
            "s": AppInstance.instance.sessionId ?? "",
            API.Params.ServerKey: API.SERVER_KEY.Server_Key,
            "type": "generate"
        ] as [String: Any]
        print("url => ", API.SHORTS_VIDEOS_Methods.GET_SHORTS_VIDEOS_API)
        print("params =>", params)
        AF.request(API.TV_Methods.GENERATE_TV_CODE_API, method: .post, parameters: params, encoding: URLEncoding.default, headers: nil).responseJSON { (response) in
            if let Res = response.value as? [String: Any] {
                guard let api_status = Res["api_status"] as? String else { return }
                if api_status == "200" {
                    let data = try? JSONSerialization.data(withJSONObject: Res, options: [])
                    let result = try! JSONDecoder().decode(GenerateTVCodeModel.GenerateTVCodeSuccessModel.self, from: data!)
                    completionBlock(result, nil, nil)
                } else if api_status == "400" {
                    let data = try? JSONSerialization.data(withJSONObject: Res, options: [])
                    let result = try? JSONDecoder().decode(GenerateTVCodeModel.GenerateTVCodeErrorModel.self, from: data!)
                    completionBlock(nil, result, nil)
                }
            } else {
                completionBlock(nil, nil, response.error)
            }
        }
        
    }
    
}
