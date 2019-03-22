//
//  LoginVC.swift
//  XELS
//
//  Created by iMac on 31/12/18.
//  Copyright © 2018 Silicon Orchard Ltd. All rights reserved.
//

import UIKit
import PKHUD
import Alamofire
import AlamofireObjectMapper

class LoginVC: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var createRestoreContentView: UIView!
    @IBOutlet weak var walletNameTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var decryptButton: UIButton!
    @IBOutlet weak var restoreButton: UIButton!
    @IBOutlet weak var createButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        self.addGestureToHideKeyoardOnTappingAround()
    }
    
    
    //MARK: - UI SETUP
    func setupUI() {
        self.navigationController?.navigationBar.barTintColor = UIColor.templateGreen
        walletNameTF.delegate = self
        passwordTF.delegate = self
        decryptButton.backgroundColor = UIColor.templateGreen
        createRestoreContentView.backgroundColor = UIColor.templateGreen
        walletNameTF.doCornerAndBorder(radius: 10.0, border: 2, color: UIColor.templateGreen.cgColor)
        passwordTF.doCornerAndBorder(radius: 10.0, border: 2, color: UIColor.templateGreen.cgColor)
        decryptButton.doCornerAndBorder(radius: 10.0, border: 2, color: UIColor.templateGreen.cgColor)
        restoreButton.doCornerAndBorder(radius: 6.0, border: 2, color: UIColor.white.cgColor)
    }
    
    
    //MARK: - BUTTON TAPPED
    @IBAction func decryptButtonTapped(_ sender: Any) {
        guard let walletName = walletNameTF.text, !walletName.trimmingCharacters(in: .whitespaces).isEmpty, walletNameTF.textColor != UIColor.templateWarning else {
            walletNameTF.resignFirstResponder()
            walletNameTF.showWarning(message: "Please enter valid wallet name!")
            return
        }
        guard let password = passwordTF.text, !password.trimmingCharacters(in: .whitespaces).isEmpty, passwordTF.textColor != UIColor.templateWarning else {
            passwordTF.resignFirstResponder()
            passwordTF.showWarning(message: "Please enter valid password!")
            return
        }
        decryptWith(walletName: walletName, password: password)
    }
    
    @IBAction func restoreButtonTapped(_ sender: Any) {
        let restoreVC = UIStoryboard(name: "Signup", bundle: nil).instantiateViewController(withIdentifier: "signupVC")
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.navigationItem.backBarButtonItem?.tintColor = UIColor.white
        self.navigationController?.pushViewController(restoreVC, animated: true)
    }
    
    
    @IBAction func createButtonTapped(_ sender: Any) {
        let restoreVC = UIStoryboard(name: "Signup", bundle: nil).instantiateViewController(withIdentifier: "createVC")
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.navigationItem.backBarButtonItem?.tintColor = UIColor.white
        self.navigationController?.pushViewController(restoreVC, animated: true)
    }
    
    
    //MARK: - API CALL
    func decryptWith(walletName: String, password: String) {
        let param = [Parameter.url: "/api/wallet/load/",
                     Parameter.folderPath: "null",
                     Parameter.name: walletName,
                     Parameter.password: password] as [String: Any]
        HUD.show(.progress)
        APIClient.login(param: param) { (result, code, data) in
            switch result {
            case .success(let loginResponse):
                guard let statusCode = loginResponse.statusCode else {
                    HUD.flash(.error)
                    return
                }
                if statusCode == 200 {
                    HUD.flash(.success, delay: 0.1, completion:{ (_) in
                        self.goToDashboardViewController()
                        return
                    })
                } else {
                    if let errors = loginResponse.errors, let error = errors.first {
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
    
    
    //MARK: - CUSTOM FUNCTIONS
    func goToDashboardViewController() {
        let sessionManager = SessionManager.sharedInstance()
        let user = User()
        user.walletName = walletNameTF.text ?? ""
        user.password = passwordTF.text ?? ""
        user.accountName = "account 0"
        sessionManager.currentUser = user
        sessionManager.setAppropriateVC()
    }
    
    func addGestureToHideKeyoardOnTappingAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func hideKeyboard() {
        self.view.endEditing(true)
    }
    
    
    //MARK: - TEXTFIELD DELEGATE METHOD
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.textColor == UIColor.templateWarning {
            if textField == passwordTF {
                textField.isSecureTextEntry = true
            }
            textField.backgroundColor = UIColor.white
            textField.textColor = UIColor.black
            textField.text = ""
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.walletNameTF {
            passwordTF.becomeFirstResponder()
        } else {
            passwordTF.resignFirstResponder()
        }
        return true
    }
}
