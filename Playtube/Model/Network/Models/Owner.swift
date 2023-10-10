import Foundation


struct Owner : Codable {
    
    let id : Int?
    let username : String?
    let email : String?
    let ip_address : String?
    let first_name : String?
    let last_name : String?
    let gender : String?
    let device_id : String?
    let language : String?
    let avatar : String?
    let cover : String?
    let src : String?
    let country_id : Int?
    let age : Int?
    let about : String?
    let google : String?
    let facebook : String?
    let twitter : String?
    let instagram : String?
    let active : Int?
    let admin : Int?
    let verified : Int?
    let last_active : Int?
    let registered : String?
    let time : Int?
    let is_pro : Int?
    let pro_type : Int?
    let imports : Int?
    let uploads : Int?
    let wallet : Double?
    let balance : String?
    let video_mon : Int?
    let age_changed : Int?
    let donation_paypal_email : String?
    let user_upload_limit : String?
    let two_factor : Int?
    let google_secret : String?
    let authy_id : String?
    let two_factor_method : String?
    let last_month : String?
    let active_time : Int?
    let active_expire : String?
    let phone_number : String?
    let subscriber_price : String?
    let monetization : Int?
    let new_email : String?
    let fav_category : [String]?
    let total_ads : Double?
    let suspend_upload : Int?
    let suspend_import : Int?
    let paystack_ref : String?
    let conversationId : String?
    let point_day_expire : Int?
    let points : Int?
    let daily_points : Int?
    let converted_points : Int?
    let info_file : String?
    let google_tracking_code : String?
    let newsletters : Int?
    let vk : String?
    let qq : String?
    let wechat : String?
    let discord : String?
    let mailru : String?
    let linkedIn : String?
    let pause_history : Int?
    let tv_code : String?
    let permission : String?
    let referrer : Int?
    let ref_user_id : Int?
    let ref_type : String?
    let privacy : Privacy?
    let name : String?
    let ex_avatar : String?
    let ex_cover : String?
    let url : String?
    let about_decoded : String?
    let full_cover : String?
    let wallet_or : Double?
    let balance_or : String?
    let name_v : String?
    let country_name : String?
    let gender_text : String?
    let am_i_subscribed : Int?
    let subscribe_count : SubscribersCount?
    let channel_notify : Bool?
    
    enum CodingKeys: String, CodingKey {
        
