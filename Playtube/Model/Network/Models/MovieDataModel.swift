//
//  MovieDataModel.swift
//  Playtube
//
//  Created by iMac on 29/05/23.
//  Copyright © 2023 ScriptSun. All rights reserved.
//

import Foundation

struct MovieDataModel : Codable {      
    struct MovieSuccessModel: Codable {
        let api_status : String?
        let api_version : String?
        let totalPages : ViewsCount?
        let channels : [VideoDetail]?

        enum CodingKeys: String, CodingKey {

            case api_status = "api_status"
            case api_version = "api_version"
            case totalPages = "totalPages"
            case channels = "channels"
        }

        init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            api_status = try values.decodeIfPresent(String.self, forKey: .api_status)
            api_version = try values.decodeIfPresent(String.self, forKey: .api_version)
            totalPages = try values.decodeIfPresent(ViewsCount.self, forKey: .totalPages)
            channels = try values.decodeIfPresent([VideoDetail].self, forKey: .channels)
        }
    }
    
    struct MovieErrorModel: Codable {
        
        let api_status: String?
        let api_text: String?
        let errors: Errors?
        
        enum CodingKeys: String, CodingKey {
            case api_status = "api_status"
            case api_text = "api_text"
            case errors = "errors"
        }
        
    }
    
}
