//
//  AlertView.swift
//  GeoBit
//
//  Created by Mr. Hasan on 1/18/18.
//  Copyright © 2018 Mehedi Hasan. All rights reserved.
//

import UIKit
import PKHUD

public enum AlertButtonType {
    case ok     //ok, cancel are similar
    case cancel
    case yes    //confirm
    case no     //reject
}

struct AlertButton {

    let type:AlertButtonType!
    let title:String!
    let colorHex:String?

    init(type: AlertButtonType, title: String, colorHex: String?) {
        self.type = type
        self.title = title
        self.colorHex = colorHex
    }
}

public enum AlertViewButtonType {
    case cancel_ok
    case confirm
}

public enum AppearanceType: String {
    case none = "None"
    case confirm = "Confirm"
    case error = "Error"
    case warning = "Warning"
    case information = "Information"
    
    init(stringValue: String) {
        guard let value = AppearanceType(rawValue: stringValue) else {
            self = .none
            return
        }
        self = value
    }
}

class AlertView: UIView {
    
    // MARK: - Public
    var appearanceType: AppearanceType?
    
    //Unity Side
    var alertWindow: UIWindow?
    var hideOnViewTap: Bool = true
    
    
    // MARK: - Outlets
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var modalView: UIView!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var copyButton: UIButton!
    @IBOutlet weak var transactionIdLbl: UILabel!
    @IBOutlet weak var confirmationLbl: UILabel!
    @IBOutlet weak var blockLabel: UILabel!
    @IBOutlet weak var datelabel: UILabel!
    @IBOutlet weak var feeLabel: UILabel!
    @IBOutlet weak var amountSentLabel: UILabel!
    @IBOutlet weak var totalAmountLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var amountSentView: UIView!
    @IBOutlet weak var feeView: UIView!
    
    // MARK: - Actions
    @IBAction func copyToClipboardBtnTapped(_ sender: Any) {
        if let text = transactionIdLbl.text {
            let pasteboard = UIPasteboard.general
            pasteboard.string = text
            HUD.flash(.label("Copied"), delay: 0.3)
        }
    }
    
    
    @IBAction func okBtnTapped(_ sender: Any) {
        self.hideAlertView()
    }
    
    @objc func viewDidTapped(recognizer: UIGestureRecognizer){
        self.hideAlertView()
    }
    
    func hideAlertView(){        
        self.removeFromSuperview()
        self.alertWindow = nil
    }
    
