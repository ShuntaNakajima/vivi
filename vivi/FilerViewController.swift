//
//  FilerViewController.swift
//  vivi
//
//  Created by nakajimashunta on 2017/10/22.
//  Copyright © 2017年 ShuntaNakajima. All rights reserved.
//

import UIKit
import FileKit
import AVKit
import AVFoundation

class FilerViewController: UIViewController ,UITableViewDelegate,UITableViewDataSource,UIGestureRecognizerDelegate,AVAudioPlayerDelegate,Modaldelegate{
    @IBOutlet var tableview:UITableView!
    var contents = [Path]()
    var thumbles = [Path:UIImage]()
    var path : Path = ""
    var editmode:Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()
        self.editButtonItem.title = "Edit"
        self.navigationItem.rightBarButtonItem = self.editButtonItem
        tableview.delegate = self
        tableview.dataSource = self
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(FilerViewController.cellLongPressed(recognizer:)))
        longPressRecognizer.delegate = self
        tableview.addGestureRecognizer(longPressRecognizer)

        tableview.allowsMultipleSelectionDuringEditing = true
        tableview.register(UINib(nibName: "FilerTableViewCell", bundle: nil), forCellReuseIdentifier: "Mycell")
        didclose()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        didclose()
    }
    func didclose() {
        contents = []
        for file in self.path {
            if file.parent == path{
            contents.append(file)
            }
        }
        tableview.reloadData()
    }
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        if editmode == false {
            editmode = true
            self.editButtonItem.title = "Done"
        } else {
            if let selectedItem = self.tableview.indexPathsForSelectedRows {
                var selected = [Path]()
                for i in selectedItem{
                    selected.append(contents[i.row])
                }
                let secondView:modalViewController = self.storyboard!.instantiateViewController(withIdentifier: "modalview") as! modalViewController
                secondView.delegate = self
                secondView.filename = selected
                secondView.modalPresentationStyle = .custom
                secondView.transitioningDelegate = self
                self.present(secondView as UIViewController, animated: true, completion:nil)
            }
            editmode = false
            self.editButtonItem.title = "Edit"
        }
        tableview.isEditing = editmode
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contents.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Mycell",for: indexPath) as! FilerTableViewCell
        var directory: ObjCBool = ObjCBool(false)
        let exists: Bool = FileManager.default.fileExists(atPath: contents[indexPath.row].url.path, isDirectory: &directory)
        cell.FileImageView.image = UIImage(named:"File.png")
        cell.FileNameLabel.adjustsFontSizeToFitWidth = true
        if exists && directory.boolValue {
            cell.FileNameLabel.text = "\(contents[indexPath.row].fileName)"
            cell.FileImageView.image = UIImage(named:"Folder.png")
        }else{
            cell.FileNameLabel.text = contents[indexPath.row].fileName
            let bcf = ByteCountFormatter()
            bcf.allowedUnits = [.useMB,.useGB,.useKB,.useBytes]
            bcf.countStyle = .file
            cell.SizeLabel.text = bcf.string(fromByteCount: Int64(contents[indexPath.row].fileSize!))
            let urll = contents[indexPath.row].url
            if contents[indexPath.row].pathExtension == "mp4" || contents[indexPath.row].pathExtension == "mov"{
                if thumbles[contents[indexPath.row]] == nil{
            let asset = AVURLAsset(url: urll, options: nil)
            let imgGenerator = AVAssetImageGenerator(asset: asset)
            do {let cgImage = try imgGenerator.copyCGImage(at: CMTimeMake(0, 1), actualTime: nil)
                let uiImage = UIImage.init(cgImage: cgImage)
                cell.FileImageView.image = uiImage
                thumbles[contents[indexPath.row]] = uiImage
            }catch{}
            }else{
                cell.FileImageView.image = thumbles[contents[indexPath.row]]
            }
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if editmode == false{
            //edit mode off
        var directory: ObjCBool = ObjCBool(false)
        let exists: Bool = FileManager.default.fileExists(atPath: contents[indexPath.row].url.path, isDirectory: &directory)
        if exists && directory.boolValue {
            let nextView = storyboard?.instantiateViewController(withIdentifier: "Filer") as! FilerViewController
            nextView.path = contents[indexPath.row]
            self.navigationController?.pushViewController(nextView, animated: true)
        }else if contents[indexPath.row].pathExtension == "mp4"{
            let videoPlayer = AVPlayer(url: contents[indexPath.row].url)
            let playerController = AVPlayerViewController()
            playerController.player = videoPlayer
            self.present(playerController, animated: true, completion: {
                videoPlayer.play()
            })
        }
        }else{
           //edit mode on
            if let _ = self.tableview.indexPathsForSelectedRows {
                self.editButtonItem.title = "Select"
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        guard tableView.isEditing else { return }
        if let _ = self.tableview.indexPathsForSelectedRows {
            self.editButtonItem.title = "Select"
        } else {
            self.editButtonItem.title = "Done"
        }
    }

    @objc func cellLongPressed(recognizer: UILongPressGestureRecognizer){
        if editmode == false{
        let point = recognizer.location(in: tableview)
        let indexPath = tableview.indexPathForRow(at: point)
        if indexPath == nil {} else if recognizer.state == UIGestureRecognizerState.began  {
            let secondView:modalViewController = self.storyboard!.instantiateViewController(withIdentifier: "modalview") as! modalViewController
            secondView.delegate = self
            secondView.filename = [contents[indexPath!.row]]
            secondView.modalPresentationStyle = .custom
            secondView.transitioningDelegate = self
            self.present(secondView as UIViewController, animated: true, completion:nil)
        }
        }
    }
    @IBAction func createnewdirectory(){
        let alert:UIAlertController = UIAlertController(title:"Enter new folder name",message: "",preferredStyle: UIAlertControllerStyle.alert)
        let cancelAction:UIAlertAction = UIAlertAction(title: "Cancel",style: UIAlertActionStyle.cancel,handler:{(action:UIAlertAction!) -> Void in
        })
        let defaultAction:UIAlertAction = UIAlertAction(title: "OK",style: UIAlertActionStyle.default,handler:{(action:UIAlertAction!) -> Void in
            let textFields:Array<UITextField>? =  alert.textFields as Array<UITextField>?
            let newname = self.path + textFields![0].text!
            if textFields != nil {
                do{try newname.createDirectory()}catch{}
                self.didclose()
            }
        })
        alert.addAction(cancelAction)
        alert.addAction(defaultAction)
        alert.addTextField(configurationHandler: {(text:UITextField!) -> Void in
            text.placeholder = "Enter new folder name"
        })
        present(alert, animated: true, completion: nil)
    }
}
extension FilerViewController: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return customPresent(presentedViewController: presented, presenting: presenting)
    }
}
class customPresent:UIPresentationController{
    var overlayView = UIView()
    override func presentationTransitionWillBegin() {
        guard let containerView = containerView else {
            return
        }
        
        overlayView.frame = containerView.bounds
        overlayView.backgroundColor = UIColor.black
        overlayView.alpha = 0.0
        containerView.insertSubview(overlayView, at: 0)
        
        
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { [weak self] context in
            self?.overlayView.alpha = 0.7
            }, completion: nil)
    }
    override func dismissalTransitionWillBegin() {
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { [weak self] context in
            self?.overlayView.alpha = 0.0
            }, completion: nil)
    }
    
    override func dismissalTransitionDidEnd(_ completed: Bool) {
        if completed {
            overlayView.removeFromSuperview()
        }
    }
    override func containerViewWillLayoutSubviews() {
        overlayView.frame = containerView!.bounds
        presentedView!.frame = frameOfPresentedViewInContainerView
    }

}
