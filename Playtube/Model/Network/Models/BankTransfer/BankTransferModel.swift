//
//  BankTransferModel.swift
//  Playtube
//
//  Created by Muhammad Haris Butt on 3/25/21.
//  Copyright © 2021 Muhammad Haris Butt. All rights reserved.
//

import Foundation

class BankTransferModel {
    
    struct BankTransferSuccessModel: Codable {
        var apiStatus, apiVersion, message: String?
        
        enum CodingKeys: String, CodingKey {
            case apiStatus = "api_status"
            case apiVersion = "api_version"
            case message
        }
    }
    
    struct BankTransferErrorModel: Codable{
        let apiStatus, apiText: String?
        let errors: Errors?
        
        enum CodingKeys: String, CodingKey {
            case apiStatus = "api_status"
            case apiText = "api_text"
            case errors
        }
    }
    
}
