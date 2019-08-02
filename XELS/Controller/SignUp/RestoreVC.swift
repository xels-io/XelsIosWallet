//
//  RestoreVC.swift
//  XELS
//
//  Created by iMac on 28/1/19.
//  Copyright © 2019 Silicon Orchard Ltd. All rights reserved.
//

import UIKit
import PKHUD

class RestoreVC: UIViewController, UITextFieldDelegate, UITextViewDelegate {

    @IBOutlet weak var walletNameTF: UITextField!
    @IBOutlet weak var creationDateTF: UITextField!
//    @IBOutlet weak var secretWordTF: UITextField!
    @IBOutlet weak var secretWordTV: UITextView!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var confirmPasswordTF: UITextField!
    @IBOutlet weak var passPhraseTF: UITextField!
    @IBOutlet weak var restoreButton: UIButton!
    
    let secretTextPlaceholder = "Enter space separated secret words"
    let datePicker = UIDatePicker()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupNavBar()
        self.setupUI()
        self.hideKeyboardOnTappedAround()
        self.setupDatepicker()
        setSecretTVPlaceholder()
    }
    
    //MARK: - SETUP
    func setupNavBar() {
        self.navigationItem.title = "RESTORE A WALLET"
    }
    
    func setupUI() {
        self.setupTF()
        restoreButton.doCornerAndBorder(radius: 8.0, border: 2.0, color: UIColor.templateGreen.cgColor)
        restoreButton.backgroundColor = UIColor.templateGreen
        restoreButton.setTitleColor(UIColor.white, for: .normal)
    }
    
    func setupTF() {
        walletNameTF.doCornerAndBorder(radius: 8.0, border: 1.0, color: UIColor.templateGreen.cgColor)
        creationDateTF.doCornerAndBorder(radius: 8.0, border: 1.0, color: UIColor.templateGreen.cgColor)
        secretWordTV.doCornerAndBorder(radius: 8.0, border: 1.0, color: UIColor.templateGreen.cgColor)
        passwordTF.doCornerAndBorder(radius: 8.0, border: 1.0, color: UIColor.templateGreen.cgColor)
        passPhraseTF.doCornerAndBorder(radius: 8.0, border: 1.0, color: UIColor.templateGreen.cgColor)
        
        walletNameTF.delegate = self
        creationDateTF.delegate = self
//        secretWordTF.delegate = self
        secretWordTV.delegate = self
        passwordTF.delegate = self
        passPhraseTF.delegate = self
    }
    
    func setupDatepicker(){
        datePicker.datePickerMode = .date
        datePicker.addTarget(self, action: #selector(datepickerValueChanged(sender:)), for: .valueChanged)
        datePicker.maximumDate = Date()
        self.creationDateTF.inputView = datePicker
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(doneClicked))
        toolbar.setItems([doneButton], animated: true)
        creationDateTF.inputAccessoryView = toolbar
        setDate()
    }
    
    func hideKeyboardOnTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func hideKeyboard() {
        self.view.endEditing(true)
    }
    
    //MARK: - TEXTFIELD DELEGATE
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == walletNameTF {
            creationDateTF.becomeFirstResponder()
        }else {
            textField.resignFirstResponder()
        }
        
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.textColor == UIColor.templateWarning {
            if textField == passwordTF {
                //textField.removeWarning(isSecure: true)
            } else {
                //textField.removeWarning(isSecure: false)
            }
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "Please enter space separated secret words" || textView.text == secretTextPlaceholder{
            textView.removeWarning(isSecure: false)
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == "" {
            setSecretTVPlaceholder()
        }
    }
    
    
    func setSecretTVPlaceholder() {
        self.secretWordTV.textColor = UIColor.lightGray
        self.secretWordTV.text = secretTextPlaceholder
    }
    
    //MARK: - CUSTOM METHODS
    @objc func datepickerValueChanged(sender: UIDatePicker){
        setDate()
    }
    
    @objc func doneClicked(){
        secretWordTV.becomeFirstResponder()
    }
    
    func setDate(){
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        creationDateTF.text = formatter.string(from: datePicker.date)
    }
    
    func isRestoreParametersValid() -> Bool{
        if !isValid(textField: walletNameTF) {
            walletNameTF.resignFirstResponder()
            showWarning(message: "Please enter a wallet name")
            return false
        } else if !isValid(textField: creationDateTF) {
            creationDateTF.resignFirstResponder()
            showWarning(message: "Please select a date")
            return false
        } else if !isValid(textView: secretWordTV) {
            secretWordTV.resignFirstResponder()
            showWarning(message: "Please enter space separated secret words")
            return false
        } else if !isValid(textField: passwordTF) {
            passwordTF.resignFirstResponder()
            showWarning(message: "New password field is empty")
            return false
        } else if !isValid(passwordTF.text!, regEx: Constant.passWordRegEx) {
            passwordTF.resignFirstResponder()
            showWarning(message: "A password must contain at least one uppercase letter, one lowercase letter, one number and one special character. A password must be at least 8 character long")
            return false
        } else if !isValid(textField: confirmPasswordTF) {
            confirmPasswordTF.resignFirstResponder()
            showWarning(message: "Confirm password field is empty")
            return false
        } else if passwordTF.text != confirmPasswordTF.text {
            showWarning(message: "Password didn't match")
            return false
        } else if !isValid(textField: passPhraseTF) {
            passPhraseTF.resignFirstResponder()
            showWarning(message: "Your passphrase will be required to recover your wallet in the future")
            return false
        }
        
        return true
    }
    
    func goToLoginVC(){
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: - BUTTON ACTION
    @IBAction func restoreButtonTapped(_ sender: Any) {
        if isRestoreParametersValid() {
            guard let walletName = walletNameTF.text, let date = creationDateTF.text, let secretWords = secretWordTV.text, let password = passwordTF.text, let passPhrase = passPhraseTF.text else {
                return
            }
            restoreWith(walletName: walletName, date: date, secureWords: secretWords, password: password, passPhrase: passPhrase)
        }
    }
    
    
    //MARK: - API CALL
    func restoreWith(walletName: String, date: String, secureWords: String, password: String, passPhrase: String) {
        
        let param = [Parameter.url: "/api/wallet/recover/",
                     Parameter.creationDate: date,
                     Parameter.folderPath: "null",
                     Parameter.mnemonic: secureWords,
                     Parameter.name: walletName,
                     Parameter.password: password,
                     Parameter.passphrase: passPhrase] as [String: Any]
        
        
        HUD.show(.progress)
        APIClient.restore(param: param) { (result, code, data) in
            switch result {
            case .success(let restoreResponse):
                guard let statusCode = restoreResponse.statusCode else {
//                    HUD.flash(.label("Something went wrong!"), delay: 0.2)
                    PKHUD.sharedHUD.hide(afterDelay: 0.2) { success in
                        self.showWarning(message:"Something went wrong!")
                    }
                    return
                }
                if statusCode == 200 {
                    HUD.flash(.success, delay: 0.1, completion:{ (_) in
                        self.goToLoginVC()
                        return
                    })
                } else {
                    if let errors = restoreResponse.errors, let error = errors.first {
                        guard let message = error.message else {
                            //HUD.flash(.label("Something went wrong!"), delay: 0.2)
                            PKHUD.sharedHUD.hide(afterDelay: 0.2) { success in
                                self.showWarning(message:error.message ?? "")
                            }
                            return
                        }
//                        HUD.flash(.label(message), delay: 0.2)
                        PKHUD.sharedHUD.hide(afterDelay: 0.2) { success in
                            self.showWarning(message: message)
                        }
                        return
                    }
                    //HUD.flash(.label("Something went wrong!"), delay: 0.2)
                    PKHUD.sharedHUD.hide(afterDelay: 0.2) { success in
                        self.showWarning(message:"Something went wrong!")
                    }
                }
                break
            case .failure:
                //HUD.flash(.label("Something went wrong!"), delay: 0.2)
                PKHUD.sharedHUD.hide(afterDelay: 0.2) { success in
                    self.showWarning(message:"Something went wrong!")
                }
                break
            }
        }
    }
}
