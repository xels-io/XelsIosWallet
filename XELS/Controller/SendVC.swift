//
//  SendVC.swift
//  XELS
//
//  Created by iMac on 31/12/18.
//  Copyright © 2018 Silicon Orchard Ltd. All rights reserved.
//

import UIKit
import PKHUD
import AVFoundation

class SendVC: UIViewController, UITextFieldDelegate, AVCaptureMetadataOutputObjectsDelegate{

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var totalBalanceLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var destinationAddLabel: UILabel!
    @IBOutlet weak var transactionFeeHeaderLabel: UILabel!
    @IBOutlet weak var transactionFeeLabel: UILabel!
    @IBOutlet weak var walletPassLabel: UILabel!
    @IBOutlet weak var amountTF: UITextField!
    @IBOutlet weak var destinationAddressTF: UITextField!
    @IBOutlet weak var walletPasswordTF: UITextField!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    
    var transactionFee: Double?
    var activeField: UITextField?
    
    let sessionManager = SessionManager.sharedInstance()
    var loggedInUser: User?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        setupMenu()
        setupTetField()
        setLoggedInUser()
        self.hideKeyboardOnTappedAround()
        getBalance()
        registerForKeyboardNotifications()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if (captureSession?.isRunning == false) {
            captureSession.startRunning()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        deregisterFromKeyboardNotifications()
        if (captureSession?.isRunning == true) {
            captureSession.stopRunning()
        }
    }
    
    
    //MARK: - SETUP
    func setupTetField() {
        amountTF.delegate = self
        destinationAddressTF.delegate = self
        walletPasswordTF.delegate = self
    }
    
    func setupMenu() {
        if revealViewController() != nil {
            menuButton.target = revealViewController()
            menuButton.action = "rightRevealToggle:"
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
    }
    
    func setup() {
        self.navigationController?.navigationBar.barTintColor = UIColor.templateGreen
        totalBalanceLabel.textColor = UIColor.templateGreen
        amountLabel.textColor = UIColor.templateGreen
        amountTF.doCornerAndBorder(radius: 8.0, border: 1.0, color: UIColor.templateGreen.cgColor)
        destinationAddLabel.textColor = UIColor.templateGreen
        destinationAddressTF.doCornerAndBorder(radius: 8.0, border: 1.0, color: UIColor.templateGreen.cgColor)
        transactionFeeHeaderLabel.textColor = UIColor.templateGreen
        walletPassLabel.textColor = UIColor.templateGreen
        walletPasswordTF.doCornerAndBorder(radius: 8.0, border: 1.0, color: UIColor.templateGreen.cgColor)
        cancelButton.doCornerAndBorder(radius: 8.0, border: 2.0, color: UIColor.templateGreen.cgColor)
        sendButton.doCornerAndBorder(radius: 8.0, border: 2.0, color: UIColor.templateGreen.cgColor)
        sendButton.backgroundColor = UIColor.templateGreen
        sendButton.setTitleColor(UIColor.white, for: .normal)
    }
    
    
    func setLoggedInUser() {
        self.loggedInUser = sessionManager.currentUser
    }
    
    func registerForKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func deregisterFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    func setupCaptureSession() {
        captureSession = AVCaptureSession()
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        let videoInput: AVCaptureDeviceInput
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }
        
        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
        } else {
            failed()
            return
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        if (captureSession.canAddOutput(metadataOutput)) {
            captureSession.addOutput(metadataOutput)
            
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            failed()
            return
        }
    }
    
    func setupPreviewLayer() {
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
    }
    
    //MARK: - BUTTON TAPPED    
    @IBAction func AmountAndDestinationTFDidEnd(_ sender: UITextField) {
        if isTransactionFeeParamentersValid() {
            guard let amount = amountTF.text, let destinationAddress = destinationAddressTF.text else {
                return
            }
            if let _amount = Double(amount) {
                getTransactionFeeFor(amount: _amount, destinationAddress: destinationAddress)
            }
        }
    }
    
