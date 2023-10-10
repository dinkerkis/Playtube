import Foundation
import Alamofire
import PlaytubeSDK

class PlaylistManager: NSObject {
    
    static let instance = PlaylistManager()
    
    func getPlaylist(User_id: Int, Session_Token: String, completionBlock: @escaping (_ Success: PlaylistModel.PlaylistSuccessModel?, _ SessionError: PlaylistModel.PlaylistErrorModel?, Error?) -> () ) {
        let params = [
            API.Params.user_id : User_id,
            API.Params.session_token : Session_Token,
            API.Params.ServerKey : API.SERVER_KEY.Server_Key
            ] as [String : Any]
        print("URL =>  ", API.PLAYLIST_Methods.PLAYLIST_API)
        print("param =>  ", params)
        AF.request(API.PLAYLIST_Methods.PLAYLIST_API, method: .post, parameters: params, encoding: URLEncoding.default, headers: nil).responseJSON { (response) in
            if let Res = response.value as? [String: Any] {
                guard let api_status = Res["api_status"] as? String else { return }
                if api_status == "200" {
                    let data = try? JSONSerialization.data(withJSONObject: Res, options: [])
                    let result = try? JSONDecoder().decode(PlaylistModel.PlaylistSuccessModel.self, from: data!)
                    completionBlock(result, nil, nil)
                } else if api_status == "400" {
                    let data = try? JSONSerialization.data(withJSONObject: Res, options: [])
                    let result = try? JSONDecoder().decode(PlaylistModel.PlaylistErrorModel.self, from: data!)
                    completionBlock(nil, result, nil)
                }
            } else {
                completionBlock(nil, nil, response.error)
            }
        }
    }
    
    func getPlaylistWithChannelId(User_id: Int, completionBlock: @escaping (_ Success: PlaylistModel.PlaylistSuccessModel?, _ SessionError: PlaylistModel.PlaylistErrorModel?, Error?) -> () ) {
        let params = [
            API.Params.ServerKey : API.SERVER_KEY.Server_Key
        ] as [String: Any]
        print("URL =>  ", API.PLAYLIST_Methods.GET_PLAYLIST_CHANNEL_API + "\(User_id)")
        print("param =>  ", params)
        AF.request(API.PLAYLIST_Methods.GET_PLAYLIST_CHANNEL_API + "\(User_id)", method: .post, parameters: params, encoding:URLEncoding.default , headers: nil).responseJSON { (response) in
            if let Res = response.value as? [String: Any] {
                guard let api_status = Res["api_status"] as? String else { return }
                if api_status == "200" {
                    let data = try? JSONSerialization.data(withJSONObject: Res, options: [])
                    let result = try? JSONDecoder().decode(PlaylistModel.PlaylistSuccessModel.self, from: data!)
                    completionBlock(result, nil, nil)
                } else if api_status == "400" {
                    let data = try? JSONSerialization.data(withJSONObject: Res, options: [])
                    let result = try? JSONDecoder().decode(PlaylistModel.PlaylistErrorModel.self, from: data!)
                    completionBlock(nil, result, nil)
                }
            } else {
                completionBlock(nil, nil, response.error)
            }
        }
    }
    
