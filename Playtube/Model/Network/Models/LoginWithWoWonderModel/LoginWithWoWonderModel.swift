//
//  LoginWithWoWonderModel.swift
//  Playtube
//
//  Created by Muhammad Haris Butt on 3/30/21.
//  Copyright © 2021 Muhammad Haris Butt. All rights reserved.
//

import Foundation

class LoginWithWoWonderModel {
    
    struct LoginWithWoWonderSuccessModel : Codable {
        
        let apiStatus : Int
        let timezone : String? = nil
        let accessToken : String?
        let userID : String?
        let message : String?
        
        enum CodingKeys: String, CodingKey {
            case apiStatus = "api_status"
            case timezone
            case message
            case accessToken = "access_token"
            case userID = "user_id"
        }
    }
    
}
