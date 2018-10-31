//
//  modalViewController.swift
//  vivi
//
//  Created by nakajimashunta on 2017/11/03.
//  Copyright © 2017年 ShuntaNakajima. All rights reserved.
//

import UIKit
import FileKit
import Photos

@objc protocol Modaldelegate {
    @objc optional func didclose()
    @objc optional func didclosedownload()
    @objc optional func didclosedownloadcustom()
}

class modalViewController: UIViewController,UITableViewDelegate,UITableViewDataSource, UIGestureRecognizerDelegate {
    
    var menuone = ["Rename","Copy","Move","Delete","Save to Camera Roll"]
    let menumulti = ["Copy","Move","Delete"]
    var downloaditem = [URL]()
    @IBOutlet var tableview:UITableView!
    @IBOutlet var filenameLabel:UILabel!
    var filename = [Path]()
    var delegate: Modaldelegate?
    var downloadfile = Path()
    var custom = false
    override func viewDidLoad() {
        super.viewDidLoad()
        tableview.bounces = false
        tableview.delegate = self
        tableview.dataSource = self
        let rec = UITapGestureRecognizer(target: self, action: #selector(self.overlayViewDidTouch(sender:)))
        rec.cancelsTouchesInView = false
        rec.delegate = self
        self.view.gestureRecognizers = [rec]
        tableview.translatesAutoresizingMaskIntoConstraints = true
        filenameLabel.translatesAutoresizingMaskIntoConstraints = true
        filenameLabel.adjustsFontSizeToFitWidth = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if downloadfile != Path(){
            if downloaditem.count <= 6{
            tableview.frame = CGRect(x: 10, y:UIScreen.main.bounds.height - CGFloat(44 * downloaditem.count), width: UIScreen.main.bounds.width - 20, height: CGFloat(44 * downloaditem.count ))
            }else{
                tableview.frame = CGRect(x: 10, y:UIScreen.main.bounds.height - CGFloat(44 * 6) + 16, width: UIScreen.main.bounds.width - 20, height: CGFloat(44 * 6 - 16))
            }
            filenameLabel.frame = CGRect(x: 10, y:tableview.frame.origin.y - 55, width: UIScreen.main.bounds.width - 20, height: 40)
            filenameLabel.text = "We found \(downloaditem.count) movies in this web site."
        }else if filename.count == 1{
            if filename[0].pathExtension != "mp4" && filename[0].pathExtension != "jpg" && filename[0].pathExtension != "png" && filename[0].pathExtension != "jpeg" && filename[0].pathExtension != "mov"{
                menuone.remove(at: menuone.count - 1)
            }
             tableview.frame = CGRect(x: 10, y:UIScreen.main.bounds.height - CGFloat(44 * menuone.count), width: UIScreen.main.bounds.width - 20, height: CGFloat(44 * menuone.count))
            filenameLabel.frame = CGRect(x: 10, y:tableview.frame.origin.y - 55, width: UIScreen.main.bounds.width - 20, height: 40)
            filenameLabel.text = filename[0].fileName
        }else{
            tableview.frame = CGRect(x: 10, y:UIScreen.main.bounds.height - CGFloat(44 * menumulti.count), width: UIScreen.main.bounds.width - 20, height: CGFloat(44 * menuone.count))
            filenameLabel.frame = CGRect(x: 10, y:tableview.frame.origin.y - 55, width: UIScreen.main.bounds.width - 20, height: 40)
            filenameLabel.text = "\(filename.count)項目"
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if downloadfile != Path(){return downloaditem.count}else if filename.count == 1{return menuone.count}else{return menumulti.count}
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:UITableViewCell = UITableViewCell(style: .default, reuseIdentifier: "MyCell")
        print(indexPath.row)
        if downloadfile != Path(){cell.textLabel?.text = String(describing: downloaditem[indexPath.row])
            cell.textLabel?.adjustsFontSizeToFitWidth = true
        }else if filename.count == 1{cell.textLabel?.text = menuone[indexPath.row]}else{cell.textLabel?.text = menumulti[indexPath.row]}
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if downloadfile != Path(){
            self.dismiss(animated: true, completion: nil)
            if let navigationController = self.presentingViewController as? UINavigationController,
                let controller = navigationController.topViewController as? BrowserViewController {
                if custom == false{
                controller.didclosedownload(url:downloaditem[indexPath.row],path:downloadfile)
                }else{
                    controller.didclosedownloadcustom(url:downloaditem[indexPath.row],path:downloadfile)
                }
            }
        }else if filename.count == 1{
        if menuone[indexPath.row] == "Rename"{
            let alert:UIAlertController = UIAlertController(title:"Entername",message: "",preferredStyle: UIAlertControllerStyle.alert)
            let cancelAction:UIAlertAction = UIAlertAction(title: "Cancel",style: UIAlertActionStyle.cancel,handler:{(action:UIAlertAction!) -> Void in
            })
            let defaultAction:UIAlertAction = UIAlertAction(title: "OK",style: UIAlertActionStyle.default,handler:{(action:UIAlertAction!) -> Void in
                let textFields:Array<UITextField>? =  alert.textFields as Array<UITextField>?
                let newname = self.filename[0].parent + textFields![0].text!
                if textFields != nil {
                    do{try self.filename[0].moveFile(to: newname)}catch{}
                    self.overlayViewDidTouch(sender: "")
                }
            })
            alert.addAction(cancelAction)
            alert.addAction(defaultAction)
            alert.addTextField(configurationHandler: {(text:UITextField!) -> Void in
                text.text = self.filename[0].fileName
            })
            present(alert, animated: true, completion: nil)
        }else if menuone[indexPath.row] == "Copy"{
            self.dismiss(animated: true, completion: nil)
            setfiler(mode: .copy)
        }else if menuone[indexPath.row] == "Move"{
            self.dismiss(animated: true, completion: nil)
            setfiler(mode: .move)
        }else if menuone[indexPath.row] == "Delete"{
            let alert:UIAlertController = UIAlertController(title:"Delete?",message: "Do you want delete file '\(filename[0].fileName)'",preferredStyle: UIAlertControllerStyle.alert)
            let cancelAction:UIAlertAction = UIAlertAction(title: "Cancel",style: UIAlertActionStyle.cancel,handler:{(action:UIAlertAction!) -> Void in
            })
            let defaultAction:UIAlertAction = UIAlertAction(title: "OK",style: UIAlertActionStyle.default,handler:{(action:UIAlertAction!) -> Void in
                    do{try self.filename[0].deleteFile()}catch{}
                    self.overlayViewDidTouch(sender: "")
            })
            alert.addAction(cancelAction)
            alert.addAction(defaultAction)
            present(alert, animated: true, completion: nil)
        }else if menuone[indexPath.row] == "Save to Camera Roll"{
            print(self.filename[0].url)
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: self.filename[0].url)
            }) { saved, error in
                if saved {
                    let alertController = UIAlertController(title: "Saved to Camera Roll", message: nil, preferredStyle: .alert)
                    let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alertController.addAction(defaultAction)
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
        }else{
            if menumulti[indexPath.row] == "Copy"{
                self.dismiss(animated: true, completion: nil)
                setfiler(mode: .copy)
            }else if menumulti[indexPath.row] == "Move"{
                self.dismiss(animated: true, completion: nil)
                setfiler(mode: .move)
            }else if menumulti[indexPath.row] == "Delete"{
                let alert:UIAlertController = UIAlertController(title:"Delete?",message: "Do you want delete file '\(filename.count)項目'",preferredStyle: UIAlertControllerStyle.alert)
                let cancelAction:UIAlertAction = UIAlertAction(title: "Cancel",style: UIAlertActionStyle.cancel,handler:{(action:UIAlertAction!) -> Void in
                })
                let defaultAction:UIAlertAction = UIAlertAction(title: "OK",style: UIAlertActionStyle.default,handler:{(action:UIAlertAction!) -> Void in
                    for file in self.filename{
                    do{try file.deleteFile()}catch{}
                    }
                    self.overlayViewDidTouch(sender: "")
                })
                alert.addAction(cancelAction)
                alert.addAction(defaultAction)
                present(alert, animated: true, completion: nil)
            }
        }
    }
    
    @objc func overlayViewDidTouch(sender: Any) {
        self.dismiss(animated: true, completion: nil)
        if let navigationController = self.presentingViewController as? UINavigationController,
        let controller = navigationController.topViewController as? FilerViewController {
            controller.didclose()
        }
    }
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool
    {
        if (touch.view?.isDescendant(of: tableview))! {
            return false
        }
        return true
    }
    func didclose() {
        
    }
    
    func setfiler(mode:Modes){
        let secondView:directoryfilerViewController = self.storyboard!.instantiateViewController(withIdentifier: "directoryview") as! directoryfilerViewController
        secondView.filename = filename
        secondView.modalPresentationStyle = .custom
        secondView.transitioningDelegate = self
        secondView.mode = mode
        if let navigationController = self.presentingViewController as? UINavigationController,
            let controller = navigationController.topViewController as? FilerViewController {
            controller.present(secondView as UIViewController, animated: true, completion:nil)
        }
    }
}
extension modalViewController: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return customPresent(presentedViewController: presented, presenting: presenting)
    }
}
