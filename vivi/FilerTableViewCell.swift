//
//  FilerTableViewCell.swift
//  vivi
//
//  Created by nakajimashunta on 2017/11/17.
//  Copyright © 2017年 ShuntaNakajima. All rights reserved.
//

import UIKit

class FilerTableViewCell: UITableViewCell {
    @IBOutlet var FileImageView : UIImageView!
    @IBOutlet var FileNameLabel:UILabel!
    @IBOutlet var SizeLabel:UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