        case id = "id"
        case username = "username"
        case email = "email"
        case ip_address = "ip_address"
        case first_name = "first_name"
        case last_name = "last_name"
        case gender = "gender"
        case device_id = "device_id"
        case language = "language"
        case avatar = "avatar"
        case cover = "cover"
        case src = "src"
        case country_id = "country_id"
        case age = "age"
        case about = "about"
        case google = "google"
        case facebook = "facebook"
        case twitter = "twitter"
        case instagram = "instagram"
        case active = "active"
        case admin = "admin"
        case verified = "verified"
        case last_active = "last_active"
        case registered = "registered"
        case time = "time"
        case is_pro = "is_pro"
        case pro_type = "pro_type"
        case imports = "imports"
        case uploads = "uploads"
        case wallet = "wallet"
        case balance = "balance"
        case video_mon = "video_mon"
        case age_changed = "age_changed"
        case donation_paypal_email = "donation_paypal_email"
        case user_upload_limit = "user_upload_limit"
        case two_factor = "two_factor"
        case google_secret = "google_secret"
        case authy_id = "authy_id"
        case two_factor_method = "two_factor_method"
        case last_month = "last_month"
        case active_time = "active_time"
        case active_expire = "active_expire"
        case phone_number = "phone_number"
        case subscriber_price = "subscriber_price"
        case monetization = "monetization"
        case new_email = "new_email"
        case fav_category = "fav_category"
        case total_ads = "total_ads"
        case suspend_upload = "suspend_upload"
        case suspend_import = "suspend_import"
        case paystack_ref = "paystack_ref"
        case conversationId = "ConversationId"
        case point_day_expire = "point_day_expire"
        case points = "points"
        case daily_points = "daily_points"
        case converted_points = "converted_points"
        case info_file = "info_file"
        case google_tracking_code = "google_tracking_code"
        case newsletters = "newsletters"
        case vk = "vk"
        case qq = "qq"
        case wechat = "wechat"
        case discord = "discord"
        case mailru = "mailru"
        case linkedIn = "linkedIn"
        case pause_history = "pause_history"
        case tv_code = "tv_code"
        case permission = "permission"
        case referrer = "referrer"
        case ref_user_id = "ref_user_id"
        case ref_type = "ref_type"
        case privacy = "privacy"
        case name = "name"
        case ex_avatar = "ex_avatar"
        case ex_cover = "ex_cover"
        case url = "url"
        case about_decoded = "about_decoded"
        case full_cover = "full_cover"
        case wallet_or = "wallet_or"
        case balance_or = "balance_or"
        case name_v = "name_v"
        case country_name = "country_name"
        case gender_text = "gender_text"
        case am_i_subscribed = "am_i_subscribed"
        case subscribe_count = "subscribe_count"
        case channel_notify = "channel_notify"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decodeIfPresent(Int.self, forKey: .id)
        username = try values.decodeIfPresent(String.self, forKey: .username)
        email = try values.decodeIfPresent(String.self, forKey: .email)
        ip_address = try values.decodeIfPresent(String.self, forKey: .ip_address)
        first_name = try values.decodeIfPresent(String.self, forKey: .first_name)
        last_name = try values.decodeIfPresent(String.self, forKey: .last_name)
        gender = try values.decodeIfPresent(String.self, forKey: .gender)
        device_id = try values.decodeIfPresent(String.self, forKey: .device_id)
        language = try values.decodeIfPresent(String.self, forKey: .language)
        avatar = try values.decodeIfPresent(String.self, forKey: .avatar)
        cover = try values.decodeIfPresent(String.self, forKey: .cover)
        src = try values.decodeIfPresent(String.self, forKey: .src)
        country_id = try values.decodeIfPresent(Int.self, forKey: .country_id)
        age = try values.decodeIfPresent(Int.self, forKey: .age)
        about = try values.decodeIfPresent(String.self, forKey: .about)
        google = try values.decodeIfPresent(String.self, forKey: .google)
        facebook = try values.decodeIfPresent(String.self, forKey: .facebook)
        twitter = try values.decodeIfPresent(String.self, forKey: .twitter)
        instagram = try values.decodeIfPresent(String.self, forKey: .instagram)
        active = try values.decodeIfPresent(Int.self, forKey: .active)
        admin = try values.decodeIfPresent(Int.self, forKey: .admin)
        verified = try values.decodeIfPresent(Int.self, forKey: .verified)
        last_active = try values.decodeIfPresent(Int.self, forKey: .last_active)
        registered = try values.decodeIfPresent(String.self, forKey: .registered)
        time = try values.decodeIfPresent(Int.self, forKey: .time)
        is_pro = try values.decodeIfPresent(Int.self, forKey: .is_pro)
        pro_type = try values.decodeIfPresent(Int.self, forKey: .pro_type)
        imports = try values.decodeIfPresent(Int.self, forKey: .imports)
        uploads = try values.decodeIfPresent(Int.self, forKey: .uploads)
        wallet = try values.decodeIfPresent(Double.self, forKey: .wallet)
        balance = try values.decodeIfPresent(String.self, forKey: .balance)
        video_mon = try values.decodeIfPresent(Int.self, forKey: .video_mon)
        age_changed = try values.decodeIfPresent(Int.self, forKey: .age_changed)
        donation_paypal_email = try values.decodeIfPresent(String.self, forKey: .donation_paypal_email)
        user_upload_limit = try values.decodeIfPresent(String.self, forKey: .user_upload_limit)
        two_factor = try values.decodeIfPresent(Int.self, forKey: .two_factor)
        google_secret = try values.decodeIfPresent(String.self, forKey: .google_secret)
        authy_id = try values.decodeIfPresent(String.self, forKey: .authy_id)
        two_factor_method = try values.decodeIfPresent(String.self, forKey: .two_factor_method)
        last_month = try values.decodeIfPresent(String.self, forKey: .last_month)
        active_time = try values.decodeIfPresent(Int.self, forKey: .active_time)
        active_expire = try values.decodeIfPresent(String.self, forKey: .active_expire)
        phone_number = try values.decodeIfPresent(String.self, forKey: .phone_number)
        subscriber_price = try values.decodeIfPresent(String.self, forKey: .subscriber_price)
        monetization = try values.decodeIfPresent(Int.self, forKey: .monetization)
        new_email = try values.decodeIfPresent(String.self, forKey: .new_email)
        fav_category = try values.decodeIfPresent([String].self, forKey: .fav_category)
        total_ads = try values.decodeIfPresent(Double.self, forKey: .total_ads)
        suspend_upload = try values.decodeIfPresent(Int.self, forKey: .suspend_upload)
        suspend_import = try values.decodeIfPresent(Int.self, forKey: .suspend_import)
        paystack_ref = try values.decodeIfPresent(String.self, forKey: .paystack_ref)
        conversationId = try values.decodeIfPresent(String.self, forKey: .conversationId)
        point_day_expire = try values.decodeIfPresent(Int.self, forKey: .point_day_expire)
        points = try values.decodeIfPresent(Int.self, forKey: .points)
        daily_points = try values.decodeIfPresent(Int.self, forKey: .daily_points)
        converted_points = try values.decodeIfPresent(Int.self, forKey: .converted_points)
        info_file = try values.decodeIfPresent(String.self, forKey: .info_file)
        google_tracking_code = try values.decodeIfPresent(String.self, forKey: .google_tracking_code)
        newsletters = try values.decodeIfPresent(Int.self, forKey: .newsletters)
        vk = try values.decodeIfPresent(String.self, forKey: .vk)
        qq = try values.decodeIfPresent(String.self, forKey: .qq)
        wechat = try values.decodeIfPresent(String.self, forKey: .wechat)
        discord = try values.decodeIfPresent(String.self, forKey: .discord)
        mailru = try values.decodeIfPresent(String.self, forKey: .mailru)
        linkedIn = try values.decodeIfPresent(String.self, forKey: .linkedIn)
        pause_history = try values.decodeIfPresent(Int.self, forKey: .pause_history)
        tv_code = try values.decodeIfPresent(String.self, forKey: .tv_code)
        permission = try values.decodeIfPresent(String.self, forKey: .permission)
        referrer = try values.decodeIfPresent(Int.self, forKey: .referrer)
        ref_user_id = try values.decodeIfPresent(Int.self, forKey: .ref_user_id)
        ref_type = try values.decodeIfPresent(String.self, forKey: .ref_type)
        privacy = try values.decodeIfPresent(Privacy.self, forKey: .privacy)
        name = try values.decodeIfPresent(String.self, forKey: .name)
        ex_avatar = try values.decodeIfPresent(String.self, forKey: .ex_avatar)
        ex_cover = try values.decodeIfPresent(String.self, forKey: .ex_cover)
        url = try values.decodeIfPresent(String.self, forKey: .url)
        about_decoded = try values.decodeIfPresent(String.self, forKey: .about_decoded)
        full_cover = try values.decodeIfPresent(String.self, forKey: .full_cover)
        wallet_or = try values.decodeIfPresent(Double.self, forKey: .wallet_or)
        balance_or = try values.decodeIfPresent(String.self, forKey: .balance_or)
        name_v = try values.decodeIfPresent(String.self, forKey: .name_v)
        country_name = try values.decodeIfPresent(String.self, forKey: .country_name)
        gender_text = try values.decodeIfPresent(String.self, forKey: .gender_text)
        am_i_subscribed = try values.decodeIfPresent(Int.self, forKey: .am_i_subscribed)
        subscribe_count = try values.decodeIfPresent(SubscribersCount.self, forKey: .subscribe_count)
        channel_notify = try values.decodeIfPresent(Bool.self, forKey: .channel_notify)
    }
    
}
