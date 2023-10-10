import Foundation

struct VideoDetail : Codable {
    
    let id : Int?
    let video_id : String?
    let user_id : Int?
    let short_id : String?
    let title : String?
    let description : String?
    let thumbnail : String?
    var video_location : String?
    let youtube : String?
    let vimeo : String?
    let daily : String?
    let facebook : String?
    let instagram : String?
    let ok : String?
    let twitch : String?
    let twitch_type : String?
    let embed : Int?
    let time : Int?
    let time_date : String?
    let active : Int?
    let tags : String?
    let duration : String?
    let size : Int?
    let converted : Int?
    let category_id : CategoryID?
    let views : Int?
    let featured : Int?
    let registered : String?
    let privacy : Int?
    let age_restriction : Int?
    let type : String?
    let approved : Int?
    let the240p : Int?
    let the360p : Int?
    let the480p : Int?
    let the720p : Int?
    let the1080p : Int?
    let the2048p : Int?
    let the4096p : Int?
    let sell_video : Sell_Video?
    let sub_category : String?
    let geo_blocking : String?
    let demo : String?
    let gif : String?
    let is_movie : Int?
    let stars : String?
    let producer : String?
    let country : String?
    let movie_release : String?
    let quality : String?
    let rating : String?
    let monetization : Int?
    let rent_price : Int?
    let stream_name : String?
    let live_time : Int?
    let live_ended : Int?
    let agora_resource_id : String?
    let agora_sid : String?
    let agora_token : String?
    let license : String?
    let is_stock : Int?
    let trailer : String?
    let embedding : Int?
    let live_chating : String?
    let publication_date : Int?
    let is_short : Int?
    let org_thumbnail : String?
    let video_id_ : String?
    let source : String?
    let video_type : String?
    let url : String?
    let ajax_url : String?
    let edit_description : String?
    let markup_description : String?
    let markup_title : String?
    let owner : Owner?
    let is_liked : Int?
    let is_disliked : Int?
    let is_owner : Bool?
    let is_purchased : Int?
    let paused_time : Int?
    let time_alpha : String?
    let time_ago : String?
    let comments_count : Int?
    let category_name : String?
    let likes : Int?
    let dislikes : Int?
    let likes_percent : Int?
    let dislikes_percent : Int?
    let is_subscribed : Int?
    let suggested_videos: [VideoDetail]?
    let video_ad : VideoAdUnion?
    let history_id: Int?
    let featured_movie : Int?
    
    enum CodingKeys: String, CodingKey {
        
