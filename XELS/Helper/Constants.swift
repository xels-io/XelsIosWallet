//
//  Constants.swift
//  XELS
//
//  Created by iMac on 31/12/18.
//  Copyright © 2018 Silicon Orchard Ltd. All rights reserved.
//

import Foundation

struct BaseURL {
//    static let getURL = "http://192.168.0.30:4000/GetAPIResponse"
//    static let postURL = "http://192.168.0.30:4000/PostAPIResponse"
    
//    static let getURL = "http://13.115.162.46:4000/GetAPIResponse"
//    static let postURL = "http://13.115.162.46:4000/PostAPIResponse"

//    static let getURL = "http://13.115.56.41:4000/GetAPIResponse"
//    static let postURL = "http://13.115.56.41:4000/PostAPIResponse"
    
//    static let getURL = "http://54.238.248.117:4000/GetAPIResponse"
//    static let postURL = "http://54.238.248.117:4000/PostAPIResponse"
    
//    static let getURL = "http://52.68.239.4:4000/GetAPIResponse"
//    static let postURL = "http://52.68.239.4:4000/PostAPIResponse"
    
//    static let getURL = "https://api.xels.io:2332/GetAPIResponse"
//    static let postURL = "https://api.xels.io:2332/PostAPIResponse"

    static let baseUrl = "https://api.xels.io:2332"
    static let getURL = "\(BaseURL.getBaseUrl())/GetAPIResponse"
    static let postURL = "\(BaseURL.getBaseUrl())/PostAPIResponse"
    
    static func getBaseUrl() -> String {
        let settingsManager = SettingsManager.sharedInstance()
        if let baseUrlString = settingsManager.baseUrl {
            return baseUrlString
        } else {
            return ""
        }
    }
}

struct Parameter {
    static let url = "URL"
    static let folderPath = "folderPath"
    static let name = "name"
    static let password = "password"
    static let passphrase = "passphrase"
    static let walletName = "walletName"
    static let accountName = "accountName"
    static let destinationAddress = "recipients[0].[destinationAddress]"
    static let amount = "recipients[0].[amount]"
    static let rawDestinationAddress = "destinationAddress"
    static let rawAmount = "amount"
    static let feeType = "feeType"
    static let allowUnconfirmed = "allowUnconfirmed"
    static let feeAmount = "feeAmount"
    static let shuffleOutputs = "shuffleOutputs"
    static let recipients = "recipients"
    static let hex = "hex"
    static let creationDate = "creationDate"
    static let mnemonic = "mnemonic"
    static let language = "language"
    static let wordCount = "wordCount"
    
}

struct Constant{
    static let mainGetURL = "http://13.115.56.41:4000/GetAPIResponse" // used in dashboardVC and sendVC
    static let mainPostURL = "http://13.115.56.41:4000/PostAPIResponse"
    static let satosi:Double = 100000000;
    
    static let used: String = "Used"
    static let unused: String = "Unused"
    static let changed: String = "Changed"
    
    static let passWordRegEx: String = #"^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$"#
    static let emaiRegEx: String = "[A-Z0-9a-z.-_]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,3}"
    
    static let appBackgroundStatusNotKey = "com.xels.backgrondNotKey"
}

