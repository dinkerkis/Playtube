import Foundation
import Alamofire
import PlaytubeSDK

class MyChannelManager: NSObject {
    
    static let instance = MyChannelManager()
    
    func changePassword(User_id: Int, Session_Token: String, CurrentPassword: String, NewPassword: String, RepeatPassword: String, completionBlock: @escaping (_ Success: MychannelModel.ChangePasswordModel.ChangePassordSuccessModel?, _ SessionError: MychannelModel.ChangePasswordModel.ChangePassordErrorModel?, Error?) -> () ) {
        let params = [
            API.Params.user_id: User_id,
            API.Params.session_token: Session_Token,
            API.Params.CurrentPassword: CurrentPassword,
            API.Params.NewPassword: NewPassword,
            API.Params.RepeatPassword: RepeatPassword,
            API.Params.ServerKey: API.SERVER_KEY.Server_Key
        ] as [String: Any]
        AF.request(API.MY_CHANNEL_Methods.CHANGE_PASSWORD_API, method: .post, parameters: params, encoding: URLEncoding.default, headers: nil).responseJSON { (response) in
            if let Res = response.value as? [String: Any] {
                guard let api_status = Res["api_status"]  as? String else { return }
                if api_status == "200" {
                    let data = try? JSONSerialization.data(withJSONObject: Res, options: [])
                    let result = try? JSONDecoder().decode(MychannelModel.ChangePasswordModel.ChangePassordSuccessModel.self, from: data!)
                    completionBlock(result, nil, nil)
                } else if api_status == "400" {
                    let data = try? JSONSerialization.data(withJSONObject: Res, options: [])
                    let result = try? JSONDecoder().decode(MychannelModel.ChangePasswordModel.ChangePassordErrorModel.self, from: data!)
                    completionBlock(nil, result, nil)
                }
            } else {
                completionBlock(nil, nil, response.error)
            }
        }
    }
    
    func editMyChannel(User_id: Int, Session_Token: String, Username: String, FirstName: String, LastName: String, Email: String,  About: String, Gender: String, facebook: String, twitter: String, Google: String, completionBlock: @escaping (_ Success: MychannelModel.UpdateMyChannelModel.UpdateChannelSuccessModel?, _ AuthError: MychannelModel.UpdateMyChannelModel.UpdateChannelErrorModel?, Error?) -> () ) {
        let params = [
            API.Params.user_id : User_id,
            API.Params.session_token : Session_Token,
            API.Params.Username : Username,
            API.Params.Email : Email,
            API.Params.FirstName : FirstName,
            API.Params.LastName : LastName,
            API.Params.About : About,
            API.Params.Gender : Gender,
            API.Params.facebook : facebook,
            API.Params.google : Google,
            API.Params.twitter : twitter,
            API.Params.SettingsType : API.SETTINGS_TYPE.SettingType_General,
            API.Params.ServerKey : API.SERVER_KEY.Server_Key
        ] as [String : Any]
        AF.request(API.MY_CHANNEL_Methods.UPDATE_MY_CHANNEL_API, method: .post, parameters: params, encoding:URLEncoding.default , headers: nil).responseJSON { (response) in
            if (response.value != nil) {
                guard let Res = response.value as? [String: Any] else { return }
                guard let api_status = Res["api_status"]  as? String else { return }
                if api_status == "200" {
                    let data = try? JSONSerialization.data(withJSONObject: Res, options: [])
                    let result = try? JSONDecoder().decode(MychannelModel.UpdateMyChannelModel.UpdateChannelSuccessModel.self, from: data!)
                    completionBlock(result, nil, nil)
                } else if api_status == "400" {
                    let data = try? JSONSerialization.data(withJSONObject: Res, options: [])
                    let result = try? JSONDecoder().decode(MychannelModel.UpdateMyChannelModel.UpdateChannelErrorModel.self, from: data!)
                    completionBlock(nil, result, nil)
                }
            } else {
                completionBlock(nil, nil, response.error)
            }
        }
    }
    
