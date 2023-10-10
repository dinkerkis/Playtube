//
//  GenerateTVCodeModel.swift
//  Playtube
//
//  Created by iMac on 25/05/23.
//  Copyright © 2023 ScriptSun. All rights reserved.
//

import Foundation

class GenerateTVCodeModel {
    
    struct GenerateTVCodeSuccessModel : Codable {
        
        let api_status : String?
        let api_version : String?
        let success_type : String?
        let code : String?

        enum CodingKeys: String, CodingKey {
            case api_status = "api_status"
            case api_version = "api_version"
            case success_type = "success_type"
            case code = "code"
        }

        init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            api_status = try values.decodeIfPresent(String.self, forKey: .api_status)
            api_version = try values.decodeIfPresent(String.self, forKey: .api_version)
            success_type = try values.decodeIfPresent(String.self, forKey: .success_type)
            code = try values.decodeIfPresent(String.self, forKey: .code)
        }

    }
    
    struct GenerateTVCodeErrorModel : Codable {
        
        let api_status : String?
        let api_text : String?
        let errors : Errors?

        enum CodingKeys: String, CodingKey {
            case api_status = "api_status"
            case api_text = "api_text"
            case errors = "errors"
        }

        init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            api_status = try values.decodeIfPresent(String.self, forKey: .api_status)
            api_text = try values.decodeIfPresent(String.self, forKey: .api_text)
            errors = try values.decodeIfPresent(Errors.self, forKey: .errors)
        }

    }
    
}
