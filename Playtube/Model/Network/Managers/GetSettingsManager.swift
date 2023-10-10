import Foundation
import Alamofire
import PlaytubeSDK

class GetSettingsManager: NSObject {
    
    static let instance = GetSettingsManager()
    
    func getSetting(completionBlock: @escaping (_ categories: [String: String]?, _ siteSetting: [String: Any]?, _ SuccessError: [GetSettings.GetSuccessSettings]?, _ SessionError: GetSettings.GetSettingsErrorModel?, Error?) -> () ) {
        let params = [
            API.Params.ServerKey: API.SERVER_KEY.Server_Key
        ] as [String: Any]
        AF.request(API.SETTINGS_METHODS.GET_SETTIGNS_API, method: .post, parameters: params, encoding: URLEncoding.default, headers: nil).responseJSON { (response) in
            if let Res = response.value as? [String: Any] {
                guard let api_status = Res["api_status"] as? String else { return }
                if api_status == "200" {
                    guard let data = Res["data"] as? [String: Any] else{ return }
                    guard let siteSettings = data["site_settings"] as? [String: Any] else { return }
                    completionBlock(nil, siteSettings, nil, nil, nil)
                } else if api_status == "400" {
                    let data = try? JSONSerialization.data(withJSONObject: Res, options: [])
                    let result = try? JSONDecoder().decode(GetSettings.GetSettingsErrorModel.self, from: data!)
                    completionBlock(nil, nil, nil, result, nil)
                }
            } else {
                completionBlock(nil, nil, nil, nil, response.error)
            }
        }
    }
    
    func updatePauseWatchHistory(completionBlock: @escaping (_ Success: MychannelModel.UpdateMyChannelModel.UpdateChannelSuccessModel?, _ AuthError: MychannelModel.UpdateMyChannelModel.UpdateChannelErrorModel?, Error?) -> ()) {
        let params = [
            API.Params.ServerKey: API.SERVER_KEY.Server_Key,
            API.Params.session_token: AppInstance.instance.sessionId ?? "",
            API.Params.user_id: AppInstance.instance.userId ?? 0,
            API.Params.SettingsType: API.SETTINGS_TYPE.SettingType_Pause_History,
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
