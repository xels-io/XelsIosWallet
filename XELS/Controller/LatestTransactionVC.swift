//
//  LatestTransactionVC.swift
//  XELS
//
//  Created by iMac on 4/1/19.
//  Copyright © 2019 Silicon Orchard Ltd. All rights reserved.
//

import UIKit
import PKHUD

class LatestTransactionVC: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var transactionTableView: UITableView!
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    var transactions = [Transaction]()
    
    let sessionManager = SessionManager.sharedInstance()
    var loggedInUser: User?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupMenu()
        setLoggedInUser()
        initiateCell()
        getTransactions()
    }
    
    
    //MARK: - SETUP
    func setLoggedInUser() {
        self.loggedInUser = sessionManager.currentUser
    }
    
    func setupMenu() {
        if revealViewController() != nil {
            menuButton.target = revealViewController()
            menuButton.action = "rightRevealToggle:"
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
    }
    
    
    func setupUI() {
        self.navigationController?.navigationBar.barTintColor = UIColor.templateGreen
    }
    
    
    func initiateCell() {
        transactionTableView.register(UINib(nibName: "TransactionTVCell", bundle: nil), forCellReuseIdentifier: "transactionTVCell")
        transactionTableView.delegate = self
        transactionTableView.dataSource = self
    }
    
    //MARK: - API CALL
    func getTransactions() {
        guard let user = self.loggedInUser, let walletName = user.walletName, let accountName = user.accountName else {
            HUD.flash(.label("Sorry!, could not find current user."), delay: 0.2)
            sessionManager.setAppropriateVC()
            return
        }
        
        let param = [Parameter.url: "/api/wallet/history",
                     Parameter.walletName: walletName,
                     Parameter.accountName: accountName] as [String: Any]
        HUD.show(.progress)
        APIClient.getTransactionHistory(param: param) { (result, code, data) in
            switch result {
            case .success(let transactionHistoryResponse):
                guard let statusCode = transactionHistoryResponse.statusCode else {
                    HUD.flash(.label("Something went wrong!"), delay: 0.2)
                    return
                }
                if statusCode == 200 {
                    guard let responseData = transactionHistoryResponse.responseData, let histories = responseData.histories, let firstHistory = histories.first, let transactions = firstHistory.transactions else{
                        HUD.flash(.label("Sorry, balance not found"), delay: 0.2)
                        return
                    }
                    HUD.flash(.success)
                    self.transactions = transactions
                    self.transactionTableView.reloadData()
                } else {
                    if let errors = transactionHistoryResponse.errors, let error = errors.first {
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
                HUD.flash(.error)
                break
            }
        }
    }
    
    
    //MARK: - TABLEVIEW METHODS
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return transactions.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "transactionTVCell", for: indexPath) as! TransactionTVCell
        let transactionData = transactions[indexPath.row]
        
        if let type = transactionData.type {
            if type == "staked"{
                cell.statusIV?.image = UIImage(named: "stake_icon")
            } else {
                cell.statusIV.image = UIImage(named: "receive_selected")
            }
        }
        if let amount = transactionData.amount {
            cell.amountLabel.text = satosiToXels(value: amount).description//"\(Double(amount)/Constant.satosi) XELS"
        }
        if let date = transactionData.timestamp {
            cell.dateLabel.text = getDateFor(unixtimeInterval: Double(date) ?? 0)
        }
        if let address = transactionData.toAddress {
            cell.addressLabel.text = address
        }
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 115.0
    }
    
    
    //MARK: - CUSTOM METHODS
    func satosiToXels(value: Int)->NSDecimalNumber {
        let object = ["numberone" : "\(value)", "numbertwo" : "\(Constant.satosi)"]
        let firstnumber: NSDecimalNumber =  NSDecimalNumber(string: object["numberone"])
        let secondnumber: NSDecimalNumber =  NSDecimalNumber(string: object["numbertwo"])
        let calculated: NSDecimalNumber = firstnumber.dividing(by: secondnumber)
        return calculated
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
