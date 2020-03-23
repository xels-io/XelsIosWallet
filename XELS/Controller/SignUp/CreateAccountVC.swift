//
//  CreateAccountVC.swift
//  XELS
//
//  Created by iMac on 7/2/19.
//  Copyright © 2019 Silicon Orchard Ltd. All rights reserved.
//

import UIKit
import PKHUD

@available(iOS 11.0, *)
class CreateAccountVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UITextFieldDelegate {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var passPhraseTextField: UITextField!
    @IBOutlet weak var warningContainerView: UIView!
    @IBOutlet weak var word5Label: UILabel!
    @IBOutlet weak var Word5TextField: UITextField!
    @IBOutlet weak var word8Label: UILabel!
    @IBOutlet weak var word8TextField: UITextField!
    @IBOutlet weak var word12Label: UILabel!
    @IBOutlet weak var word12TextField: UITextField!
    
    @IBOutlet weak var inputSliderView: UIView!
    @IBOutlet weak var createNewWalletButton: UIButton!
    @IBOutlet weak var wordsCollectionView: UICollectionView!
    @IBOutlet weak var copyToClipBoardButton: UIButton!
    
    var mnemonic: String!
    var mnemonics = ["One", "Two", "Three", "Four", "Five", "Six", "One", "Two", "Three", "Four", "Five", "Six"]
    var randomIndex = [Int]()
    
    var name: String!
    var password: String!
    var passPhrase: String!
    var word5: String!
    var word8: String!
    var word12: String!
    

    var currentState = CreateWalletState.crateAWallet {
        didSet{
            self.navigationItem.title = currentState.rawValue
            if currentState == .confirmWords {
                createNewWalletButton.setTitle("Confirm", for: .normal)
            }
        }
    }
    
