import UIKit
import AVKit
import IQKeyboardManagerSwift
import SwiftyBeaver
import DropDown
import Async
import OneSignal
import FBSDKLoginKit
import GoogleSignIn
import PlaytubeSDK
import FlowplayerSDK
import AVFoundation

let log = SwiftyBeaver.self

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate,OSSubscriptionObserver {
    
    var isInternetConnected = Connectivity.isConnectedToNetwork()
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        initFramework(application: application, launchOptions: launchOptions)
        Flowplayer.current.accessToken = "eyJraWQiOiI3R0VUcmo0R2Q5ZVQiLCJ0eXAiOiJKV1QiLCJhbGciOiJFUzI1NiJ9.eyJjIjoie1wiYWNsXCI6MjIsXCJpZFwiOlwiN0dFVHJqNEdkOWVUXCJ9IiwiaXNzIjoiRmxvd3BsYXllciJ9.bm-PArwvMV1LaiZI-Ih-OG1JF54-SVmSEiQ31mT4fFRuFGL-rPYFWoAb_XGAPSEH2sgLt3cDr7_kK6Gqiiipjg"
        Flowplayer.current.configure()
        return true
    }
    
    func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        
        let handled: Bool = ApplicationDelegate.shared
            .application(application, open: url, sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String, annotation: options[UIApplication.OpenURLOptionsKey.annotation])
        // Add any custom logic here.
        return handled
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    private func initFramework(application: UIApplication, launchOptions: [UIApplication.LaunchOptionsKey: Any]?){
        
        ServerCredentials.setServerDataWithKey(key: AppConstant.key)
        AppInstance.instance.fetchContacts()
        
        let preferredLanguage = NSLocale.preferredLanguages[0]
        if preferredLanguage.starts(with: "ar") {
            UIView.appearance().semanticContentAttribute = .forceRightToLeft
        } else {
            UIView.appearance().semanticContentAttribute = .forceLeftToRight
        }

        window?.overrideUserInterfaceStyle = .dark
//        let status = UserDefaults.standard.getDarkMode(Key: "darkMode")
//        let isSystemTheme = UserDefaults.standard.getSystemTheme(Key: "SystemTheme")
//        if #available(iOS 13.0, *) {
//            if isSystemTheme {
//                window?.overrideUserInterfaceStyle = UIScreen.main.traitCollection.userInterfaceStyle
//            }else {
//                if status {
//                    window?.overrideUserInterfaceStyle = .dark
//                } else {
//                    window?.overrideUserInterfaceStyle = .light
//                }
//            }
//        }
        // BTAppSwitch.setReturnURLScheme(AppSettings.BrainTreeURLScheme)
        //BTAppContextSwitcher.setReturnURLScheme(AppSettings.BrainTreeURLScheme)
        
        GIDSignIn.sharedInstance().clientID = AppSettings.googleClientKey
        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        let onesignalInitSettings = [kOSSettingsKeyAutoPrompt: false]
        OneSignal.initWithLaunchOptions(launchOptions,
                                        appId:AppSettings.oneSignalAppId ,
                                        handleNotificationAction: nil,
                                        settings: onesignalInitSettings)
        OneSignal.inFocusDisplayType = OSNotificationDisplayType.notification;
        OneSignal.add(self as OSSubscriptionObserver)
        
        OneSignal.promptForPushNotifications(userResponse: { accepted in
            print("User accepted notifications: \(accepted)")
        })
        
        
        // PayPalMobile.initializeWithClientIds(forEnvironments: [PayPalEnvironmentProduction:"",PayPalEnvironmentSandbox:"AYQj_efvWzS7BgDU42nwInlwmetwd3ZT5WloT2ePnfinLw59GcR_EzEhnG8AtRBp9frGuvs09HsKagKJ"])
        
        AppInstance.instance.GetSetting()
        IQKeyboardManager.shared.enable = true
        DropDown.startListeningToKeyboard()
        let console = ConsoleDestination()
        log.addDestination(console)
        
        let backgroundSessionIdentifier = "com.example.app.backgroundsession"
        URLSessionConfiguration.background(withIdentifier: backgroundSessionIdentifier)
        self.setUpPictureInPicture()
    }
    
    func onOSSubscriptionChanged(_ stateChanges: OSSubscriptionStateChanges!) {
        if !stateChanges.from.subscribed && stateChanges.to.subscribed {
            print("Subscribed for OneSignal push notifications!")
        }
        print("SubscriptionStateChange: \n\(stateChanges)")
        //The player id is inside stateChanges. But be careful, this value can be nil if the user has not granted you permission to send notifications.
        if let playerId = stateChanges.to.userId {
            print("Current playerId \(playerId)")
            UserDefaults.standard.setDeviceId(value: playerId, ForKey: Local.DEVICE_ID.DeviceId)
        }
        
    }
    
    func setUpPictureInPicture() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSession.Category.playback)
        } catch  {
            print("Audio session failed")
        }
        UserDefaults.standard.setPictureInPicture(value: AVPictureInPictureController.isPictureInPictureSupported(), ForKey: Local.GET_SETTINGS.picture_In_Picture)
    }
    
}
