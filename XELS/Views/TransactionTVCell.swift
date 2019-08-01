//
//  TransactionTVCell.swift
//  XELS
//
//  Created by iMac on 4/1/19.
//  Copyright © 2019 Silicon Orchard Ltd. All rights reserved.
//

import UIKit

class TransactionTVCell: UITableViewCell {
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var statusIV: UIImageView!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    func setupUI() {
        amountLabel.textColor = UIColor.templateGreen
        containerView.doCornerAndBorder(radius: 13.0, border: 2.0, color: UIColor.white.cgColor)
        containerView.doBottomShadow()
    }
}
