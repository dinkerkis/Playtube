import Foundation
import Alamofire
import PlaytubeSDK

class HomeManager: NSObject {
    
    static let instance = HomeManager()
    
    func getHomeDataWithLimit(User_id: Int, Session_Token: String, Limit: Int, completionBlock: @escaping (_ Success: Home.HomeModel?, _ SessionError: Home.HomeModel_Error?, Error?) -> () ) {
        let params = [
            API.Params.user_id: User_id,
            API.Params.session_token: Session_Token,
            API.Params.ServerKey: API.SERVER_KEY.Server_Key
        ] as [String: Any]
        print("PARAM :=> ", params)
        print("URL :=> ", API.HOME_Constants_Methods.VIDEOS_API)
        AF.request(API.HOME_Constants_Methods.VIDEOS_API + "\(Limit)", method: .post, parameters: params, encoding: URLEncoding.default, headers: nil).responseJSON { (response) in
            if let Res = response.value as? [String: Any] {
                guard let api_status = Res["api_status"]  as? String else { return }
                if api_status == "200" {
                    let data = try? JSONSerialization.data(withJSONObject: Res, options: [])
                    let result = try! JSONDecoder().decode(Home.HomeModel.self, from: data!)
                    completionBlock(result ,nil, nil)
                } else if api_status == "400" {
                    let data = try? JSONSerialization.data(withJSONObject: Res, options: [])
                    let result = try? JSONDecoder().decode(Home.HomeModel_Error.self, from: data!)
                    completionBlock(nil, result, nil)
                }
            } else {
                completionBlock(nil, nil, response.error)
            }
        }
    }
    
    var temp: [VideoDetail] = []
    
    func getStockVidoes(User_id: String, Session_Token: String, Offset: NSNumber, Limit: NSNumber, completionBlock: @escaping (_ Success: [VideoDetail]?, _ SessionError: [String: Any]?, Error?) -> () ) {
        let params = [
            API.Params.user_id: User_id,
            API.Params.session_token: Session_Token,
            API.Params.ServerKey: API.SERVER_KEY.Server_Key,
            API.Params.Limit: Limit,
            API.Params.Offset: Offset
        ] as [String: Any]
        print("URL :=> ", API.StockVideos.STOCK_VIDEOS)
        print("PARAM :=> ",params)
        AF.request(API.StockVideos.STOCK_VIDEOS, method: .post, parameters: params, encoding: URLEncoding.default, headers: nil).responseJSON { (response) in
            print("Called")
            if let Res = response.value as? [String: Any] {
                guard let api_status = Res["api_status"] as? String else { return }
                if api_status == "200" {
                    guard let videos = Res["videos"] as? [[String: Any]] else { return }
                    for index in videos {
                        let data = try! JSONSerialization.data(withJSONObject: index, options: [])
                        let result = try! JSONDecoder().decode(VideoDetail.self, from: data)
                        self.temp.append(result)
                    }
                    completionBlock(self.temp, nil, nil)
                } else if api_status == "400" {
                    completionBlock(nil, Res, nil)
                }
            } else {
                completionBlock(nil, nil, response.error)
            }
        }
    }
    
}
