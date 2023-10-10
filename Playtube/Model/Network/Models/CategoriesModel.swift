
import Foundation

class GetSettings {
  
    struct GetSuccessSettings: Codable {
        
        let apiStatus, apiVersion: String
        let data: DataClass?
        
        enum CodingKeys: String, CodingKey {
            case apiStatus = "api_status"
            case apiVersion = "api_version"
            case data
        }
        
    }
    
    // MARK: - DataClass
    struct DataClass: Codable {
        
        let siteSettings: SiteSettings?

        enum CodingKeys: String, CodingKey {
            case siteSettings = "site_settings"
        }
        
    }

    // MARK: - SiteSettings
    struct SiteSettings: Codable {
        
        let theme, censoredWords, title, name: String
        let keyword, email, siteSettingsDescription, validation: String
        let recaptcha, language, seoLink, commentSystem: String
        let deleteAccount, totalVideos, totalViews, totalUsers: String
        let totalSubs, totalComments, totalLikes, totalDislikes: String
        let totalSaved, uploadSystem, importSystem, autoplaySystem: String
        let historySystem, userRegistration, verificationBadge, commentsDefaultNum: String
        let fbLogin, twLogin, plusLogin, proPkgPrice: String
        let paymentCurrency, goPro, paypalID, paypalSecret: String
        let paypalMode, userAds, maxUpload, pushID: String
        let pushKey, paypalCurrency, checkoutCurrency, checkoutPayment: String
        let checkoutMode, checkoutSellerID, checkoutPublishableKey, checkoutPrivateKey: String
        let creditCard, stripeCurrency, stripeSecret, stripeID: String
        let bankPayment, bankTransferNote, bankDescription: String
        let themeURL, siteURL: String
        let scriptVersion: String
        let currencyArray: [String]
        let currencySymbolArray: CurrencySymbolArray
        let payedSubscribers: String
        let continents: [String]
        let moviesCategories: MoviesCategories
        let subCategories: [String:[[String:String]]]?
        let categories: [String:String]?

        enum CodingKeys: String, CodingKey {
            case theme
            case censoredWords = "censored_words"
            case title, name, keyword, email
            case siteSettingsDescription = "description"
            case validation, recaptcha, language
            case seoLink = "seo_link"
            case commentSystem = "comment_system"
            case deleteAccount = "delete_account"
            case totalVideos = "total_videos"
            case totalViews = "total_views"
            case totalUsers = "total_users"
            case totalSubs = "total_subs"
            case totalComments = "total_comments"
            case totalLikes = "total_likes"
            case totalDislikes = "total_dislikes"
            case totalSaved = "total_saved"
            case uploadSystem = "upload_system"
            case importSystem = "import_system"
            case autoplaySystem = "autoplay_system"
            case historySystem = "history_system"
            case userRegistration = "user_registration"
            case verificationBadge = "verification_badge"
            case commentsDefaultNum = "comments_default_num"
            case fbLogin = "fb_login"
            case twLogin = "tw_login"
            case plusLogin = "plus_login"
            case proPkgPrice = "pro_pkg_price"
            case paymentCurrency = "payment_currency"
            case goPro = "go_pro"
            case paypalID = "paypal_id"
            case paypalSecret = "paypal_secret"
            case paypalMode = "paypal_mode"
            case userAds = "user_ads"
            case maxUpload = "max_upload"
            case pushID = "push_id"
            case pushKey = "push_key"
            case paypalCurrency = "paypal_currency"
            case checkoutCurrency = "checkout_currency"
            case checkoutPayment = "checkout_payment"
            case checkoutMode = "checkout_mode"
            case checkoutSellerID = "checkout_seller_id"
            case checkoutPublishableKey = "checkout_publishable_key"
            case checkoutPrivateKey = "checkout_private_key"
            case creditCard = "credit_card"
            case stripeCurrency = "stripe_currency"
            case stripeSecret = "stripe_secret"
            case stripeID = "stripe_id"
            case bankPayment = "bank_payment"
            case bankTransferNote = "bank_transfer_note"
            case bankDescription = "bank_description"
            case themeURL = "theme_url"
            case siteURL = "site_url"
            case scriptVersion = "script_version"
            case currencyArray = "currency_array"
            case currencySymbolArray = "currency_symbol_array"
            case payedSubscribers = "payed_subscribers"
            case continents
            case moviesCategories = "movies_categories"
            case subCategories = "sub_categories"
            case categories
        }
    }
    

    // MARK: - Categories
    struct Categories: Codable {
        let category1, category3, category4, category5: String
        let category6, category7, category8, category9: String
        let category10, category11, category12, category13: String
        let other: String

        enum CodingKeys: String, CodingKey {
            case category1 = "category__1"
            case category3 = "category__3"
            case category4 = "category__4"
            case category5 = "category__5"
            case category6 = "category__6"
            case category7 = "category__7"
            case category8 = "category__8"
            case category9 = "category__9"
            case category10 = "category__10"
            case category11 = "category__11"
            case category12 = "category__12"
            case category13 = "category__13"
            case other
        }
    }
    
    // MARK: - CurrencySymbolArray
    struct CurrencySymbolArray: Codable {
        let usd, eur, jpy, currencySymbolArrayTRY: String
        let gbp, rub, pln, ils: String
        let brl, inr: String

        enum CodingKeys: String, CodingKey {
            case usd = "USD"
            case eur = "EUR"
            case jpy = "JPY"
            case currencySymbolArrayTRY = "TRY"
            case gbp = "GBP"
            case rub = "RUB"
            case pln = "PLN"
            case ils = "ILS"
            case brl = "BRL"
            case inr = "INR"
        }
    }
    
    // MARK: - MoviesCategories
    struct MoviesCategories: Codable {
        let the514, other: String

        enum CodingKeys: String, CodingKey {
            case the514 = "514"
            case other
        }
    }

    // MARK: - SubCategories
    struct SubCategories: Codable {
        let category1: [Category1]

        enum CodingKeys: String, CodingKey {
            case category1 = "category__1"
        }
    }

    // MARK: - Category1
    struct Category1: Codable {
        let sub470: String

        enum CodingKeys: String, CodingKey {
            case sub470 = "sub__470"
        }
    }

    struct GetSettingsErrorModel: Codable {
        let apiStatus: String?
        let errors: Errors?
        
        enum CodingKeys: String, CodingKey {
            case apiStatus = "api_status"
            case errors
        }
    }

}
