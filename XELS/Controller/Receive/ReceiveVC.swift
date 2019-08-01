//
//  ReceiveVC.swift
//  XELS
//
//  Created by iMac on 31/12/18.
//  Copyright © 2018 Silicon Orchard Ltd. All rights reserved.
//

import UIKit
import PKHUD

class ReceiveVC: UIViewController {

    @IBOutlet weak var qrCodeIV: UIImageView!
    @IBOutlet weak var addressContainerView: UIView!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var copyToClipboardContentView: UIView!
    @IBOutlet weak var copyToclipboardIV: UIImageView!
    @IBOutlet weak var copyToClipBoardButton: UIButton!
    @IBOutlet weak var showAllAddressesButton: UIButton!
    @IBOutlet weak var okButton: UIButton!
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    let sessionManager = SessionManager.sharedInstance()
    var loggedInUser: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupMenu()
        setLoggedInUser()
        getUnUsedAddress()
    }
    
    
    //MARK: - SETUP
    func setLoggedInUser() {
        self.loggedInUser = sessionManager.currentUser
    }
    
    
    func setupUI() {
        self.navigationController?.navigationBar.barTintColor = UIColor.templateGreen
        showAllAddressesButton.setTitleColor(UIColor.templateGreen, for: .normal)
        okButton.setTitleColor(UIColor.templateGreen, for: .normal)
        okButton.doCornerAndBorder(radius: 8.0, border: 3.0, color: UIColor.templateGreen.cgColor)
        addressContainerView.doCornerAndBorder(radius: 8.0, border: 1.5, color: UIColor.templateGreen.cgColor)
        copyToClipboardContentView.doCornerAndBorder(radius: 8.0, border: 1.0, color: UIColor.templateGreen.cgColor)
        copyToClipBoardButton.doCornerAndBorder(radius: 8.0, border: 1.0, color: UIColor.templateGreen.cgColor)
    }
    
    func setupMenu() {
        if revealViewController() != nil {
            menuButton.target = revealViewController()
            menuButton.action = "rightRevealToggle:"
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
    }
    
    //MARK: - BUTTON TAPPED
    @IBAction func copyToClipboardTapped(_ sender: Any) {
        let pasteboard = UIPasteboard.general
        pasteboard.string = addressLabel.text
        HUD.flash(.label("Copied"), delay: 0.3)
    }
    
    @IBAction func okButtonTapped(_ sender: Any) {
        let appDeledate = UIApplication.shared.delegate as! AppDelegate
        let revealViewController = appDeledate.revealViewController
        let dashboardVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "dashboardNav")
        if let revealVC = revealViewController, let menuVC = revealVC.rightViewController as? MenuVC, let tableView = menuVC.menuTableView as? UITableView {
            tableView.reloadData()
        }
        revealViewController!.pushFrontViewController(dashboardVC, animated: true)
    }
    
    
    //MARK: - API CALL
    func getUnUsedAddress() {
        guard let user = self.loggedInUser, let walletName = user.walletName, let accountName = user.accountName else {
            HUD.flash(.label("Sorry!, could not find current user."), delay: 0.2)
            sessionManager.setAppropriateVC()
            return
        }
        
        let param = [
            Parameter.url: "/api/wallet/unusedaddress",
            Parameter.walletName: walletName,
            Parameter.accountName: accountName] as [String: Any]
        HUD.show(.progress)
        APIClient.getUnUsedAddress(param: param) { (result, code, data) in
            switch result {
            case .success(let unusedAddressResponse):
                guard let statusCode = unusedAddressResponse.statusCode else {
                    HUD.flash(.label("Something went wrong!"), delay: 0.2)
                    return
                }
                if statusCode == 200 {
                    guard let _address = unusedAddressResponse.responseData else{
                        HUD.flash(.label("Sorry, address not found"), delay: 0.2)
                        self.resetAddress(address: "")
                        return
                    }
                    if _address.count != 34 {
                        self.resetAddress(address: "")
                        return
                    }
                    HUD.flash(.success)
                    self.resetAddress(address: _address)
                    break
                    
                } else {
                    if let errors = unusedAddressResponse.errors, let error = errors.first {
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
    func resetAddress(address: String) {
        self.addressLabel.text = address
        self.qrCodeIV.image = generateQRCode(from: address)
    }
    
    func generateQRCode(from string: String) -> UIImage? {
        let data = string.data(using: String.Encoding.ascii)
        
        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 3, y: 3)
            
            if let output = filter.outputImage?.transformed(by: transform) {
                return UIImage(ciImage: output)
            }
        }
        
        return nil
    }
}