    func getPlaylistVideos(User_id: Int, Session_Token: String, List_Id: String, Limit: Int, completionBlock: @escaping (_ Success: PlaylistVideosModel.PlaylistVideosSuccessModel?, _ SessionError: PlaylistVideosModel.PlaylistVideosErrorModel?, Error?) -> () ) {
        let params = [
            API.Params.user_id: User_id,
            API.Params.session_token: Session_Token,
            API.Params.ServerKey: API.SERVER_KEY.Server_Key
            ] as [String : Any]
        print("URL :=> ", API.PLAYLIST_Methods.PLAYLIST_VIDEOS_API + List_Id + "&limit=\(Limit)")
        print("PARAM :=> ",params)
        AF.request(API.PLAYLIST_Methods.PLAYLIST_VIDEOS_API + List_Id + "&limit=\(Limit)", method: .post, parameters: params, encoding: URLEncoding.default, headers: nil).responseJSON { (response) in
            print(API.PLAYLIST_Methods.PLAYLIST_VIDEOS_API + List_Id + "&limit=\(Limit)")
            if let Res = response.value as? [String: Any] {
                guard let api_status = Res["api_status"]  as? String else {return}
                if api_status == "200" {
                    let data = try? JSONSerialization.data(withJSONObject: Res, options: [])
                    let result = try? JSONDecoder().decode(PlaylistVideosModel.PlaylistVideosSuccessModel.self, from: data!)
                    completionBlock(result, nil, nil)
                } else if api_status == "400" {
                    let data = try? JSONSerialization.data(withJSONObject: Res, options: [])
                    let result = try? JSONDecoder().decode(PlaylistVideosModel.PlaylistVideosErrorModel.self, from: data!)
                    completionBlock(nil, result, nil)
                }
            } else {
                completionBlock(nil, nil, response.error)
            }
        }
    }
    
    func addPlaylist(User_id: Int, Session_Token: String, Name: String, Description: String, Privacy: Int, completionBlock: @escaping (_ Success: CreatePlaylistModel.CreatePlaylistSuccessModel?, _ SessionError: CreatePlaylistModel.CreatePlaylistErrorModel?, Error?) -> () ) {
        let params = [
            API.Params.user_id: User_id,
            API.Params.session_token: Session_Token,
            API.Params.Name: Name,
            API.Params.Description: Description,
            API.Params.Privacy: Privacy,
            API.Params.ServerKey: API.SERVER_KEY.Server_Key
            ] as [String: Any]
        AF.request(API.PLAYLIST_Methods.CREATE_PLAYLIST_API, method: .post, parameters: params, encoding: URLEncoding.default, headers: nil).responseJSON { (response) in
            if let Res = response.value as? [String: Any] {
                guard let api_status = Res["api_status"]  as? String else { return }
                if api_status == "200" {
                    let data = try? JSONSerialization.data(withJSONObject: Res, options: [])
                    let result = try? JSONDecoder().decode(CreatePlaylistModel.CreatePlaylistSuccessModel.self, from: data!)
                    completionBlock(result, nil, nil)
                } else if api_status == "400" {
                    let data = try? JSONSerialization.data(withJSONObject: Res, options: [])
                    let result = try? JSONDecoder().decode(CreatePlaylistModel.CreatePlaylistErrorModel.self, from: data!)
                    completionBlock(nil,result,nil)
                }
            } else {
                completionBlock(nil, nil, response.error)
            }
        }
    }
    
    func updatePlaylist(User_id: Int, Session_Token: String, List_id: String, Name: String, Description: String, Privacy: Int, completionBlock: @escaping (_ Success: UpdatePlaylistModel.UpdatePlaylistSuccessModel?, _ SessionError: UpdatePlaylistModel.UpdatePlaylistErrorModel?, Error?) -> () ) {
        let params = [
            API.Params.user_id : User_id,
            API.Params.session_token : Session_Token,
            API.Params.Name : Name,
            API.Params.Description : Description,
            API.Params.Privacy : Privacy,
            API.Params.List_id : List_id,
            API.Params.ServerKey : API.SERVER_KEY.Server_Key
            ] as [String : Any]
        AF.request(API.PLAYLIST_Methods.UPDATE_PLAYLIST_API, method: .post, parameters: params, encoding:URLEncoding.default , headers: nil).responseJSON { (response) in
            if let Res = response.value as? [String: Any] {
                guard let api_status = Res["api_status"]  as? String else {return}
                if api_status == "200" {
                    let data = try? JSONSerialization.data(withJSONObject: Res, options: [])
                    let result = try? JSONDecoder().decode(UpdatePlaylistModel.UpdatePlaylistSuccessModel.self, from: data!)
                    completionBlock(result, nil, nil)
                } else if api_status == "400" {
                    let data = try? JSONSerialization.data(withJSONObject: Res, options: [])
                    let result = try? JSONDecoder().decode(UpdatePlaylistModel.UpdatePlaylistErrorModel.self, from: data!)
                    completionBlock(nil, result, nil)
                }
            } else {
                completionBlock(nil, nil, response.error)
            }
        }
    }
    

