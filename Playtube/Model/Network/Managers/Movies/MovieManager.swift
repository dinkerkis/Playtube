//
//  MovieManager.swift
//  Playtube
//
//  Created by Abdul Moid on 18/03/2021.
//  Copyright © 2021 Muhammad Haris Butt. All rights reserved.
//

import Foundation
import Alamofire
import PlaytubeSDK

class MovieManager: NSObject {
    
    static let instance = MovieManager()
    
    func getMovies(User_id: String, Session_Token: String, completionBlock: @escaping (_ Success: MovieDataModel.MovieSuccessModel?, _ SessionError: MovieDataModel.MovieErrorModel?, Error?) -> () ) {
        let params = [
            API.Params.page_id : "1",
            API.Params.user_id : User_id,
            API.Params.session_token: Session_Token,
            API.Params.ServerKey : API.SERVER_KEY.Server_Key
        ] as [String : Any]
        AF.request(API.MoviesMethod.MOVIES_API, method: .post, parameters: params, encoding: URLEncoding.default, headers: nil).responseJSON { (response) in
            if let Res = response.value as? [String: Any] {
                guard let api_status = Res["api_status"]  as? String else { return }
                if api_status == "200" {
                    let data = try? JSONSerialization.data(withJSONObject: Res, options: [])
                    let result = try! JSONDecoder().decode(MovieDataModel.MovieSuccessModel.self, from: data!)
                    completionBlock(result, nil, nil)
                } else if api_status == "400" {
                    let data = try? JSONSerialization.data(withJSONObject: Res, options: [])
                    let result = try? JSONDecoder().decode(MovieDataModel.MovieErrorModel.self, from: data!)
                  completionBlock(nil, result, nil)
                }
            } else {
                completionBlock(nil, nil, response.error)
            }
        }
    }

    func filterMovies(User_id: String, pageID: String, keyword: String, country: String, category: String, rating: String, release: String, Session_Token: String, completionBlock: @escaping (_ Success: MovieDataModel.MovieSuccessModel?, _ SessionError: MovieDataModel.MovieErrorModel?, Error?) -> () ) {
        let params = [
            API.Params.page_id : pageID,
            API.Params.keyword : keyword,
            API.Params.country: country,
            API.Params.category : category,
            API.Params.rating : rating,
            API.Params.release : release,
            API.Params.user_id : User_id,
            API.Params.session_token: Session_Token,
            API.Params.ServerKey : API.SERVER_KEY.Server_Key
        ] as [String : Any]
        AF.request(API.MoviesMethod.MOVIES_API, method: .post, parameters: params, encoding: URLEncoding.default, headers: nil).responseJSON { (response) in
            if let Res = response.value as? [String: Any] {
                guard let api_status = Res["api_status"]  as? String else { return }
                if api_status == "200" {
                    let data = try? JSONSerialization.data(withJSONObject: Res, options: [])
                    let result = try! JSONDecoder().decode(MovieDataModel.MovieSuccessModel.self, from: data!)
                    completionBlock(result, nil, nil)
                } else if api_status == "400" {
                    let data = try? JSONSerialization.data(withJSONObject: Res, options: [])
                    let result = try? JSONDecoder().decode(MovieDataModel.MovieErrorModel.self, from: data!)
                  completionBlock(nil, result, nil)
                }
            } else {
                completionBlock(nil, nil, response.error)
            }
        }
    }
    
}
