//
//  DashboardVC.swift
//  XELS
//
//  Created by iMac on 31/12/18.
//  Copyright © 2018 Silicon Orchard Ltd. All rights reserved.
//

import UIKit
import PKHUD

class DashboardVC: UIViewController {
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var statusLabel: UILabel!
    
    var confirmedBalance = "0"
    var unconfirmedBalance = "0"
    var weight = "0"
    var networkWeight = "0"
    var rewardTime = "Unknown"
    
    let sessionManager = SessionManager.sharedInstance()
    var loggedInUser: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setLoggedInUser()
        setupMenu()
        getBalance()
    }
    
    
    //MARK: - SETUP
    func setupUI() {
        self.navigationController?.navigationBar.barTintColor = UIColor.templateGreen
    }
    
    func setupMenu() {
        if revealViewController() != nil {
            menuButton.target = revealViewController()
            menuButton.action = "rightRevealToggle:"
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
    }
    
    func setLoggedInUser() {
        self.loggedInUser = sessionManager.currentUser
    }
    
    
    //MARK: - API CALL
    func getBalance() {
        guard let user = self.loggedInUser, let walletName = user.walletName, let accountName = user.accountName else {
            HUD.flash(.label("Sorry!, could not find current user."), delay: 0.2)
            sessionManager.setAppropriateVC()
            return
        }
        
        let param = [Parameter.url: "/api/wallet/balance", Parameter.walletName: walletName, Parameter.accountName: accountName] as [String: Any]
        HUD.show(.progress)
        APIClient.getBalance(param: param) { (result, statusCode, data) in
            switch result {
            case .success(let balanceResponse):
                guard let statusCode = balanceResponse.statusCode else {
                    HUD.flash(.label("Something went wrong!"), delay: 0.2)
                    return
                }
                if statusCode == 200 {
                    guard let responseData = balanceResponse.responseData, let balances = responseData.balances, let balance = balances.first else{
                        HUD.flash(.label("Sorry, balance not found"), delay: 0.2)
                        return
                    }
                    self.updateBalance(balance: balance)
                    self.getStakingInfo()
                    return
                } else {
                    if let errors = balanceResponse.errors, let error = errors.first {
                        guard let message = error.message else {
                            HUD.flash(.label("Something went wrong!"), delay: 0.2)
                            return
                        }
                        HUD.flash(.label(message), delay: 0.2)
                        return
                    }
                    HUD.flash(.label("Something went wrong!"), delay: 0.2)
                }
                break
            case .failure:
                HUD.flash(.label("Something went wrong!"), delay: 0.2)
                break
            }
        }
    }
    
    func getStakingUrl() -> String {
        if BaseURL.getURL == Constant.mainGetURL {
            return "/api/miner/getstakinginfo"
        }
        return "/api/staking/getstakinginfo"
    }
    
    func getStakingInfo(){
        let param = [Parameter.url: getStakingUrl()] as [String: Any]
        APIClient.getStakingInfo(param: param) { (result, statusCode, data) in
            switch result {
            case .success(let stakingInfoResonse):
                guard let statusCode = stakingInfoResonse.statusCode else {
                    HUD.flash(.label("Something went wrong!"), delay: 0.2)
                    return
                }
                if statusCode == 200 {
                    guard let responseData = stakingInfoResonse.responseData, let weight = responseData.weight, let netWeight = responseData.netStakeWeight, let rewardTime = responseData.expectedTime else {
                        HUD.flash(.label("Sorry, Data not found"), delay: 0.2)
                        return
                    }
                    self.weight = "\(weight)"
                    self.networkWeight = "\(netWeight)"
                    self.rewardTime = "\(rewardTime)"
                    HUD.flash(.success, delay: 0.1, completion:{ (_) in
                        self.setAttributedTextWith(confirmedBalance: self.confirmedBalance, unconfirmedBalance: self.unconfirmedBalance, weight: self.weight, networkWeight: self.networkWeight, rewardTime: self.rewardTime)
                        return
                    })
                } else {
                    if let errors = stakingInfoResonse.errors, let error = errors.first {
                        guard let message = error.message else {
                            HUD.flash(.label("Something went wrong!"), delay: 0.2)
                            return
                        }
                        HUD.flash(.label(message), delay: 0.2)
                        return
                    }
                    HUD.flash(.label("Something went wrong!"), delay: 0.2)
                }
                break
            case .failure:
                HUD.flash(.label("Something went wrong!"), delay: 0.2)
                break
            }
        }
    }
    
    
    //MARK: - CUSTOM METHODS
    func satosiToXels(value: Int)->NSDecimalNumber {
        let object = ["numberone" : "\(value)", "numbertwo" : "\(Constant.satosi)"]
        let firstnumber: NSDecimalNumber =  NSDecimalNumber(string: object["numberone"])
        let secondnumber: NSDecimalNumber =  NSDecimalNumber(string: object["numbertwo"])
        let calculated: NSDecimalNumber = firstnumber.dividing(by: secondnumber)
        return calculated
    }
    
    func updateBalance(balance: Balance) {
        if let confirmed = balance.amountConfirmed{
            confirmedBalance = satosiToXels(value: confirmed).description
        }
        if let unconfirmed = balance.amountUnconfirmed {
            unconfirmedBalance = satosiToXels(value: unconfirmed).description
        }
        self.setAttributedTextWith(confirmedBalance: self.confirmedBalance, unconfirmedBalance: self.unconfirmedBalance, weight: self.weight, networkWeight: self.networkWeight, rewardTime: self.rewardTime)
    }
    
    
    func setAttributedTextWith(confirmedBalance: String, unconfirmedBalance: String, weight: String, networkWeight: String, rewardTime: String) {
        let combination = NSMutableAttributedString()
        
        let bold24 = UIFont(name: "Roboto-Bold", size: 24) ?? UIFont.boldSystemFont(ofSize: 24)
        let normal20 = UIFont(name: "Roboto-Regular", size: 20) ?? UIFont.systemFont(ofSize: 20)
        let normal14 = UIFont(name: "Roboto-Regular", size: 14) ?? UIFont.systemFont(ofSize: 14)
        let normal11 = UIFont(name: "Roboto-Regular", size: 11) ?? UIFont.systemFont(ofSize: 11)
        let normal18 = UIFont(name: "Roboto-Regular", size: 18) ?? UIFont.systemFont(ofSize: 18)
        let bold18 = UIFont(name: "Roboto-Bold", size: 20) ?? UIFont.boldSystemFont(ofSize: 20)
        
        combination.append(getAttributedString(firstTxt: "AVAILABLE BALANCE", secondTxt: "\n\n\n", font1: bold24, font2: bold24))
        combination.append(getAttributedString(firstTxt: confirmedBalance, secondTxt: " XELS\n\n", font1: normal20, font2: normal14))
        combination.append(getAttributedString(firstTxt: unconfirmedBalance, secondTxt: " (unconfirmed)\n\n\n", font1: normal14, font2: normal11))
        combination.append(getAttributedString(firstTxt: "Your weight is\n", secondTxt: " \(weight) XELS\n", font1: normal18, font2: bold18))
        combination.append(getAttributedString(firstTxt: "Network weight is\n", secondTxt: " \(networkWeight) XELS\n\n", font1: normal18, font2: bold18))
        combination.append(getAttributedString(firstTxt: "Expected reward time is:\n", secondTxt: "\(rewardTime)\n\n\n\n\n", font1: normal18, font2: bold18))
        
        self.statusLabel.attributedText = combination
        self.statusLabel.textAlignment = .center
    }
    
    func getAttributedString(firstTxt: String, secondTxt: String, font1: UIFont, font2: UIFont) -> NSAttributedString {
        let mutableAttr = NSMutableAttributedString()
        mutableAttr.append(NSAttributedString(string: firstTxt, attributes: [ NSAttributedString.Key.font: font1]))
        mutableAttr.append(NSAttributedString(string: secondTxt, attributes: [NSAttributedString.Key.font: font2]))
        return mutableAttr
    }

}
