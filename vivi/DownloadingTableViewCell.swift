//
//  DownloadingTableViewCell.swift
//  vivi
//
//  Created by nakajimashunta on 2017/10/23.
//  Copyright © 2017年 ShuntaNakajima. All rights reserved.
//

import UIKit

class DownloadingTableViewCell: UITableViewCell{
    
    @IBOutlet var titleLabel:UILabel!
    @IBOutlet var progressView:UIProgressView!
    @IBOutlet var downloadingUrlLabel:UILabel!
    @IBOutlet var mixsizeLabel:UILabel!
    @IBOutlet var maxsizeLabel:UILabel!
    var downloader:Downloader!
    var downloadtask:URLSessionDownloadTask!
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
