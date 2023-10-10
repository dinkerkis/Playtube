//
//  PopularChannelModal.swift
//  Playtube
//
//  Created by Ubaid Javaid on 9/5/20.
//  Copyright © 2020 Muhammad Haris Butt. All rights reserved.
//

import Foundation

class popularChannelModal {
    
    struct getPopularChannel_SuccessModal: Codable {
        
        let api_status : String?
        let api_version : String?
        let channels : [Channels]?
        
        enum CodingKeys: String, CodingKey {
            
            case api_status = "api_status"
            case api_version = "api_version"
            case channels = "channels"
        }
        
        init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            api_status = try values.decodeIfPresent(String.self, forKey: .api_status)
            api_version = try values.decodeIfPresent(String.self, forKey: .api_version)
            channels = try values.decodeIfPresent([Channels].self, forKey: .channels)
        }
        
    }
    
    struct getPopularChannel_ErrorModal: Codable {
        
        let api_status : String?
        let api_version : String?
        let errors : Errors?
        
        enum CodingKeys: String, CodingKey {
            
            case api_status = "api_status"
            case api_version = "api_version"
            case errors = "errors"
        }
        
        init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            api_status = try values.decodeIfPresent(String.self, forKey: .api_status)
            api_version = try values.decodeIfPresent(String.self, forKey: .api_version)
            errors = try values.decodeIfPresent(Errors.self, forKey: .errors)
        }
        
    }
    
}