    func deletePlaylist(User_id: Int, Session_Token: String, List_id: String, completionBlock: @escaping (_ Success: DeletePlaylistModel.DeletePlaylistSuccessModel?, _ SessionError: DeletePlaylistModel.DeletePlaylistErrorModel?, Error?) -> () ) {
        let params = [
            API.Params.user_id : User_id,
            API.Params.session_token : Session_Token,
            API.Params.List_id : List_id,
            API.Params.ServerKey : API.SERVER_KEY.Server_Key
            ] as [String : Any]
        AF.request(API.PLAYLIST_Methods.DELETE_PLAYLIST_API, method: .post, parameters: params, encoding: URLEncoding.default, headers: nil).responseJSON { (response) in
            if let Res = response.value as? [String: Any] {
                guard let api_status = Res["api_status"]  as? String else {return}
                if api_status == "200" {
                    let data = try? JSONSerialization.data(withJSONObject: Res, options: [])
                    let result = try? JSONDecoder().decode(DeletePlaylistModel.DeletePlaylistSuccessModel.self, from: data!)
                    completionBlock(result, nil, nil)
                } else if api_status == "400" {
                    let data = try? JSONSerialization.data(withJSONObject: Res, options: [])
                    let result = try? JSONDecoder().decode(DeletePlaylistModel.DeletePlaylistErrorModel.self, from: data!)
                    completionBlock(nil, result, nil)
                }
            } else {
                completionBlock(nil, nil, response.error)
            }
        }
    }
    

    func addToPlaylist(User_id: Int, Session_Token: String, List_id: String, Video_Id: Int, completionBlock: @escaping (_ Success: AddToListModel.AddToListSuccessModel?, _ SessionError: AddToListModel.AddToListErrorModel?, Error?) -> () ) {
        let params = [
            API.Params.user_id : User_id,
            API.Params.session_token : Session_Token,
            API.Params.List_uid : List_id,
            API.Params.Video_id : Video_Id,
            API.Params.ServerKey : API.SERVER_KEY.Server_Key
            ] as [String : Any]
        AF.request(API.PLAYLIST_Methods.ADD_TO_PLAYLIST_API, method: .post, parameters: params, encoding: URLEncoding.default, headers: nil).responseJSON { (response) in
            if let Res = response.value as? [String: Any] {
                log.verbose("response = \(Res)")
                guard let api_status = Res["status"]  as? Int else { return }
                guard let api_status_error = Res["status"]  as? Double else { return }
                log.verbose("Apo_Status \(api_status_error)")
                if api_status == 200 {
                    let data = try? JSONSerialization.data(withJSONObject: Res, options: [])
                    let result = try? JSONDecoder().decode(AddToListModel.AddToListSuccessModel.self, from: data!)
                    completionBlock(result, nil, nil)
                } else if api_status == 302 {
                    let data = try? JSONSerialization.data(withJSONObject: Res, options: [])
                    let result = try? JSONDecoder().decode(AddToListModel.AddToListSuccessModel.self, from: data!)
                    completionBlock(result, nil, nil)
                } else if api_status_error == 400 {
                    let data = try? JSONSerialization.data(withJSONObject: Res, options: [])
                    let result = try? JSONDecoder().decode(AddToListModel.AddToListErrorModel.self, from: data!)
                    completionBlock(nil, result, nil)
                }
            } else {
                completionBlock(nil, nil, response.error)
            }
        }
    }
    
}
