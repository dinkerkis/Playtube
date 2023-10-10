//
//  AuthorizeNetPaymentModel.swift
//  Playtube
//
//  Created by iMac on 19/06/23.
//  Copyright © 2023 ScriptSun. All rights reserved.
//

import Foundation

class AuthorizeNetPaymentModel {
    
    struct AuthorizeNetPaymentSuccessModal : Codable {
        
        let api_status : String?
        let api_version : String?
        let success_type : String?
        let message : String?
        
        enum CodingKeys: String, CodingKey {
            case api_status = "api_status"
            case api_version = "api_version"
            case success_type = "success_type"
            case message = "message"
        }
        
        init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            api_status = try values.decodeIfPresent(String.self, forKey: .api_status)
            api_version = try values.decodeIfPresent(String.self, forKey: .api_version)
            success_type = try values.decodeIfPresent(String.self, forKey: .success_type)
            message = try values.decodeIfPresent(String.self, forKey: .message)
        }
        
    }
    
    struct AuthorizeNetPaymentErrorModal : Codable {
        
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
