//
//  MenuTVCell.swift
//  XELS
//
//  Created by iMac on 4/1/19.
//  Copyright © 2019 Silicon Orchard Ltd. All rights reserved.
//

import UIKit

class MenuTVCell: UITableViewCell {
    @IBOutlet weak var menuIcon: UIImageView!
    @IBOutlet weak var menuLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
