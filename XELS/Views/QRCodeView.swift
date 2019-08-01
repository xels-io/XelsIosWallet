//
//  QRCodeView.swift
//  XELS
//
//  Created by iMac on 8/4/19.
//  Copyright © 2019 Silicon Orchard Ltd. All rights reserved.
//

import UIKit

class QRCodeView: UIView {

    @IBOutlet weak var qrCodeImageView: UIImageView!
    @IBOutlet var containerView: UIView!
    @IBOutlet weak var modalView: UIView!
    
    var alertWindow: UIWindow?
    
    // MARK: - UIView
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        modalView.layer.cornerRadius  = 8
        modalView.layer.masksToBounds  = true
    }
    
    // MARK:  INIT
    private func commonInit() {
        containerView = loadNib()
        containerView.frame = bounds
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
    
    func show(frame: CGRect, addressString: String) {
        self.frame = frame
        modalView.layer.cornerRadius  = 8
        modalView.layer.masksToBounds  = true
        openSelfInAlertWindow()
        
        let tapGesture = UITapGestureRecognizer(target: self, action:#selector(viewDidTapped(recognizer:)))
        tapGesture.delegate = self
        self.addGestureRecognizer(tapGesture)
        self.showQrCodeUsing(addressString)
    }
    
    //MARK: - CUSTOM METHODS
    fileprivate func openSelfInAlertWindow() {
        alertWindow = UIWindow(frame: UIScreen.main.bounds)
        let vc = UIViewController()
        vc.view.backgroundColor = .clear
        alertWindow?.rootViewController = vc
        alertWindow?.windowLevel = UIWindow.Level.alert + 1
        alertWindow?.makeKeyAndVisible()
        vc.view.addSubview(self)
    }
    
    @objc func viewDidTapped(recognizer: UIGestureRecognizer){
        self.hideAlertView()
    }
    
    func hideAlertView(){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.showMainWindow()
        
        self.removeFromSuperview()
        self.alertWindow = nil
    }
    
    func showQrCodeUsing(_ addressString: String) {
        self.qrCodeImageView.image = generateQRCode(from: addressString)
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
    
    //MARK: - BUTTON ACTIONS
    
}

extension QRCodeView: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if let touchView = touch.view, touchView.isDescendant(of: self.modalView){
            return false
        }
        return true
    }
}
