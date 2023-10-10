import Foundation
import PlaytubeSDK

extension UserDefaults {
    
    // let Category: String = "Category"
    
    func setCategory(_ category: [String: String]) {
//        let encoded = try? NSKeyedArchiver.archivedData(withRootObject: category, requiringSecureCoding: false)
        setValue(category, forKey: "Category")
        // synchronize()
    }
    
    func setSettings(_ category: [String: Any]?) {
//        let encoded = try? NSKeyedArchiver.archivedData(withRootObject: category, requiringSecureCoding: false)
        if let category = category {
            setValue(category, forKey: "SettingData")
        }
        // synchronize()
    }
    
    
    func setSubCategory(_ category: [String: [[String: String]]]) {
        let encoded = try? NSKeyedArchiver.archivedData(withRootObject: category, requiringSecureCoding: false)
        setValue(encoded, forKey: "SubCategory")
        // synchronize()
    }
    
    func getSubCategory() -> [String: [[String: String]]]? {
        return object(forKey: "SubCategory") as? [String: [[String: String]]]
    }
    
    func getCategory() -> [String: String]? {
        return object(forKey: "Category") as? [String: String]
    }
    
    func getSettings() -> [String: Any]? {
        return object(forKey: "SettingData") as? [String: Any]
    }
    
    //    func setGetSettings(value: GetSettings.Categories, ForKey:String) {
    //        set(value, forKey: ForKey)
    //        // synchronize()
    //    }
    
    //    func getGetSettings(Key:String) ->  GetSettings.Categories?{
    //        return ((object(forKey: Key) as! GetSettings.Categories))
    //    }
    
    func clearUserDefaults() {
        removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
    }
    
    func removeValuefromUserdefault(Key: String) {
        removeObject(forKey: Key)
    }
    
    func setWatchLater(value: [Data], ForKey: String){
        set(value, forKey: ForKey)
        synchronize()
    }
    
    func setPassword(value: String, ForKey: String) {
        set(value, forKey: ForKey)
        // synchronize()
    }
    
    func setSystemTheme(value: Bool, ForKey: String) {
        set(value, forKey: ForKey)
        // synchronize()
    }
    
    func getSystemTheme(Key: String) ->  Bool {
        return object(forKey: Key)  as?  Bool ?? false
    }
    
    func getPassword(Key: String) ->  String {
        return object(forKey: Key)  as?  String ?? ""
    }
    
    func getWatchLater(Key:String) ->  [Data] {
        return ((object(forKey: Key) as? [Data]) ?? [])!
    }
    
    func setNotInterested(value: [Data], ForKey:String){
        set(value, forKey: ForKey)
        synchronize()
    }
    
    func getNotInterested(Key: String) ->  [Data] {
        return ((object(forKey: Key) as? [Data]) ?? [])!
    }
    
    func setPictureInPicture(value: Bool, ForKey: String) {
        set(value, forKey: ForKey)
        synchronize()
    }
    
    func getPictureInPicture(Key: String) ->  Bool {
        return object(forKey: Key) as? Bool ?? false
    }
    
    func setOfflineDownload(value: [Data], ForKey: String) {
        set(value, forKey: ForKey)
        synchronize()
    }
    
    func getOfflineDownload(Key: String) ->  [Data] {
        return ((object(forKey: Key) as? [Data]) ?? [])!
    }
    
    func setSharedVideos(value: [Data], ForKey: String) {
        set(value, forKey: ForKey)
        synchronize()
    }
    
    func getSharedVideos(Key: String) ->  [Data] {
        return ((object(forKey: Key) as? [Data]) ?? [])!
    }
    
    func setLanguage(value: String, ForKey: String) {
        set(value, forKey: ForKey)
        synchronize()
    }
    
    func getLanguage(Key: String) ->  String {
        return ((object(forKey: Key) as? String) ?? "")!
    }
    
    func setLibraryImages(value: [String], ForKey: String) {
        set(value, forKey: ForKey)
        synchronize()
    }
    
    func getLibraryImages(Key:String) ->  String {
        return ((object(forKey: Key) as? String) ?? "")!
    }
    
    func setSubscriptionImage(value: String, ForKey: String) {
        set(value, forKey: ForKey)
        synchronize()
    }
    
    func getSubscriptionImage(Key: String) ->  String {
        return ((object(forKey: Key) as? String) ?? "")!
    }
    
    func setRecentWatchImage(value: String, ForKey: String) {
        set(value, forKey: ForKey)
        synchronize()
    }
    
    func getRecentWatchImage(Key: String) ->  String {
        return ((object(forKey: Key) as? String) ?? "")!
    }
    
    func setWatchLaterImage(value: String, ForKey: String) {
        set(value, forKey: ForKey)
        synchronize()
    }
    
    func getOfflineImage(Key: String) ->  String {
        return ((object(forKey: Key) as? String) ?? "")!
    }
    
    func setOfflineImage(value: String, ForKey: String) {
        set(value, forKey: ForKey)
        synchronize()
    }
    
    func getWatchLaterImage(Key: String) ->  String {
        return ((object(forKey: Key) as? String) ?? "")!
    }
    
    func setLikedImage(value: String, ForKey: String) {
        set(value, forKey: ForKey)
        synchronize()
    }
    
    func getLikedImage(Key:String) ->  String {
        return ((object(forKey: Key) as? String) ?? "")!
    }
     
    func setPlaylistImage(value: String, ForKey: String) {
        set(value, forKey: ForKey)
        synchronize()
    }
    
    func getPlaylistImage(Key: String) ->  String {
        return ((object(forKey: Key) as? String) ?? "")!
    }
    
    func setSharedImage(value: String, ForKey: String) {
        set(value, forKey: ForKey)
        synchronize()
    }
    
    func getSharedImage(Key: String) ->  String {
        return ((object(forKey: Key) as? String) ?? "")!
    }
    
    func setDarkMode(value: Bool, ForKey: String) {
        set(value, forKey: ForKey)
        synchronize()
    }
    
    func getDarkMode(Key: String) ->  Bool {
        return ((object(forKey: Key) as? Bool) ?? false)!
    }
    
    func setDeviceId(value: String, ForKey: String) {
        set(value, forKey: ForKey)
        synchronize()
    }
    
    func getDeviceId(Key:String) ->  String {
        return ((object(forKey: Key) as? String) ?? "")!
    }
    
    func setAutoPlay(value: Bool = false) {
        set(value, forKey: "autoPlay")
        synchronize()
    }
    
    func getAutoPlay() -> Bool {
        return ((value(forKey: "autoPlay") as? Bool) ?? false)
    }
}