    // MARK: - UIView
    //for using in code
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // Setup view from .xib file
        commonInit()
    }
    
    //for using in IB
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        // Setup view from .xib file
        commonInit()
    }
     
    override func awakeFromNib() {
        super.awakeFromNib()
        
        modalView.layer.cornerRadius  = 8
        modalView.layer.masksToBounds  = true
        confirmButton.layer.cornerRadius = 6
        confirmButton.layer.masksToBounds  = true
    }
    
    // MARK:  Init
    
    private func commonInit() {
        //backgroundColor = UIColor.clear
        containerView = loadNib()
        // use bounds not frame or it'll be offset
        containerView.frame = bounds
        // Adding custom subview on top of our view
        addSubview(containerView)
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[childView]|",
                                                      options: [],
                                                      metrics: nil,
                                                      views: ["childView": containerView]))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[childView]|",
                                                      options: [],
                                                      metrics: nil,
                                                      views: ["childView": containerView]))
    }
    
    
    func showFullSceneAlert(transaction: Transaction, loggedInUser: User?, appearanceType: AppearanceType = .none){
        //Setup
        let frame = UIScreen.main.bounds
        
        self.frame = frame
        modalView.doCornerAndBorder(radius: 4, border: 2, color: UIColor.templateGreen.cgColor)
        modalView.layer.masksToBounds  = true
        confirmButton.doCornerAndBorder(radius: 8, border: 1, color: UIColor.templateGreen.cgColor)
        confirmButton.layer.masksToBounds  = true
        
        copyButton.doCornerAndBorder(radius: 1, border: 0, color: UIColor.templateGreen.cgColor)
        copyButton.backgroundColor = UIColor.templateGreen
        copyButton.layer.masksToBounds = true
        
        loadTransactionGeneralInfo(loggedInUser, transaction)
        setupDateWith(transaction: transaction)
        
        if let alertWindow = self.alertWindow {
            //without static, it'll be always nill
            alertWindow.rootViewController?.view.addSubview(self)
        } else {
            alertWindow = UIWindow(frame: UIScreen.main.bounds)
            let vc = BaseViewController()
            vc.view.backgroundColor = .clear
            alertWindow?.rootViewController = vc
            alertWindow?.windowLevel = UIWindow.Level.alert + 1
            alertWindow?.makeKeyAndVisible()

            vc.view.addSubview(self)
        }
        
        if hideOnViewTap {
            let tapGesture = UITapGestureRecognizer(target: self, action:#selector(viewDidTapped(recognizer:)))
            tapGesture.delegate = self
            self.addGestureRecognizer(tapGesture)
        }
    }
    
    
    //MARK: - API CALL
    func loadTransactionGeneralInfo(_ loggedInUser: User?, _ transaction: Transaction) {
        guard let user = loggedInUser, let walletName = user.walletName, let accountName = user.accountName else {
            HUD.flash(.label("Sorry!, could not find current user."), delay: 0.2)
            return
        }
        
        let param = [Parameter.url: "/api/wallet/general-info",
                     Parameter.name: walletName] as [String: Any]
        HUD.show(.progress)
        APIClient.getTransactionDetailGeneralInfo(param: param) { (result, code, data) in
            switch result {
            case .success(let transactionGeneralInfoResponse):
                guard let statusCode = transactionGeneralInfoResponse.statusCode else {
                    HUD.flash(.label("Something went wrong!"), delay: 0.2)
                    return
                }
                if statusCode == 200 {
                    guard let generalInfo = transactionGeneralInfoResponse.responseData else{
                        HUD.flash(.label("Sorry, Info not found"), delay: 0.2)
                        return
                    }
                    HUD.flash(.success)
                    self.updateAlertUIWith(generalInfo, transaction)
                } else {
                    if let errors = transactionGeneralInfoResponse.errors, let error = errors.first {
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
    
    //MARK: - CUSTOM METHODS
    func updateAlertUIWith(_ generalInfo: GeneralInfo, _ transaction: Transaction) {
        if let lastBlockSynchedHeight = generalInfo.lastBlockSyncedHeight {
            guard let confirmedInblock = transaction.confirmedInBlock  else {
                self.confirmationLbl.text = "0"
                self.blockLabel.text = "#0"
                return
            }
            let confirmations = lastBlockSynchedHeight - confirmedInblock + 1
            self.confirmationLbl.text = "\(confirmations)"
            self.blockLabel.text = "#\(lastBlockSynchedHeight)"
        } else {
            self.confirmationLbl.text = "0"
            self.blockLabel.text = "#0"
        }
    }
    
    
    func setupDateWith(transaction: Transaction) {
        let xels = " XELS"
        if let amount = transaction.amount {
            self.totalAmountLabel.text = satosiToXels(value: amount).description + xels
            self.amountSentLabel.text = satosiToXels(value: amount).description + xels
        }
        if let fee = transaction.fee {
            self.feeLabel.text =  satosiToXels(value: fee).description + xels
        }
        if let date = transaction.timestamp {
            self.datelabel.text = getDateFor(unixtimeInterval: Double(date) ?? 0)
        }
        self.transactionIdLbl.text = transaction.id
        
        if let type = transaction.type {
            switch type {
            case "send":
                self.typeLabel.text = "SENT"
                break
            case "received":
                self.typeLabel.text = "RECEIVED"
                self.amountSentView.isHidden = true
                self.feeView.isHidden = true
                self.totalAmountLabel.textColor = UIColor.black
                break
            case "staked":
                self.typeLabel.text = "REWARD"
                self.amountSentView.isHidden = true
                self.feeView.isHidden = true
                self.totalAmountLabel.textColor = UIColor.black
                break
            default:
                break
            }
        }
    }
    
    
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

extension AlertView: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if let touchView = touch.view, touchView.isDescendant(of: self.modalView){
            return false
        }
        return true
    }
}



class BaseViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    open override var shouldAutorotate: Bool {
        return false
    }
    
    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask{
        get {
            return .portrait
            //return [.portrait, .landscapeRight]
        }
    }
    
    open override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation{
        get {
            return .portrait
        }
    }
    
}
