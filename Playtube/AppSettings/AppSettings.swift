import Foundation
import UIKit
import PlaytubeSDK

struct AppConstant {
  
    static let key = "Vm0wd2VHUXhSWGxUV0doVFYwZG9WRmx0Y3pGWFZteDBaVVYwVjJKSGVIcFpWV00xVjJ4YWMxTnNXbFpOYWtFeFZsUkdZV014WkZWVGJGcFhZa1Z3V1ZadE1IaFRNVTVIVm01S2FWSnNjSEJXTUdSdlRteFplRmR0UmxoaVZrWTBWMnRvVjFkSFNraFZiR2hhWVRGd00xUnNXbUZUUjFKSVVtMTBUbFpZUWxsV1Z6QXhWakpHVjFOWWNHaFNiVkpZV1ZSR1MxRXhVbk5VVkZKUVZsaE9ORmxZY0VOWlZsbDNWMnhrVlZZeU9UTlpNblF6WlVaa1dXRkdhR2xTTVVwM1ZrWmFZVll3TUhoVmJHUlhZbFJzV0ZacVFsZE9WbkJXVjIxR1YwMXJWalJaTUZKUFZqRkplbUZFVGxkaGExcFlXa1phVTJSSFRraGlSazVPVmxjNGVWWnFSbUZXTVd4WVZWaHNVMWRIYUZsV01HUlRZMVpXYzFwRVVsZE5WM2g2VmxkNGEyRnRTa2RpUkZaYVpXczFkbGxVUmtwbFJtUnlWMnhhYVZkSGFESlhWbHBoVTIxUmQwNVZWbEppUjJoWVdXdGFkMWRXV2toa1IzUldUVlZzTkZadE5WZFdNa3BJWVVoQ1YyRnJOWFpXTUZwaFpFZFNSMVJzU21obGJGcFVWbFZhVW1ReVRuSmxSRnBPVjBWd1VGUlZaR3RPYkdSeVZtdHdhbUV6WnpKVVZscFhWakpLUm1OR1FsaGlSbHBYV2xWa1UxSXhUbk5pUjJoVFZrWmFXVlpYZUZOV01sWkhWMnRvYkZKck5YQlpXSEJEVFRGU1YxZHNaRmROVm5CSFdUQlZOVmxXV2paU2JGSmFZV3RhVTFwVldsZGpNVTV5VGxaT1YxSldWalZXYWtaVFZESlJlRlpyWkZSaE1taHlWV3RhZDFac1duRlVhMDVvVW0xNFYxWnNVa2RWTVZsM1YxUktWVlpXUmpOWk1uUTBUbXN4VmsxVk9VNVdhM0F4VmtSR2IySnRUbkpsUkZwT1ZtMVNjRll3V2t0aU1XUlhXVE5vVjAxVmJEUldNalZYVmtkR05sWnNiRlppUjJoRVZsWmFZVlpXUm5Sa1JUbFRZbFpLV1ZacVJtOWhNV3hYVTI1S1QxWnRVbGhaYkdodlRURndWMWR0Um10U1ZGWlhWREZhVjJGV1NsbFJhbHBYVm5wR00xWlVSbHBsUm1SeFYyeGthVkpWY0doV2JYaGhaREZTUjJORlpGaGhNbEp5Vm0wMVExTkdXblJsUjNSWFRXdFdObFZYZEdGV01rcFpWVzVHWVZaV2NHRmFWbHBUWkZaU2MyRkhiRk5OTW1oMlZteGplRTVHYkZkWGEyUnBVMFUxV1ZsVVRsTldWbFowWlVoa1ZGWnVRbGRXTWpGSFZsVXhWMk5JYkZwTlJuQjJWbTB4UzFkWFJrbGpSbVJwVmtWYVNWWkhNSGhUTVU1WFVtNU9ZVkl5ZUZSVVZ6RnZVbXhaZVdWR1pGcFdiVkl3Vm0xNGIxWnRSWGxWYkZwYVlrZG9SRlpFUm5OV1ZrcDFXa1pTVjJKV1NscFhhMVpoVkRGa2MxZHVVbFpoTW5oWFZGYzFiMlJzYkhKWGEzUlhWakJ3U0ZsVlduZFdNVXBaVVd4V1YySkdXbWhXVkVwT1pVWk9jMVp0YkZOaE1YQllWbTEwVTFGck5WSlFWREE5/LHBhc3M9/WWpaeVJFaGxOVXBNTVhoYVRXZE5TRVl6VURaWVlsY3pTMFJaWWxCc1lYa2tKRlIxWW1WYWQxSlhZVmRCY21SNFNsbDRORlIyVDJwMFMxaFFlVkpDYWtnPQ=="
    
    static let javascriptYoutubeUrlEvaluator = "document.getElementsByTagName('video')[0].src"
    
}

class AppSettings {
    
    static let showSocicalLogin = true
    static let googleClientKey = "497109148599-u0g40f3e5uh53286hdrpsj10v505tral.apps.googleusercontent.com"
    static let oneSignalAppId = "b64b10e7-4cc4-455b-adcb-54e580e6b5ff"
    static let addUnitId = "ca-app-pub-3940256099942544/2934735716"
    static let interestialAddUnitId = "ca-app-pub-3940256099942544/4411468910"
    static let isPurchase = false
    
    // you will get this from brainTree Sandbox account
    static let paypalAuthorizationToken = "sandbox_zjzj7brd_fzpwr2q9pk2m568s"
    
    /*
     * in this you need replace your bundle id before .payment
     * you need to add this URL scheme in your Project info list
     */
    static let BrainTreeURLScheme = "com.SunScript.PlayTube.IOS.App.payments"
    
    static var showFacebookLogin: Bool = true
    static var showGoogleLogin: Bool = true
    static var showAppleLogin: Bool = true
    static var showWoWonderLogin: Bool = true
    static var ShowDownloadButton: Bool = true
    static var shouldShowAddMobBanner: Bool = true
    static var interestialCount: Int? = 3
    static var appColor: UIColor = UIColor.init(hexFromString: "ffffff")
    static var language: String? = "English"
    
    static let wowonder_ServerKey = "131c471c8b4edf662dd0ebf7adf3c3d7365838b9"
    static let wowonder_URL = "https://dev.lapcinema.com/"
}

extension UIColor {
    
    @nonobjc class var mainColor: UIColor {
        let myColor = UIColor(named: "mainColor")
        return myColor!
    }
    
    @nonobjc class var startColor: UIColor {
        return UIColor.hexStringToUIColor(hex: "#444444")
    }
    
    @nonobjc class var endColor: UIColor {
        return UIColor.hexStringToUIColor(hex: "#FFFFFF")
    }
    
    @nonobjc class var pinkColor: UIColor {
        return UIColor.hexStringToUIColor(hex: "#D14660")
    }
    
    @nonobjc class var buttonColor: UIColor {
        return UIColor.hexStringToUIColor(hex: "#56B5FF")
    }
    
    @nonobjc class var tabMiddleColor: UIColor {
        return UIColor.hexStringToUIColor(hex: "#0F64F7")
    }
    
    @nonobjc class var bgcolor1: UIColor {
        let myColor = UIColor(named: "bgcolor1")
        return myColor!
    }
    
    @nonobjc class var bgcolor2: UIColor {
        let myColor = UIColor(named: "bgcolor2")
        return myColor!
    }
    
    @nonobjc class var fontcolor: UIColor {
        let myColor = UIColor(named: "fontcolor")
        return myColor!
    }
    
}
