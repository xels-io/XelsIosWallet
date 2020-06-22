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
    @IBOutlet weak var historyTableView: UITableView!
    
    var confirmedBalance = "0"
    var unconfirmedBalance = "0"
    var weight = "0"
    var networkWeight = "0"
    var rewardTime = "Unknown"
    
    let sessionManager = SessionManager.sharedInstance()
    var loggedInUser: User?
    
    var transactions = [Transaction]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupUI()
        setLoggedInUser()
        setupMenu()
        getBalance()
        getTransactions()
    }
    
    
    //MARK: - SETUP
    func setupTableView() {
        historyTableView.delegate = self
        historyTableView.dataSource = self
        historyTableView.register(UINib(nibName: "TransactionTVCell", bundle: nil), forCellReuseIdentifier: "transactionTVCell")
        historyTableView.tableFooterView = UIView(frame: CGRect.zero)
    }
    
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
    
    
    //MARK: - BUTTON ACTION
    
    @IBAction func receiveButtonTapped(_ sender: Any) {
        let appDeledate = UIApplication.shared.delegate as! AppDelegate
        let revealViewController = appDeledate.revealViewController
        let receiveVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "receiveNav")
        if let revealVC = revealViewController, let menuVC = revealVC.rightViewController as? MenuVC, let tableView = menuVC.menuTableView {
            tableView.reloadData()
        }
        revealViewController!.pushFrontViewController(receiveVC, animated: true)
    }
    
    @IBAction func sendButtonTapped(_ sender: Any) {
        let appDeledate = UIApplication.shared.delegate as! AppDelegate
        let revealViewController = appDeledate.revealViewController
        let sendVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "sendNav")
        if let revealVC = revealViewController, let menuVC = revealVC.rightViewController as? MenuVC, let tableView = menuVC.menuTableView {
            tableView.reloadData()
        }
        revealViewController!.pushFrontViewController(sendVC, animated: true)
    }
    
    @IBAction func viewFullHistoryButtonTapped(_ sender: Any) {
        let appDeledate = UIApplication.shared.delegate as! AppDelegate
        let revealViewController = appDeledate.revealViewController
        let latestTransactionVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "latestTransactionNav")
        if let revealVC = revealViewController, let menuVC = revealVC.rightViewController as? MenuVC, let tableView = menuVC.menuTableView {
            tableView.reloadData()
        }
        revealViewController!.pushFrontViewController(latestTransactionVC, animated: true)
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
                    HUD.flash(.success, delay: 0.1, completion:{ (_) in
                        self.updateBalance(balance: balance)
                        //self.getStakingInfo()
                        return
                    })
                    
                    
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
                    let _weight = self.getUpdated(value: weight, dividedBy: Constant.satosi)
                    let _netWeight = self.getUpdated(value: netWeight, dividedBy: Constant.satosi)
                    self.weight = "\(_weight)"
                    self.networkWeight = "\(_netWeight)"
                    if rewardTime < 0 {
                        self.rewardTime = "1"
                    } else {
                        self.rewardTime = "\(rewardTime/60)"
                    }
                    HUD.flash(.success, delay: 0.1, completion:{ (_) in
                        //self.setAttributedTextWith(confirmedBalance: self.confirmedBalance, unconfirmedBalance: self.unconfirmedBalance, weight: self.weight, networkWeight: self.networkWeight, rewardTime: self.rewardTime)
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
    
    func getTransactions() {
        guard let user = self.loggedInUser, let walletName = user.walletName, let accountName = user.accountName else {
            HUD.flash(.label("Sorry!, could not find current user."), delay: 0.2)
            sessionManager.setAppropriateVC()
            return
        }
        
        let param = [Parameter.url: "/api/wallet/history",
                     Parameter.walletName: walletName,
                     Parameter.accountName: accountName] as [String: Any]
        //HUD.show(.progress)
        APIClient.getTransactionHistory(param: param) { (result, code, data) in
            switch result {
            case .success(let transactionHistoryResponse):
                guard let statusCode = transactionHistoryResponse.statusCode else {
                    //HUD.flash(.label("Something went wrong!"), delay: 0.2)
                    return
                }
                if statusCode == 200 {
                    guard let responseData = transactionHistoryResponse.responseData, let histories = responseData.histories, let firstHistory = histories.first, let transactions = firstHistory.transactions else{
                        //HUD.flash(.label("Sorry, balance not found"), delay: 0.2)
                        return
                    }
                    //HUD.flash(.success)
                    self.transactions = transactions
                    self.historyTableView.reloadData()
                } else {
                    if let errors = transactionHistoryResponse.errors, let error = errors.first {
                        guard let message = error.message else {
                            //HUD.flash(.label("Something went wrong!"), delay: 0.2)
                            return
                        }
                        //HUD.flash(.label(message), delay: 0.2)
                        return
                    }
                    //HUD.flash(.label("Something went wrong!"), delay: 0.2)
                }
                break
            case .failure:
                HUD.flash(.error)
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
    
    func getUpdated(value: Int, dividedBy secondValue: Double) -> NSDecimalNumber {
        let object = ["numberone" : "\(value)", "numbertwo" : "\(secondValue)"]
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
        self.setAttributedTextWith(confirmedBalance: self.confirmedBalance, unconfirmedBalance: self.unconfirmedBalance)
    }
    
    
    func setAttributedTextWith(confirmedBalance: String, unconfirmedBalance: String) {
        let combination = NSMutableAttributedString()
        
        let bold24 = UIFont(name: "Roboto-Bold", size: 24) ?? UIFont.boldSystemFont(ofSize: 24)
        let normal24 = UIFont(name: "Roboto-Regular", size: 24) ?? UIFont.systemFont(ofSize: 24)
        let normal20 = UIFont(name: "Roboto-Regular", size: 20) ?? UIFont.systemFont(ofSize: 20)
        let normal11 = UIFont(name: "Roboto-Regular", size: 11) ?? UIFont.systemFont(ofSize: 11)
        let normal18 = UIFont(name: "Roboto-Regular", size: 18) ?? UIFont.systemFont(ofSize: 18)
        let bold18 = UIFont(name: "Roboto-Bold", size: 20) ?? UIFont.boldSystemFont(ofSize: 20)
        
        combination.append(getAttributedString(firstTxt: "AVAILABLE BALANCE", secondTxt: "\n\n", font1: bold24, font2: bold24))
        combination.append(getAttributedString(firstTxt: confirmedBalance, secondTxt: " XELS\n", font1: normal24, font2: normal20))
        combination.append(getAttributedString(firstTxt: unconfirmedBalance, secondTxt: " (unconfirmed)", font1: normal20, font2: normal18))
//        combination.append(getAttributedString(firstTxt: "Your weight is\n", secondTxt: " \(weight) XELS\n", font1: normal18, font2: bold18))
//        combination.append(getAttributedString(firstTxt: "Network weight is\n", secondTxt: " \(networkWeight) XELS\n\n", font1: normal18, font2: bold18))
//        combination.append(getAttributedString(firstTxt: "Expected reward time is:\n", secondTxt: "\(rewardTime)\n\n\n\n\n", font1: normal18, font2: bold18))
        
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


extension DashboardVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if transactions.count < 6 {
            return transactions.count
        }
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "transactionTVCell", for: indexPath) as! TransactionTVCell
        let transactionData = transactions[indexPath.row]
        
        if let type = transactionData.type {
            if type == "send" {
                cell.statusLabel.text = "To"
                cell.statusIV?.image = UIImage(named: "send_selected")
                if let payments = transactionData.payments {
                    if payments.count > 0 {
                        if let address = payments[0].destinationAddress {
                            cell.addressLabel.text = address
                        }
                    }
                }
                if let _confirmedBlock = transactionData.confirmedInBlock {
                    if _confirmedBlock > 0 {
                        cell.statusIV.image = UIImage(named: "send_selected")
                    } else {
                        cell.statusIV.image = UIImage(named: "send_icon_yellow")
                    }
                } else {
                    cell.statusIV.image = UIImage(named: "send_icon_yellow")
                }
            }else if type == "received"{
                cell.statusLabel.text = "From"
                cell.statusIV?.image = UIImage(named: "receive_selected")
                if let address = transactionData.toAddress {
                    cell.addressLabel.text = address
                }
                if let _confirmedBlock = transactionData.confirmedInBlock {
                    if _confirmedBlock > 0 {
                        cell.statusIV.image = UIImage(named: "receive_selected")
                    } else {
                        cell.statusIV.image = UIImage(named: "receive_icon_yellow")
                    }
                } else {
                    cell.statusIV.image = UIImage(named: "receive_icon_yellow")
                }
                
            } else if type == "staked" {
                cell.statusLabel.text = "Hybrid Reward"
                cell.statusIV?.image = UIImage(named: "stake_icon")
                if let address = transactionData.toAddress {
                    cell.addressLabel.text = address
                }
                if let _confirmedBlock = transactionData.confirmedInBlock {
                    if _confirmedBlock > 0 {
                        cell.statusIV.image = UIImage(named: "stake_icon")
                    } else {
                        cell.statusIV.image = UIImage(named: "stake_icon_yellow")
                    }
                } else {
                    cell.statusIV.image = UIImage(named: "stake_icon_yellow")
                }
            }
            
            else if type == "mined" {
                cell.statusLabel.text = "PoW Reward"
                cell.statusIV?.image = UIImage(named: "stake_icon")
                if let address = transactionData.toAddress {
                    cell.addressLabel.text = address
                }
                if let _confirmedBlock = transactionData.confirmedInBlock {
                    if _confirmedBlock > 0 {
                        cell.statusIV.image = UIImage(named: "stake_icon")
                    } else {
                        cell.statusIV.image = UIImage(named: "stake_icon_yellow")
                    }
                } else {
                    cell.statusIV.image = UIImage(named: "stake_icon_yellow")
                }
            }
        }
        if let amount = transactionData.amount {
            cell.amountLabel.text = satosiToXels(value: amount).description//"\(Double(amount)/Constant.satosi) XELS"
        }
        if let date = transactionData.timestamp {
            cell.dateLabel.text = getDateFor(unixtimeInterval: Double(date) ?? 0)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 115
    }
    
    func getDateFor(unixtimeInterval: TimeInterval) -> String{
        let date = Date(timeIntervalSince1970: unixtimeInterval)
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT")
        dateFormatter.locale = NSLocale.current
        dateFormatter.dateFormat = "MMM dd, yyyy, HH:mm:ss a"
        let strDate = dateFormatter.string(from: date)
        return strDate
    }
}
