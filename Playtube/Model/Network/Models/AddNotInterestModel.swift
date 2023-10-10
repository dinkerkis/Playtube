//
//  AddNotInterestModel.swift
//  Playtube
//
//  Created by iMac on 02/06/23.
//  Copyright © 2023 ScriptSun. All rights reserved.
//

import Foundation

class AddNotInterestVideoModel {
    struct AddNotInterestVideoSuccessModel: Codable {
        let apiStatus, apiVersion, successType, message: String?
        
        enum CodingKeys: String, CodingKey {
            case apiStatus = "api_status"
            case apiVersion = "api_version"
            case successType = "success_type"
            case message
        }
    }
    struct AddNotInterestVideoErrorModel: Codable {
        let apiStatus, apiText: String?
        let errors: Errors?
        
        enum CodingKeys: String, CodingKey {
            case apiStatus = "api_status"
            case apiText = "api_text"
            case errors
        }
    }
    
}
