import Foundation
import Async
import UIKit
import PlaytubeSDK
import AVKit
import Contacts

class AppInstance {
    
    static let instance = AppInstance()
    
    var userId: Int? = nil
    var sessionId: String? = nil
    var cookie: String? = nil
    var categories = [String: String]()
    var subCategory =  [String: [[String: String]]]()
    var addCount:Int? = 0
    var userType = 0
    var contacts = [FetchedContact]()
    var notInterestedData = [NotInterestVideoModel.Datum]()
    var userProfile: MychannelModel.GetChannelInfoModel.GetChannelInfoSuccessModel?
    
    func getUserSession() -> Bool {
        log.verbose("getUserSession = \(UserDefaults.standard.getUserSessions(Key: Local.USER_SESSION.User_Session))")
        let localUserSessionData = UserDefaults.standard.getUserSessions(Key: Local.USER_SESSION.User_Session)
        if localUserSessionData.isEmpty {
            return false
        } else {
            self.userId = (localUserSessionData[Local.USER_SESSION.user_id]  as! Int)
            self.sessionId = localUserSessionData[Local.USER_SESSION.session_id] as? String ?? ""
            self.cookie = localUserSessionData[Local.USER_SESSION.cookie] as? String ?? ""
            return true
        }
    }
    
    func fetchUserProfile(completion: @escaping (Bool) -> ()) {
        let status = AppInstance.instance.getUserSession()
        if status {
            let userId = AppInstance.instance.userId ?? 0
            let sessionId = AppInstance.instance.sessionId ?? ""
            Async.background {
                Async.background {
                    MyChannelManager.instance.getChannelInfo(User_id: userId, Session_Token: sessionId, Channel_id: userId, completionBlock: { (success, sessionError, error) in
                        if success != nil {
                            Async.main {
                                AppInstance.instance.userProfile = success
                                completion(true)
                                log.debug("success")
                            }
                        } else if sessionError != nil {
                            Async.main {
                                log.error("sessionErrror = \(sessionError?.errors!.error_text ?? "")")
                                completion(false)
                            }
                        } else {
                            Async.main {
                                log.error("error = \(error?.localizedDescription ?? "")")
                                completion(false)
                            }
                        }
                    })
                }
            }
        } else {
            log.error(InterNetError)
        }
    }
    
    func GetSetting() {
        let getSetting =  UserDefaults.standard.getCategory()
        if getSetting != nil {
            log.debug("Already Saved in UserDefaults")
            self.categories = (getSetting ?? [:])
            log.verbose("categories = \(self.categories)")
        } else {
            log.debug("Saving settings in UserDefaults")
            Async.background {
                GetSettingsManager.instance.getSetting { (categories, settings, success, sessionError, error) in
                    if settings != nil {
                        Async.main {
                            let categories = settings?["categories"] as? [String: String]
                            let subCategories = settings?["sub_categories"] as? [String: [[String: String]]]
                            log.debug("categories = \(categories ?? [:])")
                            log.debug("settings = \(subCategories ?? [:])")
                            UserDefaults.standard.setCategory(categories ?? [:])
                            UserDefaults.standard.setSettings(settings)
                            print(UserDefaults.standard.getCategory())
                            UserDefaults.standard.setSubCategory(subCategories ?? [:])
                            self.categories = categories ?? [:]
                            self.subCategory = subCategories ?? [:]
                            print(self.categories)
                            log.verbose("categories = \(self.categories)")
                        }
                    } else if sessionError != nil {
                        Async.main {
                            log.error("sessionError = \(sessionError?.errors?.error_text ?? "")")
                        }
                    } else {
                        Async.main {
                            log.error("error = \(error?.localizedDescription ?? "")")
                        }
                    }
                }
            }
        }
    }
    
    func getNotInterestedData(data: [VideoDetail]) -> [VideoDetail] {
        var array: [VideoDetail] = []
        for i in data {
            let result = AppInstance.instance.notInterestedData.contains(where: {$0.video_id == i.id})
            if !result {
                array.append(i)
            }
        }
        return array
    }
    
    func fetchContacts() {
        print("Attempting to fetch contacts")
        let store = CNContactStore()
        store.requestAccess(for: .contacts) { (granted, error) in
            if let error = error {
                print("failed to request access", error)
                return
            }
            if granted {
                print("access granted")
                let keys = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey]
                let request = CNContactFetchRequest(keysToFetch: keys as [CNKeyDescriptor])
                do {
                    try store.enumerateContacts(with: request, usingBlock: { (contact, stopPointer) in
                        print(contact.givenName)
                        self.contacts.append(FetchedContact(firstName: contact.givenName, lastName: contact.familyName, telephone: contact.phoneNumbers.first?.value.stringValue ?? ""))
                    })
                } catch let error {
                    print("Failed to enumerate contact", error)
                }
            } else {
                print("access denied")
            }
        }
    }
    
    func getNotInterestedDataAPI() {
        if Connectivity.isConnectedToNetwork() {
            NotInterestManager.instance.getNotInterestDataAPI { success, sessionError, error in
                if success != nil {
                    self.notInterestedData = success?.data ?? []
                    log.verbose("Not Interest Data = \(self.notInterestedData.count)")
                } else if sessionError != nil {
                    Async.main {
                        log.error("responseError = \(sessionError?.errors!.error_text ?? "")")
                    }
                } else {
                    log.error("error = \(error?.localizedDescription ?? "")")
                }
            }
        }else {
            log.error(InterNetError)
        }
    }
    
}
