//
//  PaidVideosModal.swift
//  Playtube
//
//  Created by Ubaid Javaid on 9/17/20.
//  Copyright © 2020 Muhammad Haris Butt. All rights reserved.
//

import Foundation

class PaidVideosModal {
    
    struct PaidVideos_SuccessModal: Codable {
        let api_status : String?
        let api_version : String?
        let videos : [VideoDetail]?
        
        enum CodingKeys: String, CodingKey {
            
            case api_status = "api_status"
            case api_version = "api_version"
            case videos = "videos"
        }
        
        init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            api_status = try values.decodeIfPresent(String.self, forKey: .api_status)
            api_version = try values.decodeIfPresent(String.self, forKey: .api_version)
            videos = try values.decodeIfPresent([VideoDetail].self, forKey: .videos)
        }
        
    }
    
    struct PaidVideos_ErrorModal: Codable {
        
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
