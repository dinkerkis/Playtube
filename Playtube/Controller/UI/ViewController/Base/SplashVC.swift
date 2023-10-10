import UIKit
import Async
import SwiftEventBus
import PlaytubeSDK

class SplashVC: BaseVC {
    
    // MARK: - View Life Cycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.fetchUserProfile()
    }
    
    deinit {
        SwiftEventBus.unregister(self)
    }
    
    // MARK: - Helper Functions
    
    func fetchUserProfile() {
        if appDelegate.isInternetConnected {
            let status = AppInstance.instance.getUserSession()
            if status {
                let userId = AppInstance.instance.userId ?? 0
                let sessionID = AppInstance.instance.sessionId ?? ""
                Async.background {
                    MyChannelManager.instance.getChannelInfo(User_id: userId, Session_Token: sessionID, Channel_id: userId, completionBlock: { (success, sessionError, error) in
                        if success != nil{
                            Async.main {
                                AppInstance.instance.userProfile = success ?? nil
                                AppInstance.instance.getNotInterestedDataAPI()
                                SwiftEventBus.unregister(self)
                                AppInstance.instance.userType = 1
                                let vc = R.storyboard.loggedUser.tabBarNav()
                                self.appDelegate.window?.rootViewController = vc
                            }
                        } else if sessionError != nil {
                            Async.main {
                                log.error("sessionError = \(sessionError?.errors?.error_text ?? "")")
                                self.view.makeToast(sessionError?.errors?.error_text ?? "")
                            }
                        } else {
                            Async.main {
                                log.error("error = \(error?.localizedDescription ?? "")")
                                self.view.makeToast(error?.localizedDescription)
                            }
                        }
                    })
                }
            } else {
                SwiftEventBus.unregister(self)
                let mainNav =  R.storyboard.auth.login()
                self.appDelegate.window?.rootViewController = mainNav
            }
        } else {
            self.view.makeToast(InterNetError)
        }
    }
    
}
