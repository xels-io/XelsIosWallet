//
//  APIClient.swift
//  XELS
//
//  Created by iMac on 31/12/18.
//  Copyright © 2018 Silicon Orchard Ltd. All rights reserved.
//

import Foundation
import Alamofire
import ObjectMapper
import AlamofireObjectMapper
import SwiftyJSON

class APIClient {
    
    
    static func login(param: [String: Any], completion: @escaping (Result<LoginResponse>, Int?, Data?) -> Void) {
        Alamofire.request(BaseURL.postURL, method: .post, parameters: param, encoding: URLEncoding.queryString, headers: nil)
            .responseObject { (response: DataResponse<LoginResponse>) in
                completion(response.result, response.response?.statusCode, response.data)
        }
    }
    
    
    
    static func getMnemonics(param: [String: Any], completion: @escaping (Result<MnemonicResponse>, Int?, Data?) -> Void) {
        Alamofire.request(BaseURL.getURL, method: .get, parameters: param, encoding: URLEncoding.default, headers: nil)
            .responseObject { (response: DataResponse<MnemonicResponse>) in
                completion(response.result, response.response?.statusCode, response.data)
        }
    }
    
    
    
    static func createAccount(param: [String: Any], completion: @escaping (Result<MnemonicResponse>, Int?, Data?) -> Void) {
        Alamofire.request(BaseURL.postURL, method: .post, parameters: param, encoding: URLEncoding.queryString, headers: nil)
            .responseObject { (response: DataResponse<MnemonicResponse>) in
                completion(response.result, response.response?.statusCode, response.data)
        }
    }
    
    
    
    static func restore(param: [String: Any], completion: @escaping (Result<RestoreResponse>, Int?, Data?) -> Void) {
        Alamofire.request(BaseURL.postURL, method: .post, parameters: param, encoding: URLEncoding.queryString, headers: nil)
            .responseObject { (response: DataResponse<RestoreResponse>) in
                completion(response.result, response.response?.statusCode, response.data)
        }
    }
    
    
    
    static func getBalance(param: [String: Any], completion: @escaping(Result<BalanceResponse>, Int?, Data?) -> Void) {
        
        Alamofire.request(BaseURL.getURL, method: .get, parameters: param, encoding: URLEncoding.default, headers: nil).responseObject { (response: DataResponse<BalanceResponse>) in
            completion(response.result, response.response?.statusCode, response.data)
        }
    }
    
    
    
    static func getStakingInfo(param: [String: Any], completion: @escaping(Result<StakingInfoResponse>, Int?, Data?) -> Void) {
        
        Alamofire.request(BaseURL.getURL, method: .get, parameters: param, encoding: URLEncoding.default, headers: nil).responseObject { (response: DataResponse<StakingInfoResponse>) in
            completion(response.result, response.response?.statusCode, response.data)
        }
    }
    
    
    
    static func getTransactionHistory(param: [String: Any], completion: @escaping(Result<LatestTransactionResponse>, Int?, Data?) -> Void) {
        Alamofire.request(BaseURL.getURL, method: .get, parameters: param, encoding: URLEncoding.default, headers: nil).responseObject { (response: DataResponse<LatestTransactionResponse>) in
            completion(response.result, response.response?.statusCode, response.data)
        }
    }
    
    
    
    static func getTransactionFee(param: [String: Any] , completion: @escaping(Result<TransactionFeeResponse>, Int?, Data?) -> Void) {
        Alamofire.request(BaseURL.getURL, method: .get, parameters: param, encoding: URLEncoding.default, headers: nil)
            .responseObject(completionHandler: { (response: DataResponse<TransactionFeeResponse>) in
                completion(response.result, response.response?.statusCode, response.data)
            })
    }
    
    
    
    static func build(param: [String: Any], completion: @escaping (Result<BuildResponse>, Int?, Data?) -> Void) {
        Alamofire.request(BaseURL.postURL, method: .post, parameters: param, encoding: URLEncoding.queryString, headers: nil)
            .responseObject(completionHandler: { (response: DataResponse<BuildResponse>) in
                completion(response.result, response.response?.statusCode, response.data)
            })        
    }
    
    static func send(param: [String: Any], completion: @escaping (Result<SendResponse>, Int?, Data?) -> Void) {
        Alamofire.request(BaseURL.postURL, method: .post, parameters: param, encoding: URLEncoding.queryString, headers: nil)
            .responseObject(completionHandler: { (response: DataResponse<SendResponse>) in
                completion(response.result, response.response?.statusCode, response.data)
            })
    }
    
    
    
    static func getUnUsedAddress(param: [String:Any], completion: @escaping(Result<UnusedAddressRespnse>, Int?, Data?) -> Void) {
        Alamofire.request(BaseURL.getURL, method: .get, parameters: param, encoding: URLEncoding.default, headers: nil)
            .responseObject(completionHandler: { (response: DataResponse<UnusedAddressRespnse>) in
                completion(response.result, response.response?.statusCode, response.data)
            })
    }
    
    
    static func stopStaking(param: [String: Any], completion: @escaping(Result<LoginResponse>, Int?, Data?) -> Void) {
        Alamofire.request(BaseURL.postURL, method: .post, parameters: param, encoding: URLEncoding.queryString, headers: nil)
            .responseObject { (response: DataResponse<LoginResponse>) in
                completion(response.result, response.response?.statusCode, response.data)
        }
    }
    
    
    //MARK: - TEST METHODS
    
    static func testPost() {
        let para = ["URL": "/api/wallet/load/",
                    "folderPath": "null",
                    "name": "Server",
                    "password": "123"]
        
        
        Alamofire.request("http://192.168.0.30:4000/PostAPIResponse", method: .post, parameters: para, encoding: URLEncoding.queryString)
            
            .responseString { (response) in
                print("responseString: \(response)")
            }
            .responseJSON { (response) in
                print("responseJSON: \(response)")
            }
    }
    
    static func testGet(param: [String: Any]) {
        Alamofire.request(BaseURL.getURL, method: .get, parameters: param, encoding: URLEncoding.default, headers: nil).responseJSON { (response) in
            print(response)
        }
    }
    
}


