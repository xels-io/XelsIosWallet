//
//  MenuVC.swift
//  XELS
//
//  Created by iMac on 4/1/19.
//  Copyright © 2019 Silicon Orchard Ltd. All rights reserved.
//

import UIKit

class MenuVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var menuTableView: UITableView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var userNameLabel: UILabel!
    
    let menus = [MenuItem(title: "Dashboard", selectedImage: "dashboard_selected", unselectedImage: "dashboard_unselected"),
                 MenuItem(title: "History", selectedImage: "coin_selected", unselectedImage: "coin_unselected"),
                 MenuItem(title: "Receive", selectedImage: "receive_selected", unselectedImage: "receive_unselected"),
                 MenuItem(title: "Send", selectedImage: "send_selected", unselectedImage: "send_unselected"),
                 MenuItem(title: "", selectedImage: "", unselectedImage: ""),
                 MenuItem(title: "Logout", selectedImage: "logout_selected", unselectedImage: "logout_unselected")]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.templateDeepGreen
        setupHeader()
        setupTableView()
    }
        
    //MARK: - SETUP
    func setupHeader(){
        headerView.backgroundColor = UIColor.templateDeepGreen
        userNameLabel.text = getUserName()
    }
    
    func setupTableView() {
        menuTableView.dataSource = self
        menuTableView.delegate = self
        menuTableView.backgroundColor = UIColor.templateGreen
    }
    
    
    //MARK: - TABLEVIEW METHODS
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menus.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "menuCell", for: indexPath) as! MenuTVCell
        cell.backgroundColor = UIColor.templateGreen
        if indexPath.row == 4 {
            cell.menuIcon.isHidden = true
            cell.menuLabel.isHidden = true
            cell.selectionStyle = .none
        } else {
            cell.menuIcon.image = UIImage(named: menus[indexPath.row].unselectedImage)
            cell.menuLabel.text = menus[indexPath.row].title
            cell.menuLabel.textColor = UIColor.white
        }
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let appDeledate = UIApplication.shared.delegate as! AppDelegate
        let revealViewController = appDeledate.revealViewController
        switch indexPath.row {
        case 0:
            let dashboardVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "dashboardNav")
            revealViewController!.pushFrontViewController(dashboardVC, animated: true)
            break
        case 1:
            let latestTransactionVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "latestTransactionNav")
            revealViewController!.pushFrontViewController(latestTransactionVC, animated: true)
            break
        case 2:
            let receiveVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "receiveNav")
            revealViewController!.pushFrontViewController(receiveVC, animated: true)
            break
        case 3:
            let sendVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "sendNav")
            revealViewController!.pushFrontViewController(sendVC, animated: true)
            break
        case 5:
            tableView.deselectRow(at: indexPath, animated: true)
            let logoutVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "logoutNav")
            revealViewController?.frontViewController.present(logoutVC, animated: true, completion: nil)
            break
        default:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        deselectAllRow(tableView, indexPath)
        if indexPath.row == 5 || indexPath.row == 4{
           return indexPath
        }
        let cell = tableView.cellForRow(at: indexPath) as! MenuTVCell
        cell.isSelected = true
        cell.contentView.backgroundColor = UIColor.white
        cell.menuLabel.textColor = UIColor.templateGreen
        cell.menuIcon.image = UIImage(named: menus[indexPath.row].selectedImage)
        return indexPath
    }
    
    func deselectAllRow(_ tableView: UITableView,_ indexPath: IndexPath){
        let section = indexPath.section
        for row in 0..<tableView.numberOfRows(inSection: section){
            let index = IndexPath(row: row, section: section)
            let cell = tableView.cellForRow(at: index) as! MenuTVCell
            cell.contentView.backgroundColor = UIColor.templateGreen
            cell.menuLabel.textColor = UIColor.white
            cell.menuIcon.image = UIImage(named: menus[index.row].unselectedImage)
        }
    }
    
    //MARK: - CUSTOM METHODS
    func getUserName() -> String {
        let sessionManager = SessionManager.sharedInstance()
        if let currentUser = sessionManager.currentUser, let userName = currentUser.walletName {
            return userName
        }
        sessionManager.setAppropriateVC()
        return ""
    }
    
    func slideBack() {
        
    }
}

struct MenuItem {
    var title = ""
    var selectedImage = ""
    var unselectedImage = ""
}
