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
            break
            
        case .confirmWords:
            handleConfirmWords()
            break
        }
    }
    
    @IBAction func copyToClipboardButtonTapped(_ sender: Any) {
        let pasteboard = UIPasteboard.general
        pasteboard.string = self.mnemonic
        HUD.flash(.label("Copied"), delay: 0.3)
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
    func selectRandomMnemonicIndex() {
        randomIndex.removeAll()
        for _ in 1...3 {
            let randomValue = Int.random(in: 1 ... 12)
            randomIndex.append(randomValue)
        }
        randomIndex.sort()
        if randomIndex.count > 2 {
            self.word5Label.text = "Word number \(randomIndex[0])"
            self.word8Label.text = "Word number \(randomIndex[1])"
            self.word12Label.text = "Word number \(randomIndex[2])"
        }
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
                HUD.flash(.label("Sorry! Mnemonic words does not match."), delay: 0.2)
            }
        }
    }

    
    func loadMnemonicFrom(_ stringMnemonic: String) {
        mnemonics = stringMnemonic.components(separatedBy: .whitespaces)
        wordsCollectionView.reloadData()
        slideView()
        currentState = .mnemonic
    }
    
    
    
    func isValidMnemonics() -> Bool{
        guard let word5 = Word5TextField.text, !word5.trimmingCharacters(in: .whitespaces).isEmpty, Word5TextField.textColor != UIColor.templateWarning else {
            Word5TextField.resignFirstResponder()
            Word5TextField.showWarning(message: "Please enter valid word!")
            return false
        }
        guard let word8 = word8TextField.text, !word8.trimmingCharacters(in: .whitespaces).isEmpty, word8TextField.textColor != UIColor.templateWarning else {
            word8TextField.resignFirstResponder()
            word8TextField.showWarning(message: "Please enter valid word!")
            return false
        }
        guard let word12 = word12TextField.text, !word12.trimmingCharacters(in: .whitespaces).isEmpty, word12TextField.textColor != UIColor.templateWarning else {
            word12TextField.resignFirstResponder()
            word12TextField.showWarning(message: "Please enter valid word!")
            return false
        }
        self.word5 = word5
        self.word8 = word8
        self.word12 = word12
        
        return true
    }
    
    
    
    func isValidCredentials() -> Bool {
        guard let name = nameTextField.text, !name.trimmingCharacters(in: .whitespaces).isEmpty, nameTextField.textColor != UIColor.templateWarning else {
            nameTextField.resignFirstResponder()
            nameTextField.showWarning(message: "Please enter valid name!")
            return false
        }
        guard let password = passwordTextField.text, !password.trimmingCharacters(in: .whitespaces).isEmpty, passwordTextField.textColor != UIColor.templateWarning, isValid(password, regEx: Constant.passWordRegEx) else {
            passwordTextField.resignFirstResponder()
            passwordTextField.showWarning(message: "Please enter valid password!")
            return false
        }
        guard let confirmedPassword = confirmPasswordTextField.text, !confirmedPassword.trimmingCharacters(in: .whitespaces).isEmpty, confirmPasswordTextField.textColor != UIColor.templateWarning else {
            confirmPasswordTextField.resignFirstResponder()
            confirmPasswordTextField.showWarning(message: "Please enter valid password!")
            return false
        }
        
        guard let passPhrase = passPhraseTextField.text, !passPhrase.trimmingCharacters(in: .whitespaces).isEmpty, passPhraseTextField.textColor != UIColor.templateWarning else {
            passPhraseTextField.resignFirstResponder()
            passPhraseTextField.showWarning(message: "Please enter valid password!")
            return false
        }
        //self.passPhrase = passPhraseTextField.text
        if password != confirmedPassword {
            showAlert(title: "Password", message: "Password does not match!")
            return false
        }
        
        self.name = name
        self.password = password
        self.passPhrase = passPhrase
        
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
