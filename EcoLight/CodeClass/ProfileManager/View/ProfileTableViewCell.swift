//
//  ProfileTableViewCell.swift
//  EcoLight
//
//  Created by huang zhengguo on 2018/9/10.
//  Copyright © 2018年 huang zhengguo. All rights reserved.
//

import UIKit

class ProfileTableViewCell: UITableViewCell {
    @IBOutlet weak var selectBtn: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.selectBtn.setImage(UIImage.init(named: "circle_select"), for: .selected)
        self.selectBtn.setImage(UIImage.init(named: "circle_unselect"), for: .normal)
        self.selectBtn.isUserInteractionEnabled = false
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