    @IBAction func sendButtonTapped(_ sender: UIButton) {
        if isSendParametersValid() {
            guard let amount = amountTF.text, let destinationAddress = destinationAddressTF.text, let password = walletPasswordTF.text else {
                return
            }
            
            if let _fee = transactionFee, let _amount = Double(amount) {
                buildWith(fee: _fee, amount: _amount, destinationAddress: destinationAddress, password: password)
            } else {
                HUD.flash(.label("Sorry, no transaction fee found! Please enter valid amount and destination address."), delay: 0.3)
            }
        }
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        let appDeledate = UIApplication.shared.delegate as! AppDelegate
        let revealViewController = appDeledate.revealViewController
        let dashboardVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "dashboardNav")
        if let revealVC = revealViewController, let menuVC = revealVC.rightViewController as? MenuVC, let tableView = menuVC.menuTableView as? UITableView {
            tableView.reloadData()
        }
        revealViewController!.pushFrontViewController(dashboardVC, animated: true)
    }
    
    @IBAction func scanQrCodeButtonTapped(_ sender: Any) {
        if AVCaptureDevice.authorizationStatus(for: .video) ==  .authorized {
            //already authorized
            print("Authorized")
            self.setupCaptureSession()
            self.setupPreviewLayer()
            self.captureSession.startRunning()
        } else {
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { (granted: Bool) in
                if granted {
                    print("Granted")
                    DispatchQueue.main.async {
                        self.setupCaptureSession()
                        self.setupPreviewLayer()
                        self.captureSession.startRunning()
                    }
                } else {
                    print("Denied")
                    self.requestForCamera()
                }
            })
        }

    }
    
    //MARK: - API CALL
    func getBalance() {
        guard let user = self.loggedInUser, let walletName = user.walletName, let accountName = user.accountName else {
            HUD.flash(.label("Sorry!, could not find current user."), delay: 0.2)
            sessionManager.setAppropriateVC()
            return
        }
        
        let param = [Parameter.url: "/api/wallet/balance", Parameter.walletName: walletName, Parameter.accountName: accountName] as [String: Any]
        //HUD.show(.progress)
        APIClient.getBalance(param: param) { (result, statusCode, data) in
            switch result {
            case .success(let balanceResponse):
                guard let statusCode = balanceResponse.statusCode else {
                    //HUD.flash(.label("Something went wrong!"), delay: 0.2)
                    return
                }
                if statusCode == 200 {
                    guard let responseData = balanceResponse.responseData, let balances = responseData.balances, let balance = balances.first else{
                        //HUD.flash(.label("Sorry, balance not found"), delay: 0.2)
                        return
                    }
                    //HUD.flash(.success, delay: 0.1, completion:{ (_) in
                        if let confirmedBalance = balance.amountConfirmed, let unConfirmedBalance = balance.amountUnconfirmed {
                            let value = self.satosiToXels(value: confirmedBalance+unConfirmedBalance)
                            self.setBalanceTextWith(balance: value.description)
                        }
                        return
                    //})
                } else {
                    if let errors = balanceResponse.errors, let error = errors.first {
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
                //HUD.flash(.label("Something went wrong!"), delay: 0.2)
                break
            }
        }
    }
    
    
    func getTransactionFeeFor(amount: Double, destinationAddress: String) {
        guard let user = self.loggedInUser, let walletName = user.walletName, let accountName = user.accountName else {
            HUD.flash(.label("Sorry!, could not find current user."), delay: 0.2)
            sessionManager.setAppropriateVC()
            return
        }
        
        let destinationAndAmountKeyword = getDestinationAndAmountKeyword()
        let param = [
            Parameter.url: "/api/wallet/estimate-txfee",
            Parameter.walletName: walletName,
            Parameter.accountName: accountName,
            destinationAndAmountKeyword.0 : destinationAddress,
            destinationAndAmountKeyword.1 : amount,
            Parameter.feeType: "medium",
            Parameter.allowUnconfirmed: "true"
            ] as [String: Any]
        HUD.show(.progress)
        APIClient.getTransactionFee(param: param) { (result, code, data) in
            switch result {
            case .success(let feeResponse):
                guard let statusCode = feeResponse.statusCode else {
                    HUD.flash(.error)
                    return
                }
                if statusCode == 200 {
                    if let amount = feeResponse.responseData {
                        self.transactionFee = self.satosiToXels(value: amount).doubleValue
                        self.showFeeWith(value: "\(self.transactionFee ?? 0.0) XELS", color: UIColor.black)
                        HUD.flash(.success)
                        return
                    }
                    HUD.flash(.error)
                } else {
                    self.resetFee()
                    if let errors = feeResponse.errors, let error = errors.first {
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
    
    
    func buildWith(fee: Double, amount: Double, destinationAddress: String, password: String) {
        HUD.show(.progress)
        guard let user = self.loggedInUser, let walletName = user.walletName, let accountName = user.accountName else {
            HUD.flash(.label("Sorry!, could not find current user."), delay: 0.2)
            sessionManager.setAppropriateVC()
            return
        }
        
        let destinationAndAmountKeyword = getDestinationAndAmountKeyword()
        let param = [
            Parameter.url: "/api/wallet/build-transaction",
            Parameter.walletName: walletName,
            Parameter.accountName: accountName,
            Parameter.allowUnconfirmed: "true",
            Parameter.feeAmount: fee,
            Parameter.password: password,
            destinationAndAmountKeyword.0 : destinationAddress,
            destinationAndAmountKeyword.1 : amount,
            Parameter.shuffleOutputs: "false",
            ] as [String: Any]
        
        APIClient.build(param: param) { (result, code, data) in
            switch result {
            case .success(let buildResponse):
                guard let statusCode = buildResponse.statusCode else {
                    HUD.flash(.error)
                    return
                }
                if statusCode == 200 {
                    if let data = buildResponse.responseData, let _ = data.transactionId, let hex = data.hex {
                        //HUD.flash(.success)
                        self.send(hex: hex)
                        //self.resetUI()
                        return
                    }
                    HUD.flash(.error)
                } else {
                    if let errors = buildResponse.errors, let error = errors.first {
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
    
    func send(hex: String) {
        //HUD.show(.progress)
        let param = [
            Parameter.url: "/api/wallet/send-transaction",
            Parameter.hex: hex
            ] as [String: Any]
        
        APIClient.send(param: param) { (result, statusCode, data) in
            switch result {
            case .success(let sendResponse):
                guard let statusCode = sendResponse.statusCode else {
                    HUD.flash(.error)
                    return
                }
                if statusCode == 200 {
                    if let data = sendResponse.responseData, let _ = data.transactionId {
                        self.resetUI()
                        HUD.flash(.success)
                        return
                    }
                    HUD.flash(.error)
                } else {
                    if let errors = sendResponse.errors, let error = errors.first {
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
    
    
    //MARK: - CUSTOM METHODS
    func getDestinationAndAmountKeyword()->(String, String) {
        if BaseURL.getURL == Constant.mainGetURL {
            return (Parameter.rawDestinationAddress, Parameter.rawAmount)
        }
        return (Parameter.destinationAddress, Parameter.amount)
    }
    
    
    func satosiToXels(value: Int)->NSDecimalNumber {
        let object = ["numberone" : "\(value)", "numbertwo" : "\(Constant.satosi)"]
        let firstnumber: NSDecimalNumber =  NSDecimalNumber(string: object["numberone"])
        let secondnumber: NSDecimalNumber =  NSDecimalNumber(string: object["numbertwo"])
        let calculated: NSDecimalNumber = firstnumber.dividing(by: secondnumber)
        return calculated
    }
    
    func resetFee(){
        transactionFee = nil
        transactionFeeLabel.text = ""
    }
    
    func resetUI(){
        self.getBalance()
        amountTF.text = ""
        destinationAddressTF.text = ""
        transactionFeeLabel.text = ""
        transactionFee = nil
        walletPasswordTF.text = ""
    }
    
    func showFeeWith(value: String, color: UIColor) {
        transactionFeeLabel.text = value
        transactionFeeLabel.textColor = color
    }
    
    func setBalanceTextWith(balance: String) {
        let normal20 = UIFont(name: "Roboto-Regular", size: 20) ?? UIFont.systemFont(ofSize: 20)
        let mutableAttr = NSMutableAttributedString()
        mutableAttr.append(NSAttributedString(string: "Amount available:\n", attributes: [ NSAttributedString.Key.font: normal20]))
        mutableAttr.append(NSAttributedString(string: balance, attributes: [ NSAttributedString.Key.font: normal20]))
        self.totalBalanceLabel.attributedText = mutableAttr
    }
    
    func isSendParametersValid() -> Bool {
        if !isValid(textField: amountTF) {
            amountTF.resignFirstResponder()
            amountTF.showWarning(message: "Please enter valid amount!")
            return false
        } else if !isValid(textField: destinationAddressTF) {
            destinationAddressTF.resignFirstResponder()
            destinationAddressTF.showWarning(message: "Please enter destination address!")
            return false
        } else if !isValid(textField: walletPasswordTF) {
            walletPasswordTF.resignFirstResponder()
            walletPasswordTF.showWarning(message: "Please enter wallet password!")
            return false
        }
        return true
    }
    
    func isTransactionFeeParamentersValid() -> Bool {
        if !isValid(textField: amountTF) {
            return false
        } else if !isValid(textField: destinationAddressTF) {
            return false
        }
        return true
    }
    
    func isValid(textField: UITextField) -> Bool {
        if let text = textField.text, !text.trimmingCharacters(in: .whitespaces).isEmpty {
            return true
        }
        return false
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            
            let contentInsets: UIEdgeInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardHeight, right: 0.0)
            scrollView.contentInset = contentInsets
            scrollView.scrollIndicatorInsets = contentInsets
            var aRect: CGRect = self.view.frame
            aRect.size.height -= keyboardHeight
            guard let activeField = activeField else {
                return
            }
            
            if aRect.contains(activeField.frame.origin) {
                self.scrollView.scrollRectToVisible(activeField.frame, animated: true)
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        let contentInsets: UIEdgeInsets = .zero
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
    }
    
    
    func hideKeyboardOnTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func hideKeyboard() {
        self.view.endEditing(true)
    }
    
    func requestForCamera(){
        let alertController = UIAlertController(title: "Xels Wallet Would Like to Access the Camera", message: "Xels Wallet needs  your camera to scan QR Code.", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        let goToSettingsAction = UIAlertAction(title: "Go to Settings", style: .default) { (action) in
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                return
            }
            
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.openURL(settingsUrl)
            }
        }
        alertController.addAction(cancelAction)
        alertController.addAction(goToSettingsAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    //MARK: - UITEXTFIELD DELEGATE
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.textColor == UIColor.templateWarning {
            if textField == walletPasswordTF {
                textField.isSecureTextEntry = true
            }
            textField.backgroundColor = UIColor.white
            textField.textColor = UIColor.black
            textField.text = ""
        }
        activeField = textField
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        activeField = nil
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if textField == amountTF {
            destinationAddressTF.becomeFirstResponder()
        } else if textField == destinationAddressTF {
            walletPasswordTF.becomeFirstResponder()
        }
        return true
    }
    
    //MARK:- SCANNER METHODS
    func failed() {
        let ac = UIAlertController(title: "Scanning not supported", message: "Your device does not support scanning a code from an item. Please use a device with a camera.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
        captureSession = nil
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        captureSession.stopRunning()
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            found(code: stringValue)
        }
        dismiss(animated: true)
    }
    
    func found(code: String) {
        print(code)
        previewLayer.removeFromSuperlayer()
        self.destinationAddressTF.text = code
        self.AmountAndDestinationTFDidEnd(self.destinationAddressTF)
    }
}
