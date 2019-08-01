//
//  AddressesContainerVC.swift
//  XELS
//
//  Created by iMac on 2/4/19.
//  Copyright © 2019 Silicon Orchard Ltd. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class AddressesContainerVC: ButtonBarPagerTabStripViewController {

    override func viewDidLoad() {
        configureButtonBar()
        super.viewDidLoad()
        
        setupNavigation()
    }
    

    //MARK: - SETUP
    func setupNavigation() {
        self.title = "ADDRESSES"
        self.navigationController?.navigationBar.tintColor = UIColor.white
    }
    
    func configureButtonBar() {
        settings.style.buttonBarBackgroundColor = .white
        settings.style.buttonBarItemBackgroundColor = .white
        
        settings.style.buttonBarItemFont = .boldSystemFont(ofSize: 14)
        
        
        settings.style.buttonBarMinimumLineSpacing = 0
        settings.style.buttonBarItemTitleColor = .red
        settings.style.buttonBarItemsShouldFillAvailableWidth = true
        settings.style.buttonBarLeftContentInset = 0
        settings.style.buttonBarRightContentInset = 0
        
        settings.style.selectedBarBackgroundColor = UIColor.templateGreen
        settings.style.selectedBarHeight = 2
        
        
        changeCurrentIndexProgressive = { [weak self] (oldCell: ButtonBarViewCell?, newCell: ButtonBarViewCell?, progressPercentage: CGFloat, changeCurrentIndex: Bool, animated: Bool) -> Void in
            guard changeCurrentIndex == true else { return }
            oldCell?.label.textColor = .gray
            newCell?.label.textColor = .black
        }
    }
    
    
    // MARK: - PagerTabStripDataSource
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let child_1 = storyboard.instantiateViewController(withIdentifier: "AddressesVC") as! AddressesVC
        let child_2 = storyboard.instantiateViewController(withIdentifier: "AddressesVC") as! AddressesVC
        let child_3 = storyboard.instantiateViewController(withIdentifier: "AddressesVC") as! AddressesVC
        
        child_1.itemInfo = IndicatorInfo(title: Constant.used)
        child_2.itemInfo = IndicatorInfo(title: Constant.unused)
        child_3.itemInfo = IndicatorInfo(title: Constant.changed)
        
        return [child_1, child_2, child_3]
    }
    
}
