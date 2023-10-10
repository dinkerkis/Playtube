import Foundation

class PlaylistModel {

    struct PlaylistSuccessModel: Codable {
        
        let apiStatus, apiVersion: String?
        let myAllPlaylists: [MyAllPlaylist]?
        
        enum CodingKeys: String, CodingKey {
            case apiStatus = "api_status"
            case apiVersion = "api_version"
            case myAllPlaylists = "my_all_playlists"
        }
        
    }
    
    struct MyAllPlaylist: Codable {
        
        let id: Int?
        let listID: String?
        let userID: Int?
        let name, description: String?
        let privacy, views: Int?
        let icon: String?
        let time: Int?
        let thumbnail: String?
        let count: Int?
        
        enum CodingKeys: String, CodingKey {
            case id
            case listID = "list_id"
            case userID = "user_id"
            case name, description, privacy, views, icon, time, thumbnail, count
        }
        
    }
    
    struct PlaylistErrorModel: Codable {
        
        let apiStatus, apiVersion: String?
        let errors: Errors?
        
        enum CodingKeys: String, CodingKey {
            case apiStatus = "api_status"
            case apiVersion = "api_version"
            case errors
        }
        
    }

}

class PlaylistVideosModel {
    
    struct PlaylistVideosErrorModel: Codable {
        
        let apiStatus, apiVersion: String?
        let errors: Errors?
        
        enum CodingKeys: String, CodingKey {
            case apiStatus = "api_status"
            case apiVersion = "api_version"
            case errors
        }
        
    }
    
    struct PlaylistVideosSuccessModel: Codable {
        
        let apiStatus, apiVersion: String
        let data: [Datum]?
        
        enum CodingKeys: String, CodingKey {
            case apiStatus = "api_status"
            case apiVersion = "api_version"
            case data
        }
        
    }
    
    // MARK: - Datum
    struct Datum: Codable {
        
        let id: Int
        let listID, videoID: String
        let userID: Int
        let video: VideoDetail?

        enum CodingKeys: String, CodingKey {
            case id
            case listID = "list_id"
            case videoID = "video_id"
            case userID = "user_id"
            case video
        }
        
    }

}

class CreatePlaylistModel {
    
    struct CreatePlaylistSuccessModel: Codable {
        
        let apiStatus, apiVersion: String?
        let playlistID: Int?
        let playlistUid: String?
        
        enum CodingKeys: String, CodingKey {
            case apiStatus = "api_status"
            case apiVersion = "api_version"
            case playlistID = "playlist_id"
            case playlistUid = "playlist_uid"
        }
        
    }
    
    struct CreatePlaylistErrorModel: Codable {
        
        let apiStatus, apiText: String?
        let errors: Errors?
        
        enum CodingKeys: String, CodingKey {
            case apiStatus = "api_status"
            case apiText = "api_text"
            case errors
        }
        
    }

}


class UpdatePlaylistModel {
    
   struct UpdatePlaylistSuccessModel: Codable {
       
        let apiStatus, apiVersion, successType, message: String?
        
        enum CodingKeys: String, CodingKey {
            case apiStatus = "api_status"
            case apiVersion = "api_version"
            case successType = "success_type"
            case message
        }
       
    }

    struct UpdatePlaylistErrorModel: Codable {
        
        let apiStatus, apiText: String?
        let errors: Errors?
        
        enum CodingKeys: String, CodingKey {
            case apiStatus = "api_status"
            case apiText = "api_text"
            case errors
        }
        
    }
    
}

class DeletePlaylistModel {
    
    struct DeletePlaylistSuccessModel: Codable {
        
        let apiStatus, apiVersion, successType, message: String?
        
        enum CodingKeys: String, CodingKey {
            case apiStatus = "api_status"
            case apiVersion = "api_version"
            case successType = "success_type"
            case message
        }
        
    }
    
    struct DeletePlaylistErrorModel: Codable {
        
        let apiStatus, apiText: String?
        let errors: Errors?
        
        enum CodingKeys: String, CodingKey {
            case apiStatus = "api_status"
            case apiText = "api_text"
            case errors
        }
        
    }
    
}

class AddToListModel {
    
    struct AddToListSuccessModel: Codable {
        
        let status: Int?
        let message: String?
        
    }
    
    struct AddToListErrorModel: Codable {
        
        let apiStatus, apiVersion: String?
        let errors: Errors?
        
        enum CodingKeys: String, CodingKey {
            case apiStatus = "api_status"
            case apiVersion = "api_version"
            case errors
        }
        
    }
    
}
