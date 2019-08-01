//
//  LogoutVC.swift
//  XELS
//
//  Created by iMac on 4/1/19.
//  Copyright © 2019 Silicon Orchard Ltd. All rights reserved.
//

import UIKit
import PKHUD

class LogoutVC: UIViewController {
    @IBOutlet weak var yesButton: UIButton!
    @IBOutlet weak var noButton: UIButton!
    @IBOutlet weak var logoutConfirmationLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    
    //MARK: - SETUP
    func setupUI() {
        self.navigationController?.navigationBar.barTintColor = UIColor.templateGreen
        logoutConfirmationLabel.textColor = UIColor.templateGreen
        yesButton.backgroundColor = UIColor.templateGreen
        yesButton.doCornerAndBorder(radius: 6.0, border: 2.0, color: UIColor.templateGreen.cgColor)
        noButton.doCornerAndBorder(radius: 6.0, border: 2.0, color: UIColor.templateGreen.cgColor)
        //messageContentView.doCornerAndBorder(radius: 10.0, border: 2.0, color: UIColor.white.cgColor)
    }
    
    
    //MARK: - BUTTON TAPPED
    @IBAction func yesButtonTapped(_ sender: Any) {
//        logout()
        self.goToLoginViewController()
    }
    
    @IBAction func noButtonTapped(_ sender: Any) {
        self.dismiss(animated: true) {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.revealViewController?.revealToggle(animated: true)
        }
    }
    
    //MARK: - API CALL
    func logout() {
        let param = [Parameter.url: "/api/staking/stopstaking"] as [String: Any]
        HUD.show(.progress)
        APIClient.stopStaking(param: param) { (result, code, data) in
            switch result {
            case .success(let logoutResponse):
                guard let statusCode = logoutResponse.statusCode else {
                    HUD.flash(.error)
                    return
                }
                if statusCode == 200 {
                    HUD.flash(.success, delay: 0.1, completion:{ (_) in
                        self.goToLoginViewController()
                        return
                    })
                } else {
                    if let errors = logoutResponse.errors, let error = errors.first {
                        guard let message = error.message else {
                            HUD.flash(.error)
                            return
                        }
                        HUD.flash(.label(message), delay: 0.2)
                        return
                    }
                    HUD.flash(.error)
                }
                break
            case .failure(let error):
                HUD.flash(.label(error.localizedDescription), delay: 0.2)
                break
            }
        }
    }
    
    func goToLoginViewController() {
        let sessionManager = SessionManager.sharedInstance()
        sessionManager.currentUser = nil
        sessionManager.setAppropriateVC()
    }
}