    func updateUserDataWithCandA(User_id: Int, Session_Token: String, Username: String, FirstName: String, LastName: String, Email: String, About: String, Gender: String, facebook: String, twitter: String, Google: String, type: String, avatar_data: Data?, cover_data: Data?, completionBlock: @escaping (_ Success: MychannelModel.UpdateMyChannelModel.UpdateChannelSuccessModel?, _ sessionError: MychannelModel.UpdateMyChannelModel.UpdateChannelErrorModel?, Error?) -> () ) {
        let params = [
            API.Params.user_id: User_id,
            API.Params.session_token: Session_Token,
            API.Params.Username: Username,
            API.Params.Email: Email,
            API.Params.FirstName: FirstName,
            API.Params.LastName: LastName,
            API.Params.About: About,
            API.Params.Gender: Gender,
            API.Params.facebook: facebook,
            API.Params.google: Google,
            API.Params.twitter: twitter,
            API.Params.SettingsType: API.SETTINGS_TYPE.SettingType_Avatar,
            API.Params.ServerKey: API.SERVER_KEY.Server_Key
        ] as [String : Any]
        let headers: HTTPHeaders = [
            "Content-type": "multipart/form-data"
        ]
        AF.upload(multipartFormData: { (multipartFormData) in
            for (key, value) in params {
                multipartFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key as String)
            }
            if type == "avatar" {
                if let data = avatar_data {
                    multipartFormData.append(data, withName: type, fileName: "avatar.jpg", mimeType: "image/png")
                }
            } else if type == "cover" {
                if let data = cover_data {
                    multipartFormData.append(data, withName: type, fileName: "cover.jpg", mimeType: "image/png")
                }
            } else {
                if let avatarData = avatar_data {
                    multipartFormData.append(avatarData, withName: "avatar", fileName: "avatar.jpg", mimeType: "image/png")
                }
                if let coverData = cover_data {
                    multipartFormData.append(coverData, withName: "cover", fileName: "cover.jpg", mimeType: "image/png")
                }
            }
        }, to: API.MY_CHANNEL_Methods.UPDATE_MY_CHANNEL_API, usingThreshold: UInt64.init(), method: .post, headers: headers).responseJSON { (response) in
            if let Res = response.value as? [String: Any] {
                guard let api_status = Res["api_status"] as? String else { return }
                if api_status == "200" {
                    let data = try? JSONSerialization.data(withJSONObject: Res, options: [])
                    let result = try? JSONDecoder().decode(MychannelModel.UpdateMyChannelModel.UpdateChannelSuccessModel.self, from: data!)
                    completionBlock(result, nil, nil)
                } else if api_status == "400" {
                    let data = try? JSONSerialization.data(withJSONObject: Res, options: [])
                    let result = try? JSONDecoder().decode(MychannelModel.UpdateMyChannelModel.UpdateChannelErrorModel.self, from: data!)
                    completionBlock(nil, result, nil)
                }
            } else {
                completionBlock(nil, nil, response.error)
            }
        }
    }
    
    func updateAvatarAndCover(session_Token: String, type: String, avatar_data: Data?, cover_data: Data?, completionBlock: @escaping (_ Success: MychannelModel.UpdateMyChannelModel.UpdateChannelSuccessModel?, _ AuthError: MychannelModel.UpdateMyChannelModel.UpdateChannelErrorModel?, Error?) -> () ) {
        let params = [
            API.Params.SettingsType: API.SETTINGS_TYPE.SettingType_Avatar,
            API.Params.ServerKey: API.SERVER_KEY.Server_Key
        ] as [String: Any]
        let headers: HTTPHeaders = [
            "Content-type": "multipart/form-data"
        ]
        AF.upload(multipartFormData: { (multipartFormData) in
            for (key, value) in params {
                multipartFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key as String)
            }
            if type == "avatar" {
                if let data = avatar_data {
                    multipartFormData.append(data, withName: type, fileName: "avatar.jpg", mimeType: "image/png")
                }
            } else if type == "cover" {
                if let data = cover_data {
                    multipartFormData.append(data, withName: type, fileName: "cover.jpg", mimeType: "image/png")
                }
            } else {
                if let avatarData = avatar_data {
                    multipartFormData.append(avatarData, withName: "avatar", fileName: "avatar.jpg", mimeType: "image/png")
                }
                if let coverData = cover_data {
                    multipartFormData.append(coverData, withName: "cover", fileName: "cover.jpg", mimeType: "image/png")
                }
            }
        }, to: API.MY_CHANNEL_Methods.UPDATE_MY_CHANNEL_API, usingThreshold: UInt64.init(), method: .post, headers: headers).responseJSON { (response) in
            if let Res = response.value as? [String: Any] {
                guard let api_status = Res["api_status"]  as? String else { return }
                if api_status == "200"{
                    let data = try? JSONSerialization.data(withJSONObject: Res, options: [])
                    let result = try? JSONDecoder().decode(MychannelModel.UpdateMyChannelModel.UpdateChannelSuccessModel.self, from: data!)
                    completionBlock(result, nil, nil)
                }else if api_status == "400" {
                    let data = try? JSONSerialization.data(withJSONObject: Res, options: [])
                    let result = try? JSONDecoder().decode(MychannelModel.UpdateMyChannelModel.UpdateChannelErrorModel.self, from: data!)
                    completionBlock(nil, result, nil)
                }
            } else {
                completionBlock(nil, nil, response.error)
            }
        }
    }
    
    func getChannelInfo(User_id: Int, Session_Token: String, Channel_id: Int, completionBlock: @escaping (_ Success: MychannelModel.GetChannelInfoModel.GetChannelInfoSuccessModel?, _ SessionError: MychannelModel.GetChannelInfoModel.GetChannelInfoErrorModel?, Error?) -> () ) {
        let params = [
            API.Params.user_id : User_id,
            API.Params.session_token : Session_Token,
            API.Params.ServerKey : API.SERVER_KEY.Server_Key
        ] as [String : Any]
        AF.request(API.MY_CHANNEL_Methods.GET_CHANNEL_INFO_API + "\(Channel_id)", method: .post, parameters: params, encoding: URLEncoding.default, headers: nil).responseJSON { (response) in
            if let Res = response.value as? [String: Any] {
                guard let api_status = Res["api_status"]  as? String else { return }
                if api_status == "200" {
                    let data = try? JSONSerialization.data(withJSONObject: Res, options: [])
                    let result = try? JSONDecoder().decode(MychannelModel.GetChannelInfoModel.GetChannelInfoSuccessModel.self, from: data!)
                    completionBlock(result, nil, nil)
                } else if api_status == "400" {
                    let data = try? JSONSerialization.data(withJSONObject: Res, options: [])
                    let result = try? JSONDecoder().decode(MychannelModel.GetChannelInfoModel.GetChannelInfoErrorModel.self, from: data!)
                    completionBlock(nil, result, nil)
                }
            } else {
                completionBlock(nil, nil, response.error)
            }
        }
        
    }
    
    func clearWatchHistory(User_id: Int, Session_Token: String, completionBlock: @escaping (_ Success: DeleteHistoryModel.DeleteHistorySuccessModel?, _ SessionError: DeleteHistoryModel.DeleteHistoryErrorModel?, Error?) -> () ) {
        let params = [
            API.Params.user_id : User_id,
            API.Params.session_token : Session_Token,
            API.Params.ServerKey : API.SERVER_KEY.Server_Key
        ] as [String : Any]
        AF.request(API.MY_CHANNEL_Methods.CLEAR_WATCH_HISTORY_API, method: .post, parameters: params, encoding: URLEncoding.default, headers: nil).responseJSON { (response) in
            if let Res = response.value as? [String: Any] {
                guard let api_status = Res["api_status"] as? String else { return }
                if api_status == "200" {
                    let data = try? JSONSerialization.data(withJSONObject: Res, options: [])
                    let result = try? JSONDecoder().decode(DeleteHistoryModel.DeleteHistorySuccessModel.self, from: data!)
                    completionBlock(result, nil, nil)
                } else if api_status == "400" {
                    let data = try? JSONSerialization.data(withJSONObject: Res, options: [])
                    let result = try? JSONDecoder().decode(DeleteHistoryModel.DeleteHistoryErrorModel.self, from: data!)
                    completionBlock(nil, result, nil)
                }
            } else {
                completionBlock(nil,nil,response.error)
            }
        }
    }
    
    func getChannelVideos(User_id: Int, Offset: Int, Limit:Int, completionBlock: @escaping (_ Success: MychannelModel.ChannelVideos.ChannelVideosSUccessModel?, _ SessionError: MychannelModel.ChannelVideos.ChannelVideosErrorModel?, Error?) -> () ) {
        let params = [
            API.Params.ServerKey : API.SERVER_KEY.Server_Key
        ] as [String : Any]
        print("PARAM :=> ",params)
        let URL = "\(API.MY_CHANNEL_Methods.CHANNEL_VIDEOS_API)\(User_id)&limit=\(Limit)&offset=\(Offset)"
        print("URL :=> \(URL)")
        AF.request(URL, method: .post, parameters: params, encoding: URLEncoding.default, headers: nil).responseJSON { (response) in
            if let Res = response.value as? [String: Any] {
                guard let api_status = Res["api_status"] as? String else { return }
                if api_status == "200" {
                    let data = try? JSONSerialization.data(withJSONObject: Res, options: [])
                    let result = try? JSONDecoder().decode(MychannelModel.ChannelVideos.ChannelVideosSUccessModel.self, from: data!)
                    completionBlock(result, nil, nil)
                } else if api_status == "400" {
                    let data = try? JSONSerialization.data(withJSONObject: Res, options: [])
                    let result = try? JSONDecoder().decode(MychannelModel.ChannelVideos.ChannelVideosErrorModel.self, from: data!)
                    completionBlock(nil, result, nil)
                }
            } else {
                completionBlock(nil, nil, response.error)
            }
        }
    }
    
}
