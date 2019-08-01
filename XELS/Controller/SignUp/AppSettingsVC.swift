//
//  AppSettingsVC.swift
//  XELS
//
//  Created by iMac on 11/4/19.
//  Copyright © 2019 Silicon Orchard Ltd. All rights reserved.
//

import UIKit

class AppSettingsVC: UIViewController {

    @IBOutlet weak var baseUrlTF: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    //MARK: - SETUP
    func setup() {
        setupNavBar()
        setupBorders()
        getBaseUrl()
    }
    
    
    func setupNavBar() {
        self.navigationItem.title = "SETTINGS"
    }

    func setupBorders() {
        baseUrlTF.doCornerAndBorder(radius: 10.0, border: 2, color: UIColor.templateGreen.cgColor)
        saveButton.doCornerAndBorder(radius: 10.0, border: 2, color: UIColor.templateGreen.cgColor)
    }
    
    //MARK: - BUTTON ACTONS
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        let settingsManager = SettingsManager.sharedInstance()
        if let baseUrl = baseUrlTF.text, !baseUrl.trimmingCharacters(in: .whitespaces).isEmpty {
            settingsManager.baseUrl = baseUrl
        } else {
            settingsManager.baseUrl = BaseURL.baseUrl
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: - CUSTOM METHODS
    func getBaseUrl() {
        let settingsManager = SettingsManager.sharedInstance()
        if let baseUrl = settingsManager.baseUrl {
            baseUrlTF.text = baseUrl
        }
    }
}
