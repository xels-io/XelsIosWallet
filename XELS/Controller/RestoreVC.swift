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
    @IBOutlet weak var restoreButton: UIButton!
    
    let datePicker = UIDatePicker()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupNavBar()
        self.setupUI()
        self.hideKeyboardOnTappedAround()
        self.setupDatepicker()
        self.secretWordTV.placeholder = "Enter space separated secert words"
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
        
        walletNameTF.delegate = self
        creationDateTF.delegate = self
//        secretWordTF.delegate = self
        secretWordTV.delegate = self
        passwordTF.delegate = self
    }
    
    func setupDatepicker(){
        datePicker.datePickerMode = .date
        datePicker.addTarget(self, action: #selector(datepickerValueChanged(sender:)), for: .valueChanged)
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
                textField.removeWarning(isSecure: true)
            } else {
                textField.removeWarning(isSecure: false)
            }
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.removeWarning(isSecure: false)
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
    
    func isValid(textField: UITextField) -> Bool {
        if let text = textField.text, !text.trimmingCharacters(in: .whitespaces).isEmpty {
            return true
        }
        return false
    }
    
    func isValid(textView: UITextView) -> Bool {
        if let text = textView.text, !text.trimmingCharacters(in: .whitespaces).isEmpty {
            return true
        }
        return false
    }
    
    func isRestoreParametersValid() -> Bool{
        if !isValid(textField: walletNameTF) {
            walletNameTF.resignFirstResponder()
            walletNameTF.showWarning(message: "Please enter a wallet name.")
            return false
        } else if !isValid(textField: creationDateTF) {
            creationDateTF.resignFirstResponder()
            creationDateTF.showWarning(message: "Please select a date.")
            return false
        } else if !isValid(textView: secretWordTV) {
            secretWordTV.resignFirstResponder()
            secretWordTV.showWarning(message: "Please enter space separated secret words")
        } else if !isValid(textField: passwordTF) {
            passwordTF.resignFirstResponder()
            passwordTF.showWarning(message: "Please enter valid password")
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
            guard let walletName = walletNameTF.text, let date = creationDateTF.text, let secretWords = secretWordTV.text, let password = passwordTF.text else {
                return
            }
            restoreWith(walletName: walletName, date: date, secureWords: secretWords, password: password)
        }
    }
    
    
    //MARK: - API CALL
    func restoreWith(walletName: String, date: String, secureWords: String, password: String) {
        
        let param = [Parameter.url: "/api/wallet/recover/",
                     Parameter.creationDate: date,
                     Parameter.folderPath: "null",
                     Parameter.mnemonic: secureWords,
                     Parameter.name: walletName,
                     Parameter.password: password] as [String: Any]
        
        
        HUD.show(.progress)
        APIClient.restore(param: param) { (result, code, data) in
            switch result {
            case .success(let restoreResponse):
                guard let statusCode = restoreResponse.statusCode else {
                    HUD.flash(.label("Something went wrong!"), delay: 0.2)
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
}