    let columnLayout = ColumnFlowLayout(
        cellsPerRow: 3,
        minimumInteritemSpacing: 10,
        minimumLineSpacing: 10,
        sectionInset: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    )

    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
        setupUI()
        NotificationCenter.default.addObserver(self, selector: #selector(checkBackgroundStatus),name: NSNotification.Name(rawValue: Constant.appBackgroundStatusNotKey),object: nil)
        print(currentState)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Constant.appBackgroundStatusNotKey), object: nil)
    }
    
    
    @objc func checkBackgroundStatus() {
        print("Current State:",currentState)
        if currentState == .mnemonic{
            slideView()
        } else if currentState == .confirmWords{
            slideView()
            slideView()
        }
    }
    
    func setup() {
        self.navigationItem.title = currentState.rawValue
        
        setupTF()
        setupCollectionView()
    }
    
    func setupTF() {
        self.nameTextField.delegate = self
        self.passwordTextField.delegate = self
        self.confirmPasswordTextField.delegate = self
        self.passPhraseTextField.delegate = self
        self.Word5TextField.delegate = self
        self.word8TextField.delegate = self
        self.word12TextField.delegate = self
    }
    
    func setupCollectionView() {
        self.wordsCollectionView.collectionViewLayout = columnLayout
        self.wordsCollectionView.delegate = self
        self.wordsCollectionView.dataSource = self
    }

    
    func setupUI() {
        setupButtonUI()
        setupTextFieldUI()
        setupWarningContentView()
    }
    
    
    func setupWarningContentView() {
        warningContainerView.backgroundColor = UIColor.warningBackground
        warningContainerView.doCornerAndBorder(radius: 5.0, border: 2.0, color: UIColor.warningBackground.cgColor)
    }
    
    func setupTextFieldUI() {
        nameTextField.doCornerAndBorder(radius: 10.0, border: 2, color: UIColor.templateGreen.cgColor)
        passwordTextField.doCornerAndBorder(radius: 10.0, border: 2, color: UIColor.templateGreen.cgColor)
        confirmPasswordTextField.doCornerAndBorder(radius: 10.0, border: 2, color: UIColor.templateGreen.cgColor)
        passPhraseTextField .doCornerAndBorder(radius: 10.0, border: 2, color: UIColor.templateGreen.cgColor)
        Word5TextField.doCornerAndBorder(radius: 10.0, border: 2, color: UIColor.templateGreen.cgColor)
        word8TextField.doCornerAndBorder(radius: 10.0, border: 2, color: UIColor.templateGreen.cgColor)
        word12TextField.doCornerAndBorder(radius: 10.0, border: 2, color: UIColor.templateGreen.cgColor)
    }
    
    
    func setupButtonUI() {
        createNewWalletButton.backgroundColor = UIColor.templateGreen
        createNewWalletButton.doCornerAndBorder(radius: 6.0, border: 2.0, color: UIColor.templateGreen.cgColor)
        createNewWalletButton.setTitleColor(UIColor.white, for: .normal)
        
        copyToClipBoardButton.doCornerAndBorder(radius: 8.0, border: 1.0, color: UIColor.templateGreen.cgColor)
    }
    
    //MARK: - BUTTON ACTIONS
    @IBAction func createNewWalletButtonTapped(_ sender: Any) {
        switch currentState {
        case .crateAWallet:
            goToMnemonicPage()
            break
            
        case .mnemonic:
            selectRandomMnemonicIndex()
            slideView()
            currentState = .confirmWords
            print("Current State:", currentState)
            break
            
        case .confirmWords:
            handleConfirmWords()
            break
        }
    }
    
    @IBAction func copyToClipboardButtonTapped(_ sender: Any) {
        let pasteboard = UIPasteboard.general
        pasteboard.string = self.mnemonic
        //HUD.flash(.label("Copied"), delay: 0.3)
        showWarning(message: "Copied")
    }
    
    //MARK: - API CALL
    func getMnemonics() {
        let param = [Parameter.url: "/api/wallet/mnemonic",
                     Parameter.language: "English",
                     Parameter.wordCount: 12] as [String: Any]
        HUD.show(.progress)
        APIClient.getMnemonics(param: param) { (result, code, data) in
            switch result {
            case .success(let mnemonicResponse):
                guard let statusCode = mnemonicResponse.statusCode else {
                    HUD.flash(.error)
                    return
                }
                if statusCode == 200 {
                    HUD.flash(.success, delay: 0.1, completion:{ (_) in
                        if let mnemonicString = mnemonicResponse.responseData {
                            self.mnemonic = mnemonicString
                            self.loadMnemonicFrom(mnemonicString)
                        }
                        return
                    })
                } else {
                    if let errors = mnemonicResponse.errors, let error = errors.first {
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
    
    
    
    func createAccountWith(mnemonic: String, name: String, password: String, passphrase: String) {
        
        let param = [Parameter.url: "/api/wallet/create/",
                     Parameter.folderPath: "null",
                     Parameter.name: name,
                     Parameter.mnemonic: mnemonic,
                     Parameter.password: password,
                     Parameter.passphrase: passphrase] as [String: Any]
        HUD.show(.progress)
        APIClient.createAccount(param: param) { (result, code, data) in
            switch result {
            case .success(let mnemonicResponse):
                guard let statusCode = mnemonicResponse.statusCode else {
                    HUD.flash(.error)
                    return
                }
                if statusCode == 200 {
                    HUD.flash(.success, delay: 0.1, completion:{ (_) in
                        if let _ = mnemonicResponse.responseData {
                            self.goToLoginScreen()
                        }
                        return
                    })
                } else {
                    if let errors = mnemonicResponse.errors, let error = errors.first {
                        guard let message = error.message else {
                            HUD.flash(.error)
                            return
                        }
//                        HUD.flash(.label(message), delay: 0.2)
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
                    self.showWarning(message: error.localizedDescription)
                }
                break
            }
        }
    }
    
    //MARK: - CUSTOM METHODS
    func selectRandomMnemonicIndex() {
//        var count:Int = 0
//        randomIndex.removeAll()
//        for _ in 1...3 {
//            let randomValue = Int.random(in: 1 ... 10)
//            randomIndex.append((randomValue % 12) + count)
//            count += 1
//        }
//        randomIndex.sort()
        
        let randomValue = Array(1...12)
        let generatedValue = Array(randomValue.shuffled().prefix(3))
        randomIndex = generatedValue
        //for i in 0..<generatedValue.count {
        //    print(generatedValue[i])
        //}
       
        self.word5Label.text = "Word number \(generatedValue[0])"
        self.word8Label.text = "Word number \(generatedValue[1])"
        self.word12Label.text = "Word number \(generatedValue[2])"
        
    }
    
    
    func goToMnemonicPage() {
        if isValidCredentials() {
            getMnemonics()
        }
    }
    
    
    func handleConfirmWords() {
        if isValidMnemonics() {
            if randomIndex.count < 3 {
                return
            }
            if word5 == mnemonics[randomIndex[0] - 1] && word8 == mnemonics[randomIndex[1] - 1] && word12 == mnemonics[randomIndex[2] - 1] {
                createAccountWith(mnemonic: mnemonic, name: name, password: password, passphrase: passPhrase)
            } else {
                //HUD.flash(.label("Sorry! Mnemonic words does not match."), delay: 0.2)
                showWarning(message: "Sorry! Mnemonic words does not match")
            }
        }
    }

    
    func loadMnemonicFrom(_ stringMnemonic: String) {
        mnemonics = stringMnemonic.components(separatedBy: .whitespaces)
        wordsCollectionView.reloadData()
        slideView()
        currentState = .mnemonic
        print("Current State:", currentState)
    }
    
    
    
    func isValidMnemonics() -> Bool{
        guard let word5 = Word5TextField.text, !word5.trimmingCharacters(in: .whitespaces).isEmpty, Word5TextField.textColor != UIColor.templateWarning else {
            Word5TextField.resignFirstResponder()
            showWarning(message: "Please enter valid word!")
            return false
        }
        guard let word8 = word8TextField.text, !word8.trimmingCharacters(in: .whitespaces).isEmpty, word8TextField.textColor != UIColor.templateWarning else {
            word8TextField.resignFirstResponder()
            showWarning(message: "Please enter valid word!")
            return false
        }
        guard let word12 = word12TextField.text, !word12.trimmingCharacters(in: .whitespaces).isEmpty, word12TextField.textColor != UIColor.templateWarning else {
            word12TextField.resignFirstResponder()
            showWarning(message: "Please enter valid word!")
            return false
        }
        self.word5 = word5
        self.word8 = word8
        self.word12 = word12
        
        return true
    }
    
    
    
    func isValidCredentials() -> Bool {
        
        if !isValid(textField: nameTextField) {
            nameTextField.resignFirstResponder()
            showWarning(message: "Please enter a valid name")
            return false
        } else if !isValid(textField: passwordTextField) {
            passwordTextField.resignFirstResponder()
            showWarning(message: "Password field is empty")
            return false
        } else if !isValid(passwordTextField.text!, regEx: Constant.passWordRegEx) {
            passwordTextField.resignFirstResponder()
            showWarning(message: "A password must contain at least one uppercase letter, one lowercase letter, one number and one special character. A password must be at least 8 character long")
            return false
        } else if !isValid(textField: confirmPasswordTextField) {
            confirmPasswordTextField.resignFirstResponder()
            showWarning(message: "Confirm password field is empty")
            return false
        } else if passwordTextField.text != confirmPasswordTextField.text {
            showWarning(message: "Password didn't match")
            return false
        } else if !isValid(textField: passPhraseTextField) {
            passPhraseTextField.resignFirstResponder()
            showWarning(message: "Your passphrase will be required to recover your wallet in the future")
            return false
        }
        
        self.name = nameTextField.text
        self.password = passwordTextField.text
        self.passPhrase = passPhraseTextField.text
        
        return true
    }
    
    
    func showAlert(title: String, message: String) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Try Again", style: .default, handler: nil)
        alertVC.addAction(okAction)
        self.present(alertVC, animated: true, completion: nil)
    }
    
    
    func slideView() {
        UIView.animate(withDuration: 0.5) {
            self.inputSliderView.frame.origin.x -= self.view.frame.width
        }
    }
    
    
    func goToLoginScreen() {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    //MARK: - COLLECTION VIEW METHODS
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return mnemonics.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "mnemonicCell", for: indexPath) as! WordsCollectionViewCell
        cell.wordLabel.text = "\(indexPath.row + 1). \(mnemonics[indexPath.row])"
        return cell
    }
    
    
    //MARK: - TEXTFIELD DELEGATE METHOD
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.textColor == UIColor.templateWarning {
            if textField == passwordTextField || textField == confirmPasswordTextField {
                textField.isSecureTextEntry = true
            }
            textField.backgroundColor = UIColor.white
            textField.textColor = UIColor.black
            textField.text = ""
        }
    }
    
}


enum CreateWalletState: String{
    case crateAWallet = "CREATE A WALLET"
    case mnemonic = "MNEMONICS"
    case confirmWords = "CONFIRM WORDS"
}



//@available(iOS 10.0, *)
class ColumnFlowLayout: UICollectionViewFlowLayout {
    
    let cellsPerRow: Int
    
    init(cellsPerRow: Int, minimumInteritemSpacing: CGFloat = 0, minimumLineSpacing: CGFloat = 0, sectionInset: UIEdgeInsets = .zero) {
        self.cellsPerRow = cellsPerRow
        super.init()
        
        self.minimumInteritemSpacing = minimumInteritemSpacing
        self.minimumLineSpacing = minimumLineSpacing
        self.sectionInset = sectionInset
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepare() {
        super.prepare()
        
        guard let collectionView = collectionView else { return }
        
        
        if #available(iOS 11, *) {
            let marginsAndInsets = sectionInset.left + sectionInset.right + collectionView.safeAreaInsets.left + collectionView.safeAreaInsets.right + minimumInteritemSpacing * CGFloat(cellsPerRow - 1)
            let itemWidth = ((collectionView.bounds.size.width - marginsAndInsets) / CGFloat(cellsPerRow)).rounded(.down)
            itemSize = CGSize(width: itemWidth, height: 30)
        } else {
            let marginsAndInsets = sectionInset.left + sectionInset.right  + minimumInteritemSpacing * CGFloat(cellsPerRow - 1)
            let itemWidth = ((collectionView.bounds.size.width - marginsAndInsets) / CGFloat(cellsPerRow)).rounded(.down)
            itemSize = CGSize(width: itemWidth, height: 30)
        }
        
       
    }
    
    override func invalidationContext(forBoundsChange newBounds: CGRect) -> UICollectionViewLayoutInvalidationContext {
        let context = super.invalidationContext(forBoundsChange: newBounds) as! UICollectionViewFlowLayoutInvalidationContext
        context.invalidateFlowLayoutDelegateMetrics = newBounds.size != collectionView?.bounds.size
        return context
    }
    
}
