//
//  EnabledTwoFactorManager.swift
//  Playtube
//
//  Created by Ubaid Javaid on 9/9/20.
//  Copyright © 2020 Muhammad Haris Butt. All rights reserved.
//

import Foundation
import Alamofire
import PlaytubeSDK

class EnableTwoFactorManager {
    
    static let sharedInstance = EnableTwoFactorManager()
    
    private init() {
        
    }
    
    func enableTwoFactor(two_factor: Int, completionBlock: @escaping (_ Success: MychannelModel.UpdateMyChannelModel.UpdateChannelSuccessModel?, _ AuthError: MychannelModel.UpdateMyChannelModel.UpdateChannelErrorModel?, Error?) -> ()) {
        let params = [
            API.Params.ServerKey: API.SERVER_KEY.Server_Key,
            API.Params.session_token: AppInstance.instance.sessionId ?? "",
            API.Params.user_id: AppInstance.instance.userId ?? 0,
            API.Params.SettingsType: API.SETTINGS_TYPE.SettingType_General,
            API.Params.Username: AppInstance.instance.userProfile?.data?.username ?? "",
            API.Params.Email: AppInstance.instance.userProfile?.data?.email ?? ""
        ] as [String : Any]
        AF.request(API.MY_CHANNEL_Methods.UPDATE_MY_CHANNEL_API, method: .post, parameters: params, encoding: URLEncoding.default, headers: nil).responseJSON { (response) in
            if let Res = response.value as? [String: Any] {
                guard let api_status = Res["api_status"] as? String else { return }
                if api_status == "200" {
                    let data = try? JSONSerialization.data(withJSONObject: Res, options: [])
                    let result = try? JSONDecoder().decode(MychannelModel.UpdateMyChannelModel.UpdateChannelSuccessModel.self, from: data!)
                    completionBlock(result, nil, nil)
                } else {
                    let data = try? JSONSerialization.data(withJSONObject: Res, options: [])
                    let result = try? JSONDecoder().decode(MychannelModel.UpdateMyChannelModel.UpdateChannelErrorModel.self, from: data!)
                    completionBlock(nil,result,nil)
                }
            } else {
                completionBlock(nil, nil, response.error)
            }
        }
    }

}
