//
//  directoryfilerViewController.swift
//  vivi
//
//  Created by nakajimashunta on 2017/11/03.
//  Copyright © 2017年 ShuntaNakajima. All rights reserved.
//

import UIKit
import FileKit

enum Modes{
    case copy
    case move
    case download
}
class directoryfilerViewController: UIViewController,UITableViewDelegate,UITableViewDataSource, UIGestureRecognizerDelegate {
    @IBOutlet var tableview:UITableView!
    @IBOutlet var DirectoryLabel:UILabel!
    @IBOutlet var cancelButton:UIButton!
    @IBOutlet var doneButton:UIButton!
    @IBOutlet var upButton:UIButton!
    @IBOutlet var newDirectoryButton:UIButton!
    var contents = [Path]()
    var filename = [Path]()
    var oldfileplace = [Path]()
    var mode:Modes = .copy
    var downloadURL = URL(string:"")
    var downloader = Downloader()
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
        DirectoryLabel.translatesAutoresizingMaskIntoConstraints = true
        DirectoryLabel.adjustsFontSizeToFitWidth = true
        DirectoryLabel.text = "/"
        if filename[0].parent == Path.userDocuments{
            upButton.isEnabled = false
        }
        oldfileplace = filename
        filename = [filename[0].parent]
        getdirectory(path: filename)
        tableview.reloadData()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        cancelButton.frame = CGRect(x: 10, y:UIScreen.main.bounds.height - 80, width: (UIScreen.main.bounds.width - 30)/2, height: 70)
        doneButton.frame = CGRect(x: 20 + (UIScreen.main.bounds.width - 30)/2, y:UIScreen.main.bounds.height - 80, width: (UIScreen.main.bounds.width - 30)/2, height: 70)
        tableview.frame = CGRect(x: 10, y:UIScreen.main.bounds.height - 290, width: UIScreen.main.bounds.width - 20, height: 200)
        DirectoryLabel.frame = CGRect(x: 10, y:UIScreen.main.bounds.height - 370, width: UIScreen.main.bounds.width - 20, height: 30)
        upButton.frame = CGRect(x: 10, y:UIScreen.main.bounds.height - 330, width: UIScreen.main.bounds.width - 20, height: 40)
        newDirectoryButton.frame = CGRect(x: UIScreen.main.bounds.width - 180, y:20, width: 170, height: 40)
    }
    
    func getdirectory(path:[Path]){
        DirectoryLabel.text = "/"
        contents = []
//        contents.append(path.parent)
        let pathh = path[0]
        for file in pathh{
            var directory: ObjCBool = ObjCBool(false)
            let exists: Bool = FileManager.default.fileExists(atPath: file.url.path, isDirectory: &directory)
            if exists && directory.boolValue {
                if file.parent == pathh{
                contents.append(file)
                }
            }
        }
        var collect = 0
        for file in pathh.components{
            if file == "Documents"{
                collect = 1
            }else if collect == 1{
                DirectoryLabel.text = DirectoryLabel.text! + file.fileName + "/"
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        upButton.isEnabled = true
        filename[0] = contents[indexPath.row]
        getdirectory(path: [contents[indexPath.row]])
        tableView.reloadData()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contents.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:UITableViewCell = UITableViewCell(style: .default, reuseIdentifier: "MyCell")
            cell.textLabel?.text = contents[indexPath.row].fileName
        return cell
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
        }else if (touch.view?.isDescendant(of: doneButton))! {
            return false
        }else if (touch.view?.isDescendant(of: upButton))! {
            return false
        }else if (touch.view?.isDescendant(of: newDirectoryButton))! {
            return false
        }
        return true
    }
    @IBAction func copys(){
        if mode == .copy{
            for file in oldfileplace{
        do{try file.copyFile(to: filename[0] + file.fileName)}catch{}
            }
      overlayViewDidTouch(sender: "")
        }else if mode == .move{
            for file in oldfileplace{
                do{try file.moveFile(to: filename[0] + file.fileName)}catch{}
            }
            overlayViewDidTouch(sender: "")
        }else if mode == .download{
            let alert:UIAlertController = UIAlertController(title:"Enter name",message: "",preferredStyle: UIAlertControllerStyle.alert)
            let cancelAction:UIAlertAction = UIAlertAction(title: "Cancel",style: UIAlertActionStyle.cancel,handler:{(action:UIAlertAction!) -> Void in
            })
            let defaultAction:UIAlertAction = UIAlertAction(title: "OK",style: UIAlertActionStyle.default,handler:{(action:UIAlertAction!) -> Void in
                let textFields:Array<UITextField>? =  alert.textFields as Array<UITextField>?
                let newname = self.filename[0] + textFields![0].text!
                if textFields != nil {
                    self.downloader.download(url: self.downloadURL!, name: newname)
                    self.dismiss(animated: true, completion: nil)
                }
            })
            alert.addAction(cancelAction)
            alert.addAction(defaultAction)
            alert.addTextField(configurationHandler: {(text:UITextField!) -> Void in
                text.text = self.downloadURL?.lastPathComponent
            })
            present(alert, animated: true, completion: nil)
        }
    }
    @IBAction func up(){
        if filename[0] == Path.userDocuments{
            upButton.isEnabled = false
        }
        filename = [filename[0].parent]
        getdirectory(path: filename)
        tableview.reloadData()
    }
    @IBAction func createDirectory(){
        let alert:UIAlertController = UIAlertController(title:"Enter new folder name",message: "",preferredStyle: UIAlertControllerStyle.alert)
        let cancelAction:UIAlertAction = UIAlertAction(title: "Cancel",style: UIAlertActionStyle.cancel,handler:{(action:UIAlertAction!) -> Void in
        })
        let defaultAction:UIAlertAction = UIAlertAction(title: "OK",style: UIAlertActionStyle.default,handler:{(action:UIAlertAction!) -> Void in
            let textFields:Array<UITextField>? =  alert.textFields as Array<UITextField>?
            let newname = self.filename[0] + textFields![0].text!
            if textFields != nil {
                do{try newname.createDirectory()}catch{}
                self.getdirectory(path: self.filename)
                if let navigationController = self.presentingViewController as? UINavigationController,
                    let controller = navigationController.topViewController as? FilerViewController {
                    controller.didclose()
                }
                self.tableview.reloadData()
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
