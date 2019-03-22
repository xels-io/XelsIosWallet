//
//  APIResponse.swift
//  XELS
//
//  Created by iMac on 31/12/18.
//  Copyright © 2018 Silicon Orchard Ltd. All rights reserved.
//

import Foundation
import ObjectMapper

class Error: Mappable {
    var status: Int?
    var message: String?
    var description: String?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        status <- map["status"]
        message <- map["message"]
        description <- map["description"]
    }
}

class BaseResponse: Mappable {
    var statusCode: Int?
    var statusText: String?
    var errors: [Error]?
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        statusCode <- map["statusCode"]
        statusText <- map["statusText"]
        errors <- map["InnerMsg"]
    }
}

class LoginResponse: BaseResponse {
    
    var responseData: String?
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        responseData <- map["InnerMsg"]
    }
}

class BalanceResponse: BaseResponse {
    var responseData: BalanceData?

    override func mapping(map: Map) {
        super.mapping(map: map)
        responseData <- map["InnerMsg"]
    }
}

class BalanceData: Mappable {
    var balances: [Balance]?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        balances <- map["balances"]
    }
}

class Balance: Mappable {
    var accountName : String?
    var accountHdPath: String?
    var coinType: Int?
    var amountConfirmed: Int?
    var amountUnconfirmed: Int?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        accountName <- map["accountName"]
        accountHdPath <- map["accountHdPath"]
        coinType <- map["coinType"]
        amountConfirmed <- map["amountConfirmed"]
        amountUnconfirmed <- map["amountUnconfirmed"]
    }
}

class StakingInfoResponse: BaseResponse {
    var responseData: StakingInfo?
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        responseData <- map["InnerMsg"]
    }
}

class StakingInfo: Mappable {
    var isEnabled: Bool?
    var isStaking: Bool?
    var errors: String?
    var currentBlockSize: Int?
    var currentBlockTx: Int?
    var pooledTx: Int?
    var difficulty: Int?
    var searchInterval: Int?
    var weight: Int?
    var netStakeWeight: Int?
    var expectedTime: Int?
    
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        isEnabled <- map["enabled"]
        isStaking <- map["staking"]
        errors <- map["errors"]
        currentBlockSize <- map["currentBlockSize"]
        currentBlockTx <- map["currentBlockTx"]
        pooledTx <- map["pooledTx"]
        difficulty <- map["difficulty"]
        searchInterval <- map["searchInterval"]
        weight <- map["weight"]
        netStakeWeight <- map["netStakeWeight"]
        expectedTime <- map["expectedTime"]
    }
}

class LatestTransactionResponse: BaseResponse {
    var responseData: HistoryData?
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        responseData <- map["InnerMsg"]
    }
}

class HistoryData: Mappable {
    var histories: [TransactionHistory]?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        histories <- map["history"]
    }
}

class TransactionHistory: Mappable {
    var accountName : String?
    var accountHdPath : String?
    var coinType : String?
    var transactions : [Transaction]?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        accountName <- map["accountName"]
        accountHdPath <- map["accountHdPath"]
        coinType <- map["coinType"]
        transactions <- map["transactionsHistory"]
    }
}

class Transaction: Mappable {
    var type : String?
    var toAddress : String?
    var id : String?
    var amount : Int?
    var payments : [Any]?
    var confirmedInBlock : Int?
    var timestamp : String?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        type <- map["type"]
        toAddress <- map["toAddress"]
        id <- map["id"]
        amount <- map["amount"]
        payments <- map["payments"]
        confirmedInBlock <- map["confirmedInBlock"]
        timestamp <- map["timestamp"]
    }
}

class TransactionFeeResponse: BaseResponse {
    var responseData: Int?
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        responseData <- map["InnerMsg"]
    }
}

class UnusedAddressRespnse: BaseResponse {
    var responseData: String?
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        responseData <- map["InnerMsg"]
    }
}


class BuildResponse: BaseResponse {
    
    var responseData: BuildResponseData?
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        responseData <- map["InnerMsg"]
    }
}

class BuildResponseData: Mappable {
    var fee: Float?
    var hex: String?
    var transactionId: String?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        fee <- map["fee"]
        hex <- map["hex"]
        transactionId <- map["transactionId"]
    }
}


class SendResponse: BaseResponse {
    var responseData: SendResponseData?
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        responseData <- map["InnerMsg"]
    }
}

class SendResponseData: Mappable {
    var transactionId: String?
    var outpouts: [SendOutput]?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        transactionId <- map["transactionId"]
        outpouts <- map["outpouts"]
    }
}


class SendOutput: Mappable {
    var address: String?
    var amount: Int?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        address <- map["address"]
        amount <- map["amount"]
    }
}


class RestoreResponse: BaseResponse {
    var responseData: String?
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        responseData <- map["InnerMsg"]
    }
}


class MnemonicResponse: BaseResponse {
    var responseData: String?
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        responseData <- map["InnerMsg"]
    }
}
