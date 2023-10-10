//
//  API.swift
//  WoWonderMessengerSDKEncrypted
//
//  Created by Muhammad Haris Butt on 5/21/21.
//

import Foundation


public let InterNetError = "Internet is not available. Please Try later!"

public struct API {
    
    public static var baseURL = ""
    
    public struct GetHashPassword {
        public static let doughouzLight = "https://doughouzlight-license.com/api/AppPortfolio"
    }
    
    public struct AUTH_Constants_Methods {
        public static let LOGIN_API = "\(baseURL)/api/\(Params.AppVersion)?type=login"
        public static let REGISTER_API = "\(baseURL)/api/\(Params.AppVersion)?type=register"
        public static let FORGETPASSWORD_API = "\(baseURL)/api/\(Params.AppVersion)?type=reset_password"
        public static let DELETE_USER_API = "\(baseURL)/api/\(Params.AppVersion)?type=delete_user"
        public static let SOCIAL_LOGIN_API = "\(baseURL)/api/\(Params.AppVersion)?type=social_login"
    }
    
    public struct HOME_Constants_Methods {
        public static let VIDEOS_API = "\(baseURL)/api/\(Params.AppVersion)/?type=get_videos&featured_offset=\(Params.featuredOffset)&top_offset=\(Params.TopOffset)&latest_offset=\(Params.LatestOffset)&limit="
    }
    
    public struct Trending_Methods {
        public static let TRENDING_VIDEOS_API = "\(baseURL)/api/\(Params.AppVersion)/?type=get_trending_videos&offset=\(Params.Trending_Offset)&limit=\(Params.Trending_Limit)&s="
    }
    
    public struct PopularChannelMethods {
        public static let PopularChannelsApi = "\(baseURL)/api/\(Params.AppVersion)/?type=popular_channels"
    }
    
    public struct SessionsMethods {
        public static let SessionsApi = "\(baseURL)/api/\(Params.AppVersion)/?type=sessions"
    }
    
    public struct PLAYLIST_Methods {
        public  static let PLAYLIST_API = "\(baseURL)/api/\(Params.AppVersion)/?type=get_my_playlists"
        public static let CREATE_PLAYLIST_API = "\(baseURL)/api/\(Params.AppVersion)/?type=create_playlist"
        public static let UPDATE_PLAYLIST_API = "\(baseURL)/api/\(Params.AppVersion)/?type=edit_playlist"
        public  static let DELETE_PLAYLIST_API = "\(baseURL)/api/\(Params.AppVersion)/?type=delete_playlist"
        public static let PLAYLIST_VIDEOS_API = "\(baseURL)/api/\(Params.AppVersion)/?type=get_playlist_videos&list_id="
        public static let ADD_TO_PLAYLIST_API = "\(baseURL)/api/\(Params.AppVersion)/?type=add_to_list"
        public  static let GET_PLAYLIST_CHANNEL_API = "\(baseURL)/api/\(Params.AppVersion)/?type=get_my_playlists&channel_id="
    }
    
    public struct REPORT_VIDEO_Methods {
        public static let REPORT_VIDEO_API = "\(baseURL)/api/\(Params.AppVersion)/?type=report_video"
    }
    
    public struct MY_CHANNEL_Methods {
        public static let CHANGE_PASSWORD_API = "\(baseURL)/api/\(Params.AppVersion)/?type=change_password"
        public static let UPDATE_MY_CHANNEL_API = "\(baseURL)/api/\(Params.AppVersion)/?type=update_user_data"
        public static let GET_CHANNEL_INFO_API = "\(baseURL)/api/\(Params.AppVersion)/?type=get_channel_info&channel_id="
        public static let CLEAR_WATCH_HISTORY_API = "\(baseURL)/api/\(Params.AppVersion)/?type=delete_history"
        public  static let CHANNEL_VIDEOS_API = "\(baseURL)/api/\(Params.AppVersion)/?type=get_videos_by_channel&channel_id="
    }
    
    public struct SEARCH_VIDEOS_Methods {
        public static let SEARCH_VIDEOS_API = "\(baseURL)/api/\(Params.AppVersion)/?type=search_videos&offset=\(Params.Trending_Offset)&keyword="
    }
    
