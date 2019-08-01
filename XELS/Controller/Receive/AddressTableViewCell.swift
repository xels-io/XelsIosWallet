//
//  AddressTableViewCell.swift
//  XELS
//
//  Created by iMac on 8/4/19.
//  Copyright © 2019 Silicon Orchard Ltd. All rights reserved.
//

import UIKit

class AddressTableViewCell: UITableViewCell {

    @IBOutlet weak var addressLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    
    func configCellWith(address: String) {
        self.addressLabel.text = address
    }
    
}
