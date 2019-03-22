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
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        
        if self.currentUser != nil {
            let frontViewController =  storyBoard.instantiateViewController(withIdentifier: "dashboardNav")
            let rightViewController = storyBoard.instantiateViewController(withIdentifier: "menuVC")
            
            appDeledate.revealViewController = SWRevealViewController()
            appDeledate.revealViewController?.setFront(frontViewController, animated: false)
            appDeledate.revealViewController?.setRight(rightViewController, animated: false)
            
            appDeledate.window?.rootViewController = appDeledate.revealViewController
        } else {
            let loginvc = storyBoard.instantiateViewController(withIdentifier: "loginNav")
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