    public struct LIBRARY_VIDEOS_Methods {
        public static let LIKED_VIDEOS_API = "\(baseURL)/api/\(Params.AppVersion)/?type=get_liked"
        public static let RECENTLY_WATCHED_API = "\(baseURL)/api/\(Params.AppVersion)/?type=get_history"
        public static let SUBSCRIBED_CHANNEL_API = "\(baseURL)/api/\(Params.AppVersion)/?type=get_subscriptions&channel="
        public static let PaidVideoApi = "\(baseURL)/api/\(Params.AppVersion)/?type=paid_videos"
    }
    
    public struct NOTIFICATIONS_Methods {
        public static let NOTIFICATIONS_API = "\(baseURL)/api/\(Params.AppVersion)/?type=get_notifications"
    }
    
    public struct PLAY_VIDEO_Methods {
        public static let PLAY_VIDEO_API = "\(baseURL)/api/\(Params.AppVersion)/?type=get_video_details&video_id="
        public static let LIKE_DISLIKE_API = "\(baseURL)/api/\(Params.AppVersion)/?type=like_dislike_video"
    }
    
    public struct SUBSCRIBE_Methods {
        public static let SUBSCRIBE_CHANNEL_API = "\(baseURL)/api/\(Params.AppVersion)/?type=subscribe_to_channel&channel_id="
    }
    
    public struct Articles_Methods {
        public static let FETCH_ARTICLES_API = "\(baseURL)/api/\(Params.AppVersion)/?type=fetch_articles"
        public static let MOST_POPULAR_ARTICLES_API = "\(baseURL)/api/\(Params.AppVersion)/?type=most_popular_articles"
        public static let IMPORT_VIDEO_API = "\(baseURL)/import-video?cookie="
        public static let UPLOAD_API = "\(baseURL)/upload-api&user_id="
        public static let CREATE_ARTICLE_API = "\(baseURL)/create_article?cookie="
    }
    
    public struct COMMENT_Methods {
        public static let COMMENT_API = "\(baseURL)/api/\(Params.AppVersion)/?type=comments"
    }
    
    public struct MESSAGE_Methods {
        public static let MESSAGE_API = "\(baseURL)/api/\(Params.AppVersion)/?type=messages"
    }
        
    public struct NOT_INTEREST_Methods {
        public static let NOT_INTERESTED_API = "\(baseURL)/api/\(Params.AppVersion)/?type=not_interested"
    }
    
    public struct Verification_Methods {
        public  static let VERIFICATION_API = "\(baseURL)/api/\(Params.AppVersion)/?type=verification"
    }
    
    public struct Monetization_Methods {
        public static let MONETIZATION_API = "\(baseURL)/api/\(Params.AppVersion)/?type=monetization"
    }
    
    public struct BLocked_User_Methods {
        public static let GET_BLOCKED_USER_API = "\(baseURL)/api/\(Params.AppVersion)?type=block"
        public static let UNBLOCKED_USER_API = "\(baseURL)/api/\(Params.AppVersion)?type=block"
        public static let BLOCKED_USER_API = "\(baseURL)/api/\(Params.AppVersion)?type=block"
    }
    
    public struct Upgrade_Methods {
        public static let UPGRADE_PRO_API = "\(baseURL)/api/\(Params.AppVersion)?type=upgrade"
    }
    
    public struct Activity_Methods {
        public static let ACTIVITY_API = "\(baseURL)/api/\(Params.AppVersion)/?type=activity"
    }
    
    public struct TwoFActorMethods {
        public static let twoFactorApi = "\(baseURL)/api/\(Params.AppVersion)/?type=two-factor"
    }
    
    public struct SETTINGS_METHODS {
        public static let GET_SETTIGNS_API = "\(baseURL)/api/\(Params.AppVersion)/?type=get_settings"
    }
    
    public struct StockVideos {
        public static let STOCK_VIDEOS = "\(baseURL)/api/\(Params.AppVersion)/?type=stock_videos"
    }
    
    public struct MoviesMethod {
        public static let MOVIES_API = "\(baseURL)/api/\(Params.AppVersion)/?type=movies"
    }
    
    public struct BankTransferMethod {
        public static let bankTransfer = "\(baseURL)/api/\(Params.AppVersion)/?type=bank"
    }
    
