//
//  DownloadingViewController.swift
//  vivi
//
//  Created by nakajimashunta on 2017/10/23.
//  Copyright © 2017年 ShuntaNakajima. All rights reserved.
//

import UIKit
import FileKit

class DownloadingViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,ViviDownloadDelegate{
    var downloader:Downloader!
    var saves = [URLSessionDownloadTask:Path]()
    var Downloading = [URLSessionDownloadTask]()
    var cells = [URLSessionDownloadTask:DownloadingTableViewCell]()
    @IBOutlet var tableview:UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableview.delegate = self
        tableview.dataSource = self
        downloader.delegate = self
        tableview.register(UINib(nibName: "DownloadingTableViewCell", bundle: nil), forCellReuseIdentifier: "Mycell")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Downloading = downloader.getDownloadingItems()
        saves = downloader.getDownloadingPaths()
        tableview.reloadData()
    }
    @IBAction func toBrowser(){
        self.navigationController?.popViewController(animated: true)
    }
    func  didChangePercent(index: Int, percent: Float, downloadtask: URLSessionDownloadTask,min: Int64,max: Int64) {
        cells[downloadtask]?.progressView.setProgress(percent, animated: true)
        let bcf = ByteCountFormatter()
        bcf.allowedUnits = [.useMB,.useGB,.useKB,.useBytes]
        bcf.countStyle = .file
        cells[downloadtask]?.mixsizeLabel.text = bcf.string(fromByteCount: min)
        cells[downloadtask]?.maxsizeLabel.text = bcf.string(fromByteCount: max)
    }
    
    func didFinishDownload(index: Int) {
        Downloading = downloader.getDownloadingItems()
        saves = downloader.getDownloadingPaths()
        tableview.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Downloading.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Mycell",for: indexPath) as! DownloadingTableViewCell
        cell.titleLabel.text = saves[Downloading[indexPath.row]]?.fileName
        cell.downloadingUrlLabel.adjustsFontSizeToFitWidth = true
        cell.downloadingUrlLabel.text = String(describing: Downloading[indexPath.row].originalRequest!.url!)
        cell.downloader = self.downloader
        cell.progressView.setProgress(0, animated: true)
        cells[Downloading[indexPath.row]] = cell
        return cell
    }
}