        case id = "id"
        case video_id = "video_id"
        case user_id = "user_id"
        case short_id = "short_id"
        case title = "title"
        case description = "description"
        case thumbnail = "thumbnail"
        case video_location = "video_location"
        case youtube = "youtube"
        case vimeo = "vimeo"
        case daily = "daily"
        case facebook = "facebook"
        case instagram = "instagram"
        case ok = "ok"
        case twitch = "twitch"
        case twitch_type = "twitch_type"
        case embed = "embed"
        case time = "time"
        case time_date = "time_date"
        case active = "active"
        case tags = "tags"
        case duration = "duration"
        case size = "size"
        case converted = "converted"
        case category_id = "category_id"
        case views = "views"
        case featured = "featured"
        case registered = "registered"
        case privacy = "privacy"
        case age_restriction = "age_restriction"
        case type = "type"
        case approved = "approved"
        case the240p = "240p"
        case the360p = "360p"
        case the480p = "480p"
        case the720p = "720p"
        case the1080p = "1080p"
        case the2048p = "2048p"
        case the4096p = "4096p"
        case sell_video = "sell_video"
        case sub_category = "sub_category"
        case geo_blocking = "geo_blocking"
        case demo = "demo"
        case gif = "gif"
        case is_movie = "is_movie"
        case stars = "stars"
        case producer = "producer"
        case country = "country"
        case movie_release = "movie_release"
        case quality = "quality"
        case rating = "rating"
        case monetization = "monetization"
        case rent_price = "rent_price"
        case stream_name = "stream_name"
        case live_time = "live_time"
        case live_ended = "live_ended"
        case agora_resource_id = "agora_resource_id"
        case agora_sid = "agora_sid"
        case agora_token = "agora_token"
        case license = "license"
        case is_stock = "is_stock"
        case trailer = "trailer"
        case embedding = "embedding"
        case live_chating = "live_chating"
        case publication_date = "publication_date"
        case is_short = "is_short"
        case org_thumbnail = "org_thumbnail"
        case video_id_ = "video_id_"
        case source = "source"
        case video_type = "video_type"
        case url = "url"
        case ajax_url = "ajax_url"
        case edit_description = "edit_description"
        case markup_description = "markup_description"
        case markup_title = "markup_title"
        case owner = "owner"
        case is_liked = "is_liked"
        case is_disliked = "is_disliked"
        case is_owner = "is_owner"
        case is_purchased = "is_purchased"
        case paused_time = "paused_time"
        case time_alpha = "time_alpha"
        case time_ago = "time_ago"
        case comments_count = "comments_count"
        case category_name = "category_name"
        case likes = "likes"
        case dislikes = "dislikes"
        case likes_percent = "likes_percent"
        case dislikes_percent = "dislikes_percent"
        case is_subscribed = "is_subscribed"
        case suggested_videos = "suggested_videos"
        case video_ad = "video_ad"
        case history_id = "history_id"
        case featured_movie = "featured_movie"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decodeIfPresent(Int.self, forKey: .id)
        video_id = try values.decodeIfPresent(String.self, forKey: .video_id)
        user_id = try values.decodeIfPresent(Int.self, forKey: .user_id)
        short_id = try values.decodeIfPresent(String.self, forKey: .short_id)
        title = try values.decodeIfPresent(String.self, forKey: .title)
        description = try values.decodeIfPresent(String.self, forKey: .description)
        thumbnail = try values.decodeIfPresent(String.self, forKey: .thumbnail)
        video_location = try values.decodeIfPresent(String.self, forKey: .video_location)
        youtube = try values.decodeIfPresent(String.self, forKey: .youtube)
        vimeo = try values.decodeIfPresent(String.self, forKey: .vimeo)
        daily = try values.decodeIfPresent(String.self, forKey: .daily)
        facebook = try values.decodeIfPresent(String.self, forKey: .facebook)
        instagram = try values.decodeIfPresent(String.self, forKey: .instagram)
        ok = try values.decodeIfPresent(String.self, forKey: .ok)
        twitch = try values.decodeIfPresent(String.self, forKey: .twitch)
        twitch_type = try values.decodeIfPresent(String.self, forKey: .twitch_type)
        embed = try values.decodeIfPresent(Int.self, forKey: .embed)
        time = try values.decodeIfPresent(Int.self, forKey: .time)
        time_date = try values.decodeIfPresent(String.self, forKey: .time_date)
        active = try values.decodeIfPresent(Int.self, forKey: .active)
        tags = try values.decodeIfPresent(String.self, forKey: .tags)
        duration = try values.decodeIfPresent(String.self, forKey: .duration)
        size = try values.decodeIfPresent(Int.self, forKey: .size)
        converted = try values.decodeIfPresent(Int.self, forKey: .converted)
        category_id = try values.decodeIfPresent(CategoryID.self, forKey: .category_id)
        views = try values.decodeIfPresent(Int.self, forKey: .views)
        featured = try values.decodeIfPresent(Int.self, forKey: .featured)
        registered = try values.decodeIfPresent(String.self, forKey: .registered)
        privacy = try values.decodeIfPresent(Int.self, forKey: .privacy)
        age_restriction = try values.decodeIfPresent(Int.self, forKey: .age_restriction)
        type = try values.decodeIfPresent(String.self, forKey: .type)
        approved = try values.decodeIfPresent(Int.self, forKey: .approved)
        the240p = try values.decodeIfPresent(Int.self, forKey: .the240p)
        the360p = try values.decodeIfPresent(Int.self, forKey: .the360p)
        the480p = try values.decodeIfPresent(Int.self, forKey: .the480p)
        the720p = try values.decodeIfPresent(Int.self, forKey: .the720p)
        the1080p = try values.decodeIfPresent(Int.self, forKey: .the1080p)
        the2048p = try values.decodeIfPresent(Int.self, forKey: .the2048p)
        the4096p = try values.decodeIfPresent(Int.self, forKey: .the4096p)
        sell_video = try values.decodeIfPresent(Sell_Video.self, forKey: .sell_video)
        sub_category = try values.decodeIfPresent(String.self, forKey: .sub_category)
        geo_blocking = try values.decodeIfPresent(String.self, forKey: .geo_blocking)
        demo = try values.decodeIfPresent(String.self, forKey: .demo)
        gif = try values.decodeIfPresent(String.self, forKey: .gif)
        is_movie = try values.decodeIfPresent(Int.self, forKey: .is_movie)
        stars = try values.decodeIfPresent(String.self, forKey: .stars)
        producer = try values.decodeIfPresent(String.self, forKey: .producer)
        country = try values.decodeIfPresent(String.self, forKey: .country)
        movie_release = try values.decodeIfPresent(String.self, forKey: .movie_release)
        quality = try values.decodeIfPresent(String.self, forKey: .quality)
        rating = try values.decodeIfPresent(String.self, forKey: .rating)
        monetization = try values.decodeIfPresent(Int.self, forKey: .monetization)
        rent_price = try values.decodeIfPresent(Int.self, forKey: .rent_price)
        stream_name = try values.decodeIfPresent(String.self, forKey: .stream_name)
        live_time = try values.decodeIfPresent(Int.self, forKey: .live_time)
        live_ended = try values.decodeIfPresent(Int.self, forKey: .live_ended)
        agora_resource_id = try values.decodeIfPresent(String.self, forKey: .agora_resource_id)
        agora_sid = try values.decodeIfPresent(String.self, forKey: .agora_sid)
        agora_token = try values.decodeIfPresent(String.self, forKey: .agora_token)
        license = try values.decodeIfPresent(String.self, forKey: .license)
        is_stock = try values.decodeIfPresent(Int.self, forKey: .is_stock)
        trailer = try values.decodeIfPresent(String.self, forKey: .trailer)
        embedding = try values.decodeIfPresent(Int.self, forKey: .embedding)
        live_chating = try values.decodeIfPresent(String.self, forKey: .live_chating)
        publication_date = try values.decodeIfPresent(Int.self, forKey: .publication_date)
        is_short = try values.decodeIfPresent(Int.self, forKey: .is_short)
        org_thumbnail = try values.decodeIfPresent(String.self, forKey: .org_thumbnail)
        video_id_ = try values.decodeIfPresent(String.self, forKey: .video_id_)
        source = try values.decodeIfPresent(String.self, forKey: .source)
        video_type = try values.decodeIfPresent(String.self, forKey: .video_type)
        url = try values.decodeIfPresent(String.self, forKey: .url)
        ajax_url = try values.decodeIfPresent(String.self, forKey: .ajax_url)
        edit_description = try values.decodeIfPresent(String.self, forKey: .edit_description)
        markup_description = try values.decodeIfPresent(String.self, forKey: .markup_description)
        markup_title = try values.decodeIfPresent(String.self, forKey: .markup_title)
        owner = try values.decodeIfPresent(Owner.self, forKey: .owner)
        is_liked = try values.decodeIfPresent(Int.self, forKey: .is_liked)
        is_disliked = try values.decodeIfPresent(Int.self, forKey: .is_disliked)
        is_owner = try values.decodeIfPresent(Bool.self, forKey: .is_owner)
        is_purchased = try values.decodeIfPresent(Int.self, forKey: .is_purchased)
        paused_time = try values.decodeIfPresent(Int.self, forKey: .paused_time)
        time_alpha = try values.decodeIfPresent(String.self, forKey: .time_alpha)
        time_ago = try values.decodeIfPresent(String.self, forKey: .time_ago)
        comments_count = try values.decodeIfPresent(Int.self, forKey: .comments_count)
        category_name = try values.decodeIfPresent(String.self, forKey: .category_name)        
        likes = try values.decodeIfPresent(Int.self, forKey: .likes)
        dislikes = try values.decodeIfPresent(Int.self, forKey: .dislikes)
        likes_percent = try values.decodeIfPresent(Int.self, forKey: .likes_percent)
        dislikes_percent = try values.decodeIfPresent(Int.self, forKey: .dislikes_percent)
        is_subscribed = try values.decodeIfPresent(Int.self, forKey: .is_subscribed)
        suggested_videos = try values.decodeIfPresent([VideoDetail].self, forKey: .suggested_videos)
        video_ad = try values.decodeIfPresent(VideoAdUnion.self, forKey: .video_ad)
        history_id = try values.decodeIfPresent(Int.self, forKey: .history_id)
        featured_movie =  try values.decodeIfPresent(Int.self, forKey: .featured_movie)
    }
    
}

