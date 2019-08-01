//
//  AddressesVC.swift
//  XELS
//
//  Created by iMac on 2/4/19.
//  Copyright © 2019 Silicon Orchard Ltd. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import PKHUD

class AddressesVC: UIViewController {
    
    @IBOutlet weak var addresseTableView: UITableView!
    
    var itemInfo = IndicatorInfo(title: "View")
    var addresses = [Address]()
    var usedAddresses = [Address]()
    var unUsedAddresses = [Address]()
    var changedAddresses = [Address]()
    
    let sessionManager = SessionManager.sharedInstance()
    var loggedInUser: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setLoggedInUser()
        setupTableView()
        getAllAddresses()
    }
    
    //MARK: -  SETUP
    func setupTableView() {
        self.addresseTableView.delegate = self
        self.addresseTableView.dataSource = self
        self.addresseTableView.tableFooterView = UIView(frame: CGRect.zero)
        self.addresseTableView.register(UINib(nibName: "AddressTableViewCell", bundle: nil), forCellReuseIdentifier: "AddressTableViewCell")
    }
    
    
    func setLoggedInUser() {
        self.loggedInUser = sessionManager.currentUser
    }
    
    //MARK: - API CALL
    func getAllAddresses() {
        guard let user = self.loggedInUser, let walletName = user.walletName, let accountName = user.accountName else {
            HUD.flash(.label("Sorry!, could not find current user."), delay: 0.2)
            sessionManager.setAppropriateVC()
            return
        }
        
        let param = [
            Parameter.url: "/api/wallet/addresses",
            Parameter.walletName: walletName,
            Parameter.accountName: accountName
        ] as [String: Any]
        
        HUD.show(.progress)
        APIClient.getAllAddresses(param: param) { (result, code, data) in
            switch result {
            case .success(let addressesResponse):
                guard let statusCode = addressesResponse.statusCode else {
                    HUD.flash(.label("Something went wrong!"), delay: 0.2)
                    return
                }
                if statusCode == 200 {
                    guard let addresses = addressesResponse.addresses else {
                        HUD.flash(.label("Sorry, address not found"), delay: 0.2)
                        return
                    }
                    HUD.flash(.success)
                    self.populateTableWith(addresses: addresses)
                } else {
                    if let errors = addressesResponse.errors, let error = errors.first {
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
    func populateTableWith(addresses: [Address]) {
        addresses.forEach { (address) in
            print("Add: \(address.address!) Used: \(address.isUser) Changed: \(address.isChange)")
            if let isUsed = address.isUser, let isChanged = address.isChange {
                if isUsed {
                    usedAddresses.append(address)
                } else {
                    unUsedAddresses.append(address)
                }
                if isChanged {
                    changedAddresses.append(address)
                }
            }
        }
        self.reloadTableView()
    }
    
    func reloadTableView() {
        if itemInfo.title == Constant.used {
            self.addresses = usedAddresses
        }
        if itemInfo.title == Constant.unused {
            self.addresses = unUsedAddresses
        }
        if itemInfo.title == Constant.changed {
            self.addresses = changedAddresses
        }
        self.addresseTableView.reloadData()
    }
    
    
    func handleQrCodeWith(_ address: Address) {
        guard let addressString = address.address else {
            return
        }
        let qrCodeView = QRCodeView()
        qrCodeView.show(frame: UIScreen.main.bounds,addressString: addressString)
    }
    
    
    func handleShareActionWith(_ address: Address) {
        guard let addressString = address.address else {
            return
        }
        
        // set up activity view controller
        let textToShare = [addressString]
        let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    
    func handleCopyActionWith(_ address: Address) {
        if let addressString = address.address {
            let pasteboard = UIPasteboard.general
            pasteboard.string = addressString
            HUD.flash(.label("Copied"), delay: 0.3)
        } else {
            HUD.flash(.label("Nothing to copy!"), delay: 0.3)
        }
    }
}


extension AddressesVC: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return addresses.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = addresseTableView.dequeueReusableCell(withIdentifier: "AddressTableViewCell", for: indexPath) as! AddressTableViewCell
        let address = addresses[indexPath.row]
        if let addressString = address.address {
            cell.configCellWith(address: addressString)
        }
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let currentCell = tableView.cellForRow(at: indexPath)
        let address = addresses[indexPath.row]
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        let qrCodeAction = UIAlertAction(title: "QR Code", style: .default) { (action) in
            self.handleQrCodeWith(address)
        }
        let shareAction = UIAlertAction(title: "Share", style: .default) { (action) in
            self.handleShareActionWith(address)
        }
        let copyAction = UIAlertAction(title: "Copy", style: .default) { (action) in
            self.handleCopyActionWith(address)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {(alert: UIAlertAction!) in print("cancel")})

        qrCodeAction.setValue(UIColor.black, forKey: "titleTextColor")
        shareAction.setValue(UIColor.black, forKey: "titleTextColor")
        copyAction.setValue(UIColor.black, forKey: "titleTextColor")
        cancelAction.setValue(UIColor.black, forKey: "titleTextColor")

        alertController.addAction(qrCodeAction)
        alertController.addAction(shareAction)
        alertController.addAction(copyAction)
        alertController.addAction(cancelAction)

        switch UIDevice.current.userInterfaceIdiom {
        case .pad:
            alertController.popoverPresentationController?.sourceView = currentCell
            alertController.popoverPresentationController?.sourceRect = (currentCell?.bounds)!
            alertController.popoverPresentationController?.permittedArrowDirections = .up
        default:
            break
        }

        DispatchQueue.main.async {
            self.present(alertController, animated: true, completion:{})
        }
        
    }
    
}


extension AddressesVC: IndicatorInfoProvider {
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }
}