    public struct GET_VIDEOS_BY_CATEGORY_Method {
        public static let GET_VIDEOS_BY_CATEGORY_API = "\(baseURL)/api/\(Params.AppVersion)/?type=get_videos_by_category"
    }
    
    public struct LiveStreamMethod {
        public static let LiveStream = "\(baseURL)/api/\(Params.AppVersion)/?type=live"
    }
    
    public struct TwoFactorMethod {
        public static let TwoFactor = "\(baseURL)/api/\(Params.AppVersion)/?type=two-factor"
    }
    
    public struct SHORTS_VIDEOS_Methods {
        public static let GET_SHORTS_VIDEOS_API = "\(baseURL)/api/\(Params.AppVersion)/?type=shorts"
    }
        
    public struct TV_Methods {
        public static let GENERATE_TV_CODE_API = "\(baseURL)/api/\(Params.AppVersion)/?type=tv"
    }
        
    public struct Wallet_Methods {
        public static let WALLET_API = "\(baseURL)/api/\(Params.AppVersion)/?type=wallet"
        public static let ADS_WALLET_API = "\(baseURL)/api/\(Params.AppVersion)/?type=ads"
    }
    
    public struct Razorpay_Methods {
        public static let RAZORPAY_API = "\(baseURL)/api/\(Params.AppVersion)/?type=razorpay"
    }
    
    public struct Cashfree_Methods {
        public static let CASHFREE_API = "\(baseURL)/api/\(Params.AppVersion)/?type=cashfree"
    }
    
    public struct Paystack_Methods {
        public static let PAYSTACK_API = "\(baseURL)/api/\(Params.AppVersion)/?type=paystack"
    }
    
    public struct Paysera_Methods {
        public static let PAYSERA_API = "\(baseURL)/api/\(Params.AppVersion)/?type=paysera"
    }
    
    
    public struct Iyzipay_Methods {
        public static let IYZIPAY_API = "\(baseURL)/api/\(Params.AppVersion)/?type=iyzipay"
    }
    
    public struct Params {
        public static var ServerKey = "server_key"
        public static var user_id = "user_id"
        public static var session_token = "s"
        public static var AppVersion = "v1.0"
        public static var Email = "email"
        public static var Username = "username"
        public static var Password = "password"
        public static var ConfirmPassword = "confirm_password"
        public static var type = "get_videos"
        public static var Name = "name"
        public static var Description = "desc"
        public static var Privacy = "pr"
        public static var List_id = "list_id"
        public static var Id = "id"
        public static var Text = "text"
        public static var CurrentPassword = "current_password"
        public static var NewPassword = "new_password"
        public static var RepeatPassword = "confirm_new_password"
        public static var FirstName = "first_name"
        public static var LastName = "last_name"
        public static var About = "about"
        public static var Gender = "gender"
        public static var SettingsType = "settings_type"
        public static var Video_id = "video_id"
        public static var List_uid = "list_uid"
        public static var Comment_Type = "type"
        public static var Fetch_Comment = "fetch_comments"
        public static var Provider = "provider"
        public static var Google_Key = "google_key"
        public static var AccessToken = "access_token"
        public static var Action = "action"
        public static var Add_Comment = "add"
        public static var Comment_Id = "comment_id"
        public static var reply_id = "reply_id"
        public static var avatar = "avatar"
        public static var cover = "cover"
        public static var Post_Id = "post_id"
        public static var Limit = "limit"
        public static var Offset = "offset"
        public static var Chat_Id = "get_chats"
        public static var User_Chat_Id = "get_user_messages"
        public static var User_Clear_Chat_Id = "delete_user_messages"
        public static var SEND_MESSAGE_Id = "send_message"
        public static var Recipient_Id = "recipient_id"
        public static var First_Id = "first_id"
        public static var Last_Id = "last_id"
        public static var Hash_Id = "hash_id"
        public static var Indentity_Id = "identity"
        public static var Message_Id = "message"
        public static var Amount = "amount"
        public static var Wallet = "wallet"
        public static var facebook = "facebook"
        public static var twitter = "twitter"
        public static var google = "google"
        public static var block_id = "block_id"
        public static var featuredOffset = 0
        public static var TopOffset = 0
        public static var LatestOffset = 0
        public static var Limit_Int = 0
        public static var Trending_Limit = 20
        public static var Trending_Offset = 0
        public static var profileId = "profile_id"
        public static var sortType = "sort_type"
        public static var lastCount = "last_count"
        public static var code = "code"
        public static var page_id = "page_id"
        public static var keyword = "keyword"
        public static var country = "country"
        public static var category = "category"
        public static var rating = "rating"
        public static var Fetch = "fetch"
        public static var release = "release"
        public static var device_id = "device_id"
        public static var stream_name = "stream_name"
        public static var activity_id = "activity_id"
        public static var Request = "request"
        public static var Phone = "phone"
        public static var Initialize = "initialize"
        public static var Pay_Type = "pay_type"
        public static var Wallet_Pay = "wallet_pay"
        
    }
    
