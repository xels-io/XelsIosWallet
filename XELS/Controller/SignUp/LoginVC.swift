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
        self.setDefaultBaseUrl()
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
        if noBaseUrl() {
            return
        }
        guard let walletName = walletNameTF.text, !walletName.trimmingCharacters(in: .whitespaces).isEmpty, walletNameTF.textColor != UIColor.templateWarning else {
            walletNameTF.resignFirstResponder()
            //walletNameTF.showWarning(message: "Please enter valid wallet name!")
            showWarning(message: "Please enter valid wallet name")
            return
        }
        guard let password = passwordTF.text, !password.trimmingCharacters(in: .whitespaces).isEmpty, passwordTF.textColor != UIColor.templateWarning/*, isValid(password, regEx: Constant.passWordRegEx)*/ else {
            passwordTF.resignFirstResponder()
            //passwordTF.showWarning(message: "Please enter valid password!")
            showWarning(message: "Please enter valid password")
            return
        }
        decryptWith(walletName: walletName, password: password)
    }
    
    @IBAction func restoreButtonTapped(_ sender: Any) {
        if noBaseUrl() {
            return
        }
        let restoreVC = UIStoryboard(name: "Signup", bundle: nil).instantiateViewController(withIdentifier: "signupVC")
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.navigationItem.backBarButtonItem?.tintColor = UIColor.white
        self.navigationController?.pushViewController(restoreVC, animated: true)
    }
    
    
    @IBAction func createButtonTapped(_ sender: Any) {
        if noBaseUrl() {
            return
        }
        let restoreVC = UIStoryboard(name: "Signup", bundle: nil).instantiateViewController(withIdentifier: "createVC")
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.navigationItem.backBarButtonItem?.tintColor = UIColor.white
        self.navigationController?.pushViewController(restoreVC, animated: true)
    }
    
    @IBAction func settingsButtonTapped(_ sender: Any) {
        let appSettingsVC = UIStoryboard(name: "Signup", bundle: nil).instantiateViewController(withIdentifier: "settingsVC")
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.navigationItem.backBarButtonItem?.tintColor = UIColor.white
        self.navigationController?.pushViewController(appSettingsVC, animated: true)
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
                        //HUD.flash(.label(message), delay: 0.2)
                        PKHUD.sharedHUD.hide(afterDelay: 0.2) { success in
                            self.showWarning(message: message)
                        }
                        return
                    }
                    HUD.flash(.error)
                }
                break
            case .failure(let error):
                //HUD.flash(.label(error.localizedDescription), delay: 0.2)
                PKHUD.sharedHUD.hide(afterDelay: 0.2) { success in
                    self.showWarning(message: error.localizedDescription as! String)
                }
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
    
    func setDefaultBaseUrl() {
        let settingsManager = SettingsManager.sharedInstance()
        if settingsManager.baseUrl == nil {
            settingsManager.baseUrl = BaseURL.baseUrl
        }
    }
    
    func noBaseUrl() -> Bool {
        let settingsManager = SettingsManager.sharedInstance()
        if let _ = settingsManager.baseUrl {
            return false
        }
        self.showAlertForBaseURL()
        return true
    }
    
    func showAlertForBaseURL() {
        let alertController = UIAlertController(title: "Warning!", message: "App requires base URL first!!", preferredStyle: .alert)
        let goToSettingsAction = UIAlertAction(title: "Set URL", style: .default) { (action) in
            self.settingsButtonTapped(UIButton())
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(goToSettingsAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
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
