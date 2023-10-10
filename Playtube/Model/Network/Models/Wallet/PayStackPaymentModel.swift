//
//  PayStackPaymentModel.swift
//  Playtube
//
//  Created by iMac on 17/06/23.
//  Copyright © 2023 ScriptSun. All rights reserved.
//

import Foundation

class PayStackPaymentModel {
    
    struct PayStackPaymentSuccessModal : Codable {
        
        let api_status : String?
        let api_version : String?
        let url : String?
        
        enum CodingKeys: String, CodingKey {
            case api_status = "api_status"
            case api_version = "api_version"
            case url = "url"
        }
        
        init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            api_status = try values.decodeIfPresent(String.self, forKey: .api_status)
            api_version = try values.decodeIfPresent(String.self, forKey: .api_version)
            url = try values.decodeIfPresent(String.self, forKey: .url)
        }
        
    }
    
    struct PayStackPaymentErrorModal : Codable {
        
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
