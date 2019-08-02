//
//  Extensions.swift
//  XELS
//
//  Created by iMac on 31/12/18.
//  Copyright © 2018 Silicon Orchard Ltd. All rights reserved.
//

import UIKit
import Toast_Swift

extension UITextField {
    
//    func showWarning(message: String){
//        self.backgroundColor = UIColor.warningBackground
//        self.textColor = UIColor.templateWarning
//        self.text = message
//        if self.isSecureTextEntry {
//            self.isSecureTextEntry = false
//        }
//    }
    
//    func removeWarning(isSecure: Bool){
//        self.isSecureTextEntry = isSecure
//        self.layer.borderColor = UIColor.templateGreen.cgColor
//        self.backgroundColor = UIColor.white
//        self.textColor = UIColor.black
//        self.text = ""
//    }
    
}

extension UITextView {
    
    func showWarning(message: String){
        self.backgroundColor = UIColor.warningBackground
        self.textColor = UIColor.templateWarning
//        self.placeholder = message
        self.text = message
    }
    
    func removeWarning(isSecure: Bool){
        self.isSecureTextEntry = isSecure
        self.layer.borderColor = UIColor.templateGreen.cgColor
        self.backgroundColor = UIColor.white
        self.textColor = UIColor.black
        self.text = ""
//        self.placeholder = ""
    }
}

extension UIColor {
    static var templateWarning: UIColor {
        return UIColor(red:160/255, green:35/255, blue:25/255, alpha:1.0)
    }
    static var templateGreen: UIColor {
        return UIColor(red: 98/255, green: 176/255, blue: 79/255, alpha: 1.0)
    }
    static var templateDeepGreen: UIColor {
        return UIColor(red:0.22, green:0.48, blue:0.16, alpha:1.0)
    }
    static var warningBackground: UIColor {
        return UIColor(red:1.00, green:0.95, blue:0.80, alpha:1.0)
    }
    
}

extension UIView {
    
    func doCornerAndBorder(radius:CGFloat,border:CGFloat,color: CGColor){
        self.layer.cornerRadius = radius
        self.layer.borderWidth = border
        self.layer.borderColor = color
        self.clipsToBounds = true
    }
    
    func doRounded(height:CGFloat, border: Bool, color: CGColor){
        if border {
            self.layer.borderColor = color
            self.layer.borderWidth = 1.0
        }
        self.layer.masksToBounds = false
        self.layer.cornerRadius = height/2
        self.clipsToBounds = true
        
    }
    
    func doBottomShadow() {
        self.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        self.layer.shadowOpacity = 1.0
        self.layer.shadowOffset = CGSize(width: 0.5, height: 4.0)
        self.layer.shadowRadius = 2.0
        self.layer.masksToBounds = false
        self.layer.cornerRadius = 4.0
    }
    
    func loadNib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nibName = type(of: self).description().components(separatedBy: ".").last!
        let nib = UINib(nibName: nibName, bundle: bundle)
        return nib.instantiate(withOwner: self, options: nil).first as! UIView
    }
}


class AppTheme: NSObject {
    var themeColor: UIColor = UIColor.templateGreen
    
}


extension UITextView: UITextViewDelegate {
    
    /// Resize the placeholder when the UITextView bounds change
    override open var bounds: CGRect {
        didSet {
            self.resizePlaceholder()
        }
    }
    
    /// The UITextView placeholder text
    public var placeholder: String? {
        get {
            var placeholderText: String?
            
            if let placeholderLabel = self.viewWithTag(100) as? UILabel {
                placeholderText = placeholderLabel.text
            }
            
            return placeholderText
        }
        set {
            if let placeholderLabel = self.viewWithTag(100) as! UILabel? {
                placeholderLabel.text = newValue
                placeholderLabel.sizeToFit()
            } else {
                self.addPlaceholder(newValue!)
            }
        }
    }
    
    /// When the UITextView did change, show or hide the label based on if the UITextView is empty or not
    ///
    /// - Parameter textView: The UITextView that got updated
    public func textViewDidChange(_ textView: UITextView) {
        if let placeholderLabel = self.viewWithTag(100) as? UILabel {
            placeholderLabel.isHidden = self.text.characters.count > 0
        }
    }
    
    /// Resize the placeholder UILabel to make sure it's in the same position as the UITextView text
    private func resizePlaceholder() {
        if let placeholderLabel = self.viewWithTag(100) as! UILabel? {
            let labelX = self.textContainer.lineFragmentPadding
            let labelY = self.textContainerInset.top - 2
            let labelWidth = self.frame.width - (labelX * 2)
            let labelHeight = placeholderLabel.frame.height
            
            placeholderLabel.frame = CGRect(x: labelX, y: labelY, width: labelWidth, height: labelHeight)
        }
    }
    
    /// Adds a placeholder UILabel to this UITextView
    private func addPlaceholder(_ placeholderText: String) {
        let placeholderLabel = UILabel()
        
        placeholderLabel.text = placeholderText
        placeholderLabel.sizeToFit()
        
        placeholderLabel.font = self.font
        placeholderLabel.textColor = UIColor.lightGray
        placeholderLabel.tag = 100
        
        placeholderLabel.isHidden = self.text.characters.count > 0
        
        self.addSubview(placeholderLabel)
        self.resizePlaceholder()
        self.delegate = self
    }
    
}


extension UIViewController {
    func isValid(_ value: String, regEx: String) -> Bool {
        let emailTest = NSPredicate(format:"SELF MATCHES[c] %@", regEx)
        return emailTest.evaluate(with: value)
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
    
    
    func showWarning(message: String){
        var style = ToastStyle()
        style.messageColor = .black
        style.backgroundColor = .white
        style.cornerRadius = 5
        style.displayShadow = true
        self.view.makeToast(message, duration: 5.0, position: .bottom, style: style)
    }
}
