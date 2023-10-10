import Foundation

class Home {
    
    struct HomeModel: Codable {
        
        let api_status : String?
        let api_version : String?
        let data : DataClass?

        enum CodingKeys: String, CodingKey {
            case api_status = "api_status"
            case api_version = "api_version"
            case data = "data"
        }

        init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            api_status = try values.decodeIfPresent(String.self, forKey: .api_status)
            api_version = try values.decodeIfPresent(String.self, forKey: .api_version)
            data = try values.decodeIfPresent(DataClass.self, forKey: .data)
        }
        
    }
    
    struct HomeModel_Error: Codable {
        
        let apiStatus, apiText: String?
        let errors: Errors?
        
        enum CodingKeys: String, CodingKey {
            case apiStatus = "api_status"
            case apiText = "api_text"
            case errors
        }
        
    }

    // MARK: DataClass
    struct DataClass: Codable {
        
        let featured : [VideoDetail]?
        let top : [VideoDetail]?
        let latest : [VideoDetail]?
        let fav : [VideoDetail]?
        let live : [VideoDetail]?

        enum CodingKeys: String, CodingKey {

            case featured = "featured"
            case top = "top"
            case latest = "latest"
            case fav = "fav"
            case live = "live"
        }

        init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            featured = try values.decodeIfPresent([VideoDetail].self, forKey: .featured)
            top = try values.decodeIfPresent([VideoDetail].self, forKey: .top)
            latest = try values.decodeIfPresent([VideoDetail].self, forKey: .latest)
            fav = try values.decodeIfPresent([VideoDetail].self, forKey: .fav)
            live = try values.decodeIfPresent([VideoDetail].self, forKey: .live)
        }
        
    }
    
    enum GeoBlocking: String, Codable {
        case asiaIndian = "[\"Asia\",\"Indian\"]"
        case empty = ""
        case geoBlocking = "[]"
        case indian = "[\"Indian\"]"
    }

    enum Producer: String, Codable {
        case empty = ""
        case sylvesterStallone9 = "Sylvester Stallone9"
    }

    enum Quality: String, Codable {
        case empty = ""
        case hdDVD = "HD DVD"
        case HDTV = "HD-TV"
    }

    enum Rating: String, Codable {
        case empty = ""
        case the89 = "8.9"
        case the10 = "10"
    }

    enum Source: String, Codable {
        case uploaded = "Uploaded"
        case youTube = "YouTube"
    }

    enum Stars: String, Codable {
        case empty = ""
        case sylvesterStallone = "sylvester Stallone"
    }

    enum VideoType: String, Codable {
        case videoMp4 = "video/mp4"
        case videoYoutube = "video/youtube"
    }

    enum SellVideo: Codable {
        
        case double(Double)
        case integer(Int)

        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            if let x = try? container.decode(Int.self) {
                self = .integer(x)
                return
            }
            if let x = try? container.decode(Double.self) {
                self = .double(x)
                return
            }
            throw DecodingError.typeMismatch(SellVideo.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for SellVideo"))
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            switch self {
            case .double(let x):
                try container.encode(x)
            case .integer(let x):
                try container.encode(x)
            }
        }
        
    }
    
}