    public struct API_TYPE {
        public static var get_shorts = "get_shorts"
        public static var get_user_shorts = "get_user_shorts"
        public static var wallet_pay = "wallet_pay"
    }
    
    public struct WALLET_PAY_TYPE {
        public static var subscribe = "subscribe"
        public static var pro = "pro"
        public static var buy = "buy"
        public static var rent = "rent"
    }
    
    public struct SERVER_KEY {
        public static var Server_Key = ""
    }
    
    public struct PURCHASE_CODE {
        public static var Purchase_Code = ""
    }
    
    public struct SETTINGS_TYPE {
        public static let SettingType_General = "general"
        public static let SettingType_Avatar = "avatar"
        public static let SettingType_Pause_History = "pause_history"        
    }
    
    public class WEBSITE_URL {
        public static let Help = "https://dev.lapcinema.com/contact-us"
        public static let AboutUs = "https://dev.lapcinema.com/terms/about-us"
        public static let TermsOfUse = "https://dev.lapcinema.com/terms/terms"
        public static let HelpAndFeedback = "https://dev.lapcinema.com/contact-us"
        public static let privacyPolicy = "https://dev.lapcinema.com/terms/privacy-policy"
    }
    
}

public class Local {
    
    public struct USER_SESSION {
        public static let User_Session = "User_Session"
        public static let cookie = "User_Session"
        public static let user_id = "user_id"
        public static let session_id = "session_id"
        public static let Current_Password = "current_password"
    }
    
    public struct GET_SETTINGS {
        public static let Categories = "Categories"
        public static let Settings = "Settings"
        public static let picture_In_Picture = "picture_In_Picture"
    }
    
    public struct WATCH_LATER {
        public static let watch_Later = "Watch_Later"
    }
    
    public struct NOT_INTERESTED {
        public static let not_interested = "Not_Interested"
    }
    
    public struct OFFLINE_DOWNLOAD {
        public static let offline_download = "Offline_Download"
    }
    
    public struct SHARED_VIDEOS {
        public static let shared_videos = "Shared_Videos"
    }
    
    public struct LANGUAGE {
        public static let LANGUAGE = "Language"
    }
    
    public struct DEVICE_ID {
        public static let DeviceId = "device_id"
    }
    
}

public class EventBusConstants {
    
    public struct EventBusConstantsUtils {
        public static let EVENT_INTERNET_CONNECTED = "internetConencted"
        public static let EVENT_INTERNET_DIS_CONNECTED = "internetDisconencted"
        public static let EVENT_SEARCH = "search"
        public static let EVENT_RECEIVE_RESULT_FOR_SEARCH = "receiveResult"
        public static let EVENT_RECEIVE_RESULT_FOR_SEARCH_TEXTFIELD = "receiveResultFromTextField"
        public static let EVENT_PLAYER_DATA_RECEIVED = "eventPlayerDataReceived"
        public static let EVENT_COMMENT_DATA_FETCH = "eventCommentDataFetch"
        public static let EVENT_CHANGE_SONG = "eventChangeSong"
        public static let EVENT_FILTER = "eventFilter"
        public static let EVENT_DISMISS_POPOVER = "eventDismissPopover"
        public static let EVENT_PLAY_PAUSE_BTN = "eventPopUpPlayPauseBtn"
    }
    
}
