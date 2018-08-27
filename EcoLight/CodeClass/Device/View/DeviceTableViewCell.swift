//
//  DeviceTableViewCell.swift
//  EcoLight
//
//  Created by huang zhengguo on 2017/10/11.
//  Copyright © 2017年 huang zhengguo. All rights reserved.
//

import UIKit

class DeviceTableViewCell: UITableViewCell {

    @IBOutlet weak var lightImageView: UIImageView!
    @IBOutlet weak var lightNameLabel: UILabel!
    @IBOutlet weak var lightDetailLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.contentView.backgroundColor = UIColor.clear
        self.backgroundColor = UIColor.clear
        self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