enum CategoryID: Codable {
    case integer(Int)
    case string(String)
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let x = try? container.decode(Int.self) {
            self = .integer(x)
            return
        }
        if let x = try? container.decode(String.self) {
            self = .string(x)
            return
        }
      
        throw DecodingError.typeMismatch(CategoryID.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for CategoryID"))
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .integer(let x):
            try container.encode(x)
        case .string(let x):
            try container.encode(x)
        }
    }
}

enum Sell_Video: Codable {
    case integer(Int)
    case string(String)
    case double(Double)

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let x = try? container.decode(Int.self) {
            self = .integer(x)
            return
        }
        if let x = try? container.decode(String.self) {
            self = .string(x)
            return
        }
        if let x = try? container.decode(Double.self) {
            self = .double(x)
            return
        }
        throw DecodingError.typeMismatch(Sell_Video.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for Sell_Video"))
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .integer(let x):
            try container.encode(x)
        case .string(let x):
            try container.encode(x)
        case .double(let x):
            try container.encode(x)
        }
    }
}

enum VideoAdUnion: Codable {
    
    case anythingArray([JSONAny])
    case videoAdClass(Video_ad)

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let x = try? container.decode([JSONAny].self) {
            self = .anythingArray(x)
            return
        }
        if let x = try? container.decode(Video_ad.self) {
            self = .videoAdClass(x)
            return
        }
        throw DecodingError.typeMismatch(VideoAdUnion.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for VideoAdUnion"))
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .anythingArray(let x):
            try container.encode(x)
        case .videoAdClass(let x):
            try container.encode(x)
        }
    }
    
}
