//
//  SessionManager.swift
//  XELS
//
//  Created by iMac on 11/1/19.
//  Copyright © 2019 Silicon Orchard Ltd. All rights reserved.
//

import Foundation
import ObjectMapper

class SessionManager {
    
    private static let instance = SessionManager()
    
    class func sharedInstance() -> SessionManager {
        return self.instance
    }
    
    
    var currentUser: User? {
        get{
            return self.getCurrentUser()
        }
        set {
            self.setCurrentUser(user: newValue)
        }
    }
    
        
    func setAppropriateVC() {
        
        let appDeledate = UIApplication.shared.delegate as! AppDelegate
        
        if self.currentUser != nil {
            let storyBoard = UIStoryboard(name: "Main", bundle: nil)
            let frontViewController =  storyBoard.instantiateViewController(withIdentifier: "dashboardNav")
            let rightViewController = storyBoard.instantiateViewController(withIdentifier: "menuVC")
            
            appDeledate.revealViewController = SWRevealViewController()
            appDeledate.revealViewController?.setFront(frontViewController, animated: false)
            appDeledate.revealViewController?.setRight(rightViewController, animated: false)
            
            appDeledate.window?.rootViewController = appDeledate.revealViewController
        } else {
            let storyBoard = UIStoryboard(name: "Signup", bundle: nil)
            let loginvc = storyBoard.instantiateViewController(withIdentifier: "loginNavVC")
            appDeledate.window?.rootViewController = loginvc
        }
        appDeledate.window?.makeKeyAndVisible()
    }
    
    private func getCurrentUser() -> User? {
        if let userString = UserDefaults.standard.string(forKey: "user_info") {
            return User(JSONString: userString)
        }
        return nil
    }
    
    
    private func setCurrentUser(user: User?) {
        if let _user = user {
            UserDefaults.standard.set(_user.toJSONString(), forKey: "user_info")
        } else {
            UserDefaults.standard.set(nil, forKey: "user_info")
        }
    }
    
    
    init() {
        
    }
}

class User: Mappable {
    var walletName: String?
    var accountName: String?
    var password: String?
    
    required init?(map: Map) {
        
    }
    
    init() {
        
    }
    
    func mapping(map: Map) {
        walletName <- map["walletName"]
        accountName <- map["accountName"]
        password <- map["password"]
    }
}


class SettingsManager {
    private static let instance = SettingsManager()
    
    class func sharedInstance() -> SettingsManager {
        return self.instance
    }
    
    var baseUrl: String? {
        get {
            return self.getBaseUrl()
        }
        set {
            self.setBaseUrlWith(newValue)
        }
    }
    
    private func getBaseUrl() -> String? {
        if let baseUrl = UserDefaults.standard.string(forKey: "base_url") {
            return baseUrl
        }
        return nil
    }
    
    private func setBaseUrlWith(_ url: String?) {
        if let _url = url {
            UserDefaults.standard.set(_url, forKey: "base_url")
        } else {
            UserDefaults.standard.set(nil, forKey: "base_url")
        }
    }
}
