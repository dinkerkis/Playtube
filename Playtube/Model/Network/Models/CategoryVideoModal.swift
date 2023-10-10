//
//  CategoryVideoModal.swift
//  Playtube
//
//  Created by Ubaid Javaid on 6/1/20.
//  Copyright © 2020 Muhammad Haris Butt. All rights reserved.
//

import Foundation

class CategoryVideoModal {
    
    struct categoryVideo_SuccessModal: Codable {
        
        let apiStatus, apiVersion: String
        let data: [VideoDetail]?
        enum CodingKeys: String, CodingKey {
            case apiStatus = "api_status"
            case apiVersion = "api_version"
            case data
        }
    }
    
    struct categoryVideo_ErrorModal: Codable{
        let apiStatus, apiVersion: String
        let errors: Errors
        
        enum CodingKeys: String, CodingKey {
            case apiStatus = "api_status"
            case apiVersion = "api_version"
            case errors
        }
    }
    
}
