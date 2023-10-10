//
//  CodeVerifyModal.swift
//  Playtube
//
//  Created by Ubaid Javaid on 9/5/20.
//  Copyright © 2020 Muhammad Haris Butt. All rights reserved.
//

import Foundation

class CodeVerifyModal{
    
    struct codeVerify_SuccessModal: Codable{
        let apiStatus, apiVersion: String
        let data: DataClass

        enum CodingKeys: String, CodingKey {
            case apiStatus = "api_status"
            case apiVersion = "api_version"
            case data
        }
    }
    
    // MARK: - DataClass
    struct DataClass: Codable {
        let sessionID, message: String
        let userID: Int
        let cookie: String

        enum CodingKeys: String, CodingKey {
            case sessionID = "session_id"
            case message
            case userID = "user_id"
            case cookie
        }
    }
    
    struct codeVerify_ErrorModal: Codable {
        let apiStatus, apiText: String?
        let errors: Errors?
        
        enum CodingKeys: String, CodingKey {
            case apiStatus = "api_status"
            case apiText = "api_text"
            case errors
        }
    }
    
}
