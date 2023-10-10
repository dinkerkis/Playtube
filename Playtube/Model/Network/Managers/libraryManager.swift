import Foundation
import Alamofire
import PlaytubeSDK

class LibraryManager: NSObject {
    
    static let instance = LibraryManager()
    
    func getLikedVideos(User_id: Int, Session_Token: String, completionBlock: @escaping (_ Success: LibraryModel.LibrarySuccessModel?, _ SessionError: LibraryModel.LibraryErrorModel?, Error?) -> () ) {
        let params = [
            API.Params.user_id : User_id,
            API.Params.session_token : Session_Token,
            API.Params.ServerKey : API.SERVER_KEY.Server_Key
            ] as [String : Any]
        AF.request(API.LIBRARY_VIDEOS_Methods.LIKED_VIDEOS_API, method: .post, parameters: params, encoding: URLEncoding.default, headers: nil).responseJSON { (response) in
            print(API.LIBRARY_VIDEOS_Methods.LIKED_VIDEOS_API)
            if let Res = response.value as? [String: Any] {
                guard let api_status = Res["api_status"] as? String else { return }
                if api_status == "200" {
                    let data = try? JSONSerialization.data(withJSONObject: Res, options: [])
                    let result = try? JSONDecoder().decode(LibraryModel.LibrarySuccessModel.self, from: data!)
                    completionBlock(result, nil, nil)
                } else if api_status == "400" {
                    let data = try? JSONSerialization.data(withJSONObject: Res, options: [])
                    let result = try? JSONDecoder().decode(LibraryModel.LibraryErrorModel.self, from: data!)
                    completionBlock(nil, result, nil)
                }
            } else {
                completionBlock(nil, nil, response.error)
            }
        }
    }
    
    func recentlyWatchedVideos(User_id: Int, Session_Token: String, Offset: NSNumber, Limit: NSNumber, completionBlock: @escaping (_ Success: RecentlyWatchModel.RecentlyWatchSuccessModel?, _ SessionError: RecentlyWatchModel.RecentlyWatchErrorModel?, Error?) -> () ) {
        let params = [
            API.Params.user_id: User_id,
            API.Params.session_token: Session_Token,
            API.Params.ServerKey: API.SERVER_KEY.Server_Key,
            API.Params.Limit: Limit,
            API.Params.Offset: Offset
            ] as [String : Any]
        AF.request(API.LIBRARY_VIDEOS_Methods.RECENTLY_WATCHED_API, method: .post, parameters: params, encoding: URLEncoding.default, headers: nil).responseJSON { (response) in
            if let Res = response.value as? [String: Any] {
                log.verbose("response = \(Res)")
                guard let api_status = Res["api_status"] as? String else {return}
                if api_status == "200" {
                    let data = try? JSONSerialization.data(withJSONObject: Res, options: [])
                    let result = try? JSONDecoder().decode(RecentlyWatchModel.RecentlyWatchSuccessModel.self, from: data!)
                    completionBlock(result, nil, nil)
                } else if api_status == "400" {
                    let data = try? JSONSerialization.data(withJSONObject: Res, options: [])
                    let result = try? JSONDecoder().decode(RecentlyWatchModel.RecentlyWatchErrorModel.self, from: data!)
                    completionBlock(nil, result, nil)
                }
            } else {
                completionBlock(nil, nil, response.error)
            }
        }
    }
    
    func getSubscribedChannels(user_id: Int, session_Token: String, channel: Int, limit: Int, completionBlock: @escaping (_ Success: SubscriptionModel.SubscriptionSuccessModel?, _ SessionError: SubscriptionModel.SubscriptionErrorModel?, Error?) -> () ) {
        let params = [
            API.Params.user_id: user_id,
            API.Params.session_token: session_Token,
            API.Params.ServerKey: API.SERVER_KEY.Server_Key
        ] as [String : Any]
        let url = API.LIBRARY_VIDEOS_Methods.SUBSCRIBED_CHANNEL_API + "\(channel)" + "&offset=0&limit=\(limit)"
        AF.request(url, method: .post, parameters: params, encoding: URLEncoding.default, headers: nil).responseJSON { (response) in
            print(url)
            if let Res = response.value as? [String: Any] {
                guard let api_status = Res["api_status"]  as? String else {return}
                if api_status == "200" {
                    let data = try? JSONSerialization.data(withJSONObject: Res, options: [])
                    let result = try? JSONDecoder().decode(SubscriptionModel.SubscriptionSuccessModel.self, from: data!)
                    completionBlock(result, nil, nil)
                }else if api_status == "400" {
                    let data = try? JSONSerialization.data(withJSONObject: Res, options: [])
                    let result = try? JSONDecoder().decode(SubscriptionModel.SubscriptionErrorModel.self, from: data!)
                    completionBlock(nil, result, nil)
                }
            } else {
                completionBlock(nil, nil, response.error)
            }
        }
    }
    
    func getSubscribedChannelsVideos(User_id: Int, Session_Token: String, ChannelId: Int, Limit: Int, completionBlock: @escaping (_ Success: SubscribedChannelVideosModel.SubscribedChannelVideosSuccessModel?, _ SessionError: SubscribedChannelVideosModel.SubscribedChannelVideosErrorModel?, Error?) -> () ) {
        let params = [
            API.Params.user_id : User_id,
            API.Params.session_token : Session_Token,
            API.Params.ServerKey : API.SERVER_KEY.Server_Key
            ] as [String : Any]
        AF.request(API.LIBRARY_VIDEOS_Methods.SUBSCRIBED_CHANNEL_API + "\(ChannelId)" + "&offset=0&limit=\(Limit)" , method: .post, parameters: params, encoding: URLEncoding.default, headers: nil).responseJSON { (response) in
            if let Res = response.value as? [String: Any] {
                guard let api_status = Res["api_status"] as? String else { return }
                if api_status == "200" {
                    let data = try? JSONSerialization.data(withJSONObject: Res, options: [])
                    let result = try? JSONDecoder().decode(SubscribedChannelVideosModel.SubscribedChannelVideosSuccessModel.self, from: data!)
                    completionBlock(result, nil, nil)
                } else if api_status == "400" {
                    let data = try? JSONSerialization.data(withJSONObject: Res, options: [])
                    let result = try? JSONDecoder().decode(SubscribedChannelVideosModel.SubscribedChannelVideosErrorModel.self, from: data!)
                    completionBlock(nil, result, nil)
                }
            } else {
                completionBlock(nil, nil, response.error)
            }
        }
    }
    
}
