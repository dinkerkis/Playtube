//
//  UserActivityModal.swift
//  Playtube
//
//  Created by Ubaid Javaid on 9/17/20.
//  Copyright © 2020 Muhammad Haris Butt. All rights reserved.
//

import Foundation

class UserActivityModal {
    
    struct UserActivity_SuccessModal: Codable {
        let api_status : String?
        let api_version : String?
        let success_type : String?
        let data : [UserActivity]?
        
        enum CodingKeys: String, CodingKey {
            
            case api_status = "api_status"
            case api_version = "api_version"
            case success_type = "success_type"
            case data = "data"
        }
        
        init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            api_status = try values.decodeIfPresent(String.self, forKey: .api_status)
            api_version = try values.decodeIfPresent(String.self, forKey: .api_version)
            success_type = try values.decodeIfPresent(String.self, forKey: .success_type)
            data = try values.decodeIfPresent([UserActivity].self, forKey: .data)
        }
    }
    
    struct UserActivity_ErrorModal: Codable {
        
        let apiStatus, apiText: String?
        let errors: Errors?
        
        enum CodingKeys: String, CodingKey {
            case apiStatus = "api_status"
            case apiText = "api_text"
            case errors
        }
        
    }
    
}

struct UserActivity : Codable {
    
    let id : Int?
    let user_id : Int?
    let text : String?
    let image : String?
    let time : String?
    let is_owner : Bool?
    let time_text : String?
    var likes : Int?
    let dislikes : Int?
    var is_liked : Int?
    let is_disliked : Int?
    let link : String?
    let comments_count : Int?
    
    enum CodingKeys: String, CodingKey {
        
        case id = "id"
        case user_id = "user_id"
        case text = "text"
        case image = "image"
        case time = "time"
        case is_owner = "is_owner"
        case time_text = "time_text"
        case likes = "likes"
        case dislikes = "dislikes"
        case is_liked = "is_liked"
        case is_disliked = "is_disliked"
        case link = "link"
        case comments_count = "comments_count"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decodeIfPresent(Int.self, forKey: .id)
        user_id = try values.decodeIfPresent(Int.self, forKey: .user_id)
        text = try values.decodeIfPresent(String.self, forKey: .text)
        image = try values.decodeIfPresent(String.self, forKey: .image)
        time = try values.decodeIfPresent(String.self, forKey: .time)
        is_owner = try values.decodeIfPresent(Bool.self, forKey: .is_owner)
        time_text = try values.decodeIfPresent(String.self, forKey: .time_text)
        likes = try values.decodeIfPresent(Int.self, forKey: .likes)
        dislikes = try values.decodeIfPresent(Int.self, forKey: .dislikes)
        is_liked = try values.decodeIfPresent(Int.self, forKey: .is_liked)
        is_disliked = try values.decodeIfPresent(Int.self, forKey: .is_disliked)
        link = try values.decodeIfPresent(String.self, forKey: .link)
        comments_count = try values.decodeIfPresent(Int.self, forKey: .comments_count)
    }
    
}

