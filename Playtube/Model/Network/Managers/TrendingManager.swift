import Foundation
import Alamofire
import PlaytubeSDK

class TrendingManager: NSObject {
    
    static let instance = TrendingManager()
    
    func getTrendingData(User_id: Int, Session_Token: String, Offset: NSNumber, completionBlock: @escaping (_ Success: TrendingModel.TrendingSuccessModel?, _ SessionError: TrendingModel.TrendingErrorModel?, Error?) -> () ) {
        let params = [
            // API.Params.user_id : User_id,
            // API.Params.session_token : Session_Token,
            API.Params.ServerKey : API.SERVER_KEY.Server_Key
         ] as [String : Any]
        print(params)
        let URL = "\(API.Trending_Methods.TRENDING_VIDEOS_API)\(Session_Token)"
        print("URL :=> ",URL)
        AF.request(URL, method: .post, parameters: params, encoding: URLEncoding.default, headers: nil).responseJSON { (response) in
            if let Res = response.value as? [String: Any] {
                guard let api_status = Res["api_status"]  as? String else { return }
                if api_status == "200" {
                    let data = try? JSONSerialization.data(withJSONObject: Res, options: [])
                    let result = try! JSONDecoder().decode(TrendingModel.TrendingSuccessModel.self, from: data!)
                    completionBlock(result, nil, nil)
                } else if api_status == "400" {
                    let data = try? JSONSerialization.data(withJSONObject: Res, options: [])
                    let result = try? JSONDecoder().decode(TrendingModel.TrendingErrorModel.self, from: data!)
                  completionBlock(nil, result, nil)
                }
            } else {
                completionBlock(nil, nil, response.error)
            }
        }
    }
    
}
