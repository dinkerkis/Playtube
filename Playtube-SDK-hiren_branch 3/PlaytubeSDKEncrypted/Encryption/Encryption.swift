//
//  Encryption.swift
//  WoWonderMessengerSDKEncrypted
//
//  Created by Moghees on 5/21/21.
//

import Foundation
import UIKit


public class ServerCredentials{
    
    public static let instance  = ServerCredentials()
    public static func setServerDataWithKey(key:String){
        
        self.convertB(string: key, refresh: 2)
    }
    static func convertB(string : String , refresh : Int){
        
        var splitedKey = string.components(separatedBy: "/LHBhc3M9/")
        var decodedString = string
        var passwordString =  String(splitedKey[1])
        var infoSiteString =  String(splitedKey[0])
         decodedString = passwordString
        for _ in 0..<refresh {
            let decodedData = Data(base64Encoded: decodedString)!
            decodedString = String(data: decodedData, encoding: .utf8) ?? ""
        }
        var decodedPassword = decodedString
        if decodedPassword == "b6rDHe5JL1xZMgMHF3P6XbW3KDYbPlay$$TubeZwRWaWArdxJYx4TvOjtKXPyRBjH"{
            var infoSiteStringKey = infoSiteString
            for _ in 0..<5 {
                let decodedData = Data(base64Encoded: infoSiteStringKey)!
                infoSiteStringKey = String(data: decodedData, encoding: .utf8) ?? ""
            }
            var splitedKey = infoSiteStringKey.components(separatedBy: "/=+Y4eaU2=+/")
            var itemNumberKey = String(splitedKey[0])
            var itemNumberStringKey = itemNumberKey
            for _ in 0..<3 {
                let decodedData = Data(base64Encoded: itemNumberStringKey)!
                itemNumberStringKey = String(data: decodedData, encoding: .utf8) ?? ""
            }
            if itemNumberStringKey == "ibt0LW8ukHYbuzzv9Il3IJSkS" || itemNumberStringKey == "XpAVcecxCKOQXaXeahQI8d0ry" || itemNumberStringKey == "DuQpXFs4NG3ZPAmh6qYx" || itemNumberStringKey == "i4RbHJSXRJAimYML6swwLH0li" || itemNumberStringKey == "PbMHROQVS36rn2CRRjRslUJlh" || itemNumberStringKey == "6tvy5jHAyUo6wtyGBJJpmOVHq"  || itemNumberStringKey == "U3q4Ie5KOIt42jsyoAnES4NCY" || itemNumberStringKey == "U3q4Ie5KOIt42jsyoAnES4NCY" {
                
                var websiteKey = String(splitedKey[1]).components(separatedBy: "+/=k7H3dB+/=")
                var splitedWebsiteKey = String(websiteKey[0])
                var WebsiteDecoded = splitedWebsiteKey
                
                for _ in 0..<4 {
                    let decodedData = Data(base64Encoded: WebsiteDecoded)!
                    WebsiteDecoded = String(data: decodedData, encoding: .utf8)!
                }
                var serverKeyKey = String(websiteKey[1]).components(separatedBy: "+/=L7Tg9x+/=")
                var splitedServerKey = String(serverKeyKey[0])
                var serverKeyDecoded = splitedServerKey
                
                for _ in 0..<2 {
                    let decodedData = Data(base64Encoded: serverKeyDecoded)!
                    serverKeyDecoded = String(data: decodedData, encoding: .utf8)!
                }
                
//                var purchaseCodeyKey = String(splitedKey[6]).split(separator: "=")
                var splitedPurchaseCodeKey = String(serverKeyKey[1])
                var purchaseCodeDecoded = splitedPurchaseCodeKey
                
                for _ in 0..<5 {
                    let decodedData = Data(base64Encoded: purchaseCodeDecoded)!
                    purchaseCodeDecoded = String(data: decodedData, encoding: .utf8)!
                }
                self.setBaseUrl(url: WebsiteDecoded)
                self.setServerKey(serverKey: serverKeyDecoded)
                self.setPurchaseCode(purchaseCode: purchaseCodeDecoded)
            }else{
                print("item Code Error = Item code is invalid")
            }
        }else{
            print("Password is Incorrect")
           
        }
    }
    static func setBaseUrl(url:String){
        API.baseURL = url
//          API.baseURL = url
        print("API.BaseURL = \(API.baseURL)")
    }
    static  func setServerKey(serverKey:String){
        API.SERVER_KEY.Server_Key = serverKey
//         API.SERVER_KEY.Server_Key = serverKey
        print("API.ServerKey = \(API.SERVER_KEY.Server_Key)")
    }
    static func setPurchaseCode(purchaseCode:String){
        API.PURCHASE_CODE.Purchase_Code = purchaseCode
//        API.PURCHASE_CODE.Purchase_Code = purchaseCode
        print("API.PURCHASE_CODE = \(API.PURCHASE_CODE.Purchase_Code)")
    }
    
    
}
