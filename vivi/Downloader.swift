//
//  Downloader.swift
//  vivi
//
//  Created by nakajimashunta on 2017/10/23.
//  Copyright © 2017年 ShuntaNakajima. All rights reserved.
//

import Foundation
import UIKit
import FileKit

@objc protocol ViviDownloadDelegate {
    func didChangePercent(index:Int,percent:Float,downloadtask:URLSessionDownloadTask,min:Int64,max:Int64)
    func didFinishDownload(index:Int)
}
class Downloader:URLSessionDownloadTask,URLSessionDownloadDelegate{
    var saves = [URLSessionDownloadTask:Path]()
    var Downloading : [URLSessionDownloadTask] = []
    var delegate: ViviDownloadDelegate?
    func getDownloadingItems() -> [URLSessionDownloadTask]{
        return Downloading
    }
    func getDownloadingPaths() -> [URLSessionDownloadTask:Path]{
        return saves
    }
func download(url:URL,name:Path){
    let sessionConfig = URLSessionConfiguration.background(withIdentifier: "myapp-background")
    let session = URLSession(configuration: sessionConfig, delegate: self, delegateQueue: nil)
    let downloadTask = session.downloadTask(with: url)
    saves[downloadTask] = name
    print(name)
    Downloading.append(downloadTask)
    downloadTask.resume()
}
func getSaveDirectory() -> String {
    let fileManager = Foundation.FileManager.default
    let path = NSSearchPathForDirectoriesInDomains(Foundation.FileManager.SearchPathDirectory.documentDirectory, Foundation.FileManager.SearchPathDomainMask.userDomainMask, true)[0] + "/"
    if !fileManager.fileExists(atPath: path) {
        createDir(path: path)
    }
    return path
}

func createDir(path: String) {
    do {
        let fileManager = Foundation.FileManager.default
        try fileManager.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
    } catch let error as NSError {
        print("createDir: \(error)")
    }
}
func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
    print("didFinishDownloading")
    if let index = Downloading.index(of: downloadTask){
    Downloading.remove(at: index)
        self.delegate?.didFinishDownload(index: index)
    }
    do {
        if let data = NSData(contentsOf: location) {
            print(downloadTask.originalRequest?.url?.lastPathComponent)
            try data.write(to: saves[downloadTask]!)
            saves[downloadTask] = nil
        }
    } catch let error as NSError {
        print("download error: \(error)")
    }
}

func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
    let progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
    print(String(format: "%.2f", progress * 100) + "%")
    DispatchQueue.main.async(execute: {
        if let index = self.Downloading.index(of: downloadTask){
            self.delegate?.didChangePercent(index: index, percent: progress,downloadtask:downloadTask,min:totalBytesWritten,max: totalBytesExpectedToWrite)
        }
    })
}

func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
    if error != nil {
        print("download error: \(error)")
    }
}
}
