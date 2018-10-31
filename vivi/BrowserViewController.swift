//
//  BrowserViewController.swift
//  vivi
//
//  Created by nakajimashunta on 2017/10/22.
//  Copyright © 2017年 ShuntaNakajima. All rights reserved.
//

import UIKit
import WebKit
import YoutubeSourceParserKit
import Alamofire
import Kanna
import FileKit
import Reachability

class BrowserViewController: UIViewController,WKNavigationDelegate,UITextFieldDelegate,WKUIDelegate,Modaldelegate{
    @IBOutlet var webview:WKWebView!
    @IBOutlet var progressView:UIProgressView!
    @IBOutlet var downloadButton:UIButton!
    @IBOutlet var backButton:UIBarButtonItem!
    @IBOutlet var fowardButton:UIBarButtonItem!
    @IBOutlet var homeButton:UIBarButtonItem!
    @IBOutlet var bookmarkButton:UIBarButtonItem!
    @IBOutlet var reloadButton:UIBarButtonItem!
    @IBOutlet var textfield:UITextField!
    var doc : HTMLDocument!
    var downloadlink = [URL]()
    let downloader=Downloader()
    var lastloadDownloadlink = URL(string: "")
    override func viewDidLoad() {
        super.viewDidLoad()
        self.webview.addObserver(self, forKeyPath: "loading", options: .new, context: nil)
        self.webview.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
        self.progressView.isHidden = true
        self.downloadButton.isHidden = true
        let url = URL(string: "https://m.youtube.com/")
        let URLRequests = URLRequest(url:url!)
        self.webview.load(URLRequests)
        self.webview.allowsBackForwardNavigationGestures = true
        textfield.delegate = self
        webview.navigationDelegate = self
        textfield.text = "\(webview.url!)"
        textfield.clearButtonMode = .whileEditing
        webview.scrollView.bounces = false
        webview.uiDelegate = self
        let myLongPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.downloadCustom(sender:)))
        myLongPressGesture.cancelsTouchesInView = true
        downloadButton.addGestureRecognizer(myLongPressGesture)
        if let reachability = Reachability() {
            if reachability.connection == .none{
                let nextView = storyboard?.instantiateViewController(withIdentifier: "Filer") as! FilerViewController
                nextView.path = Path.userDocuments
                self.navigationController?.pushViewController(nextView, animated: true)
            }
        }
    }
    deinit{
        self.webview.removeObserver(self, forKeyPath: "estimatedProgress")
        self.webview.removeObserver(self, forKeyPath: "loading")
    }
    @objc func downloadCustom(sender: Any){
        let secondView:directoryfilerViewController = self.storyboard!.instantiateViewController(withIdentifier: "directoryview") as! directoryfilerViewController
        secondView.modalPresentationStyle = .custom
        secondView.transitioningDelegate = self
        secondView.mode = .download
        secondView.downloader = self.downloader
        if "\(webview.url!)".contains("https://m.youtube.com/"){
            Youtube.h264videosWithYoutubeURL(URL(string:"https://www.youtube.com/watch?v=\("\(webview.url!)".dictionaryFromQueryStringComponents()["https://m.youtube.com/watch?v"]!)")!) { (videoInfo, error) -> Void in
                if let videoURLString = videoInfo?["url"] as? String,
                    let videoTitle = videoInfo?["title"] as? String {
                    secondView.downloadURL = URL(string:videoURLString)!
                    var paths = Path.userDocuments + videoTitle
                    paths.pathExtension = "mp4"
                    secondView.filename = [paths]
                     self.present(secondView as UIViewController, animated: true, completion:nil)
                }
            }
        }else{
            var mypath = Path.userDocuments + webview.title!
            mypath.pathExtension = "mp4"
            self.downloaded(downloadfile: mypath,custom:true)
//            if "\(webview.url!)".contains("http://m.anitube.se"){
//                self.downloaded(downloadfile: Path.userDocuments + webview.title! + "." + webview.url!.pathExtension,custom:true)
//            }else{
//                self.downloaded(downloadfile: Path.userDocuments,custom:true)
//            secondView.filename = [Path.userDocuments + downloadlink!.lastPathComponent]
//            }
            //secondView.downloadURL = downloadlink!
             self.present(secondView as UIViewController, animated: true, completion:nil)
            
        }
        
    }
    
    func downloaded(downloadfile:Path,custom:Bool){
        let secondView:modalViewController = self.storyboard!.instantiateViewController(withIdentifier: "modalview") as! modalViewController
        secondView.delegate = self
        secondView.downloadfile = downloadfile
        secondView.downloaditem = downloadlink
        secondView.custom = custom
        secondView.modalPresentationStyle = .custom
        secondView.transitioningDelegate = self
        self.present(secondView as UIViewController, animated: true, completion:nil)
    }
    
    func didclosedownload(url:URL,path:Path) {
        downloader.download(url: url, name: path)
    }
    func didclosedownloadcustom(url:URL,path:Path) {
        let secondView:directoryfilerViewController = self.storyboard!.instantiateViewController(withIdentifier: "directoryview") as! directoryfilerViewController
        secondView.modalPresentationStyle = .custom
        secondView.transitioningDelegate = self
        secondView.mode = .download
        secondView.downloader = self.downloader
        secondView.filename = [path]
        secondView.downloadURL = url
        self.present(secondView as UIViewController, animated: true, completion:nil)
    }
    @IBAction func download(){
        if "\(webview.url!)".contains("https://m.youtube.com/"){
             Youtube.h264videosWithYoutubeURL(URL(string:"https://www.youtube.com/watch?v=\("\(webview.url!)".dictionaryFromQueryStringComponents()["https://m.youtube.com/watch?v"]!)")!) { (videoInfo, error) -> Void in
                if let videoURLString = videoInfo?["url"] as? String,
                    let videoTitle = videoInfo?["title"] as? String {
                    var paths = Path.userDocuments + videoTitle
                    paths.pathExtension = "mp4"
                    self.downloader.download(url: URL(string:videoURLString)!, name:paths)
                }
            }
        }else{
            if "\(webview.url!)".contains("http://m.anitube.se"){
                var mypath = Path.userDocuments + webview.title!
                mypath.pathExtension = "mp4"
                self.downloaded(downloadfile: mypath,custom:false)
               // downloader.download(url: downloadlink!, name: Path.userDocuments + webview.title! + "." + webview.url!.pathExtension)
            }else{
                var mypath = Path.userDocuments + webview.title!
                mypath.pathExtension = "mp4"
                print(mypath)
                self.downloaded(downloadfile: mypath,custom:false)
               // downloader.download(url: downloadlink!, name: Path.userDocuments + (downloadlink?.lastPathComponent)!)
            }
        }
    }
    
    @IBAction func back(){webview.goBack()}
    @IBAction func foward(){webview.goForward()}
    @IBAction func reload(){webview.reload()}
    @IBAction func toFiler(){
        let nextView = storyboard?.instantiateViewController(withIdentifier: "Filer") as! FilerViewController
        nextView.path = Path.userDocuments
        self.navigationController?.pushViewController(nextView, animated: true)
    }
    @IBAction func toDownloading(){
        let first = storyboard?.instantiateViewController(withIdentifier: "DownloadingView") as! DownloadingViewController
        first.downloader = self.downloader
        self.navigationController?.pushViewController(first, animated: true)
    }
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress"{
            self.progressView.isHidden = false
            self.progressView.setProgress(Float(self.webview.estimatedProgress), animated: true)
        }else if keyPath == "loading"{
            UIApplication.shared.isNetworkActivityIndicatorVisible = self.webview.isLoading
            if self.webview.isLoading {
                self.progressView.isHidden = false
                self.progressView.setProgress(0.1, animated: true)
            }else{
                self.progressView.isHidden = true
                self.progressView.setProgress(0.0, animated: true)
            }
        }
    }
    func generateDownloadLink(canpass: Bool){
        if webview.url != lastloadDownloadlink || canpass == true{
            downloadButton.isHidden = true
        lastloadDownloadlink = webview.url
        let request = NSMutableURLRequest(url: URL(string: "\(webview.url!)")!)
        let userAgent = UIWebView().stringByEvaluatingJavaScript(from: "navigator.userAgent")
        request.setValue(userAgent, forHTTPHeaderField: "User-Agent")
        var myhtml = ""
        DispatchQueue.global(qos: .default).async {
            do { myhtml = try String(contentsOf: request.url!, encoding: .utf8)}catch{}
            myhtml = myhtml.replacingOccurrences(of:"\\", with:"")
            print(myhtml)
            let test = myhtml.checkLink()
            var movies: [URL] = []
            var urls: [URL] = []
            for_urlss:for i in test{
                if i.pathExtension == "mp4"{
                    movies.append(i)
                }else
                    if i.pathExtension == "php" || i.pathExtension == "js" || i.pathExtension == "txt" || "\(i)".contains("config") || "\(i)".contains("1080p") || "\(i)".contains("720p") || "\(i)".contains("480p") || "\(i)".contains("360p") || "\(i)".contains("240p")
                    {
                    //if "\(i)".contains("ads") != true && i.pathExtension != "html" && i.pathExtension != "jpg" && i.pathExtension != "png" && i.pathExtension != "jpeg" && i.pathExtension != "gif"{
                    urls.append(i)
                    //}
                }
            }
            DispatchQueue.main.async {
                    let dispatchGroup = DispatchGroup()
                    let dispatchQueue = DispatchQueue(label: "queue", attributes: .concurrent)
                    print(urls)
                    for_urls: for url in urls{
                        dispatchGroup.enter()
                        dispatchQueue.async(group: dispatchGroup) { [] in
                            do { myhtml = try String(contentsOf: url, encoding: .utf8)}catch{}
                            myhtml = myhtml.replacingOccurrences(of:"\\", with:"")
                            let checklink = myhtml.checkLink()
                            print(checklink)
                            for i in checklink{
                                if i.pathExtension == "mp4"{
                                    movies.append(i)
                                }
                            }
                            dispatchGroup.leave()
                        }
                    }
                    dispatchGroup.notify(queue: .main) {
                        self.checkresult(movies: movies)
                    }
            }
        }
    }
    }
    func checkresult(movies: [URL]){
        if movies.isEmpty == false{
            print("result:" + String(describing: movies[0]))
            self.downloadlink = movies
        }
        print(movies)
        if "\(self.webview.url!)".contains("https://m.youtube.com/watch?v=") || movies.isEmpty == false{
            self.downloadButton.isHidden = false
        }
    }
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        print("start")
        downloadButton.isHidden = true
    }
    func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        let cred = URLCredential(trust: challenge.protectionSpace.serverTrust!)
        completionHandler(.useCredential, cred)
        textfield.text = "\(webview.url!)"
        generateDownloadLink(canpass: false)
    }
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("fail")
    }
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("finish")
        textfield.text = "\(webview.url!)"
        if webview.canGoBack {
            backButton.tintColor = nil
        } else {
            backButton.tintColor = UIColor.gray
        }
        if webview.canGoForward {
            fowardButton.tintColor = nil
        } else {
            fowardButton.tintColor = UIColor.gray
        }
        generateDownloadLink(canpass: true)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString text: String) -> Bool{
        if(text == "\n") {
            textField.resignFirstResponder()
            let url = checklink(url: textField.text!)
            if url == true{
                let urltext = textField.text!
                let encodedURL = urltext.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
                let URLRequests = URLRequest(url:URL(string: encodedURL!)!)
                self.webview.load(URLRequests)
                textfield.text = "\(webview.url!)"
            }else{
                let urltext = "https://www.google.com/search?q=" + textField.text!
                let encodedURL = urltext.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
                let URLRequests = URLRequest(url:URL(string: encodedURL!)!)
                self.webview.load(URLRequests)
                textfield.text = "\(webview.url!)"
            }
            return false
        }
        return true
    }
    func checklink(url:String) -> Bool{
        var result = false
        let types: NSTextCheckingResult.CheckingType = .link
        let detector = try? NSDataDetector(types: types.rawValue)
        guard let detect = detector else {
            return result
        }
        let matches = detect.matches(in: url, options: .reportCompletion, range: NSMakeRange(0, url.characters.count))
        for match in matches {
            if match.url != nil {
                result = true
            }
        }
        return result
    }
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        let url = navigationAction.request.url
        if url!.pathExtension == "mp4" || url!.pathExtension == "mp3" || url!.pathExtension == "pdf" || url!.pathExtension == "jpg" || url!.pathExtension == "jpeg" || url!.pathExtension == "mov" || url!.pathExtension == "ppt" || url!.pathExtension == "txt" || url!.pathExtension == "zip"{
            decisionHandler(.cancel)
            downloadlink = [url!]
            downloadCustom(sender: "")
        }else{
            if UIApplication.shared.canOpenURL(url!) == true || url! == URL(string:"about:blank"){
                if navigationAction.navigationType == .linkActivated{
                webView.load(URLRequest(url: url!))
                decisionHandler(.cancel)
                return
            }
                decisionHandler(.allow)
                return
    }
            decisionHandler(.allow)
    }
    }
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        guard let url = navigationAction.request.url else {
            return nil
        }
        
        guard let targetFrame = navigationAction.targetFrame, targetFrame.isMainFrame else {
            webView.load(URLRequest(url: url))
            return nil
        }
        return nil
    }
}
extension BrowserViewController: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return customPresent(presentedViewController: presented, presenting: presenting)
    }
}
extension String {
    func checkLink() -> [URL] {
        let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        let links = detector.matches(in: self, range: NSRange(location: 0, length: self.characters.count))
        let checked: [URL] = links.map{$0.url!}
        return checked
    }
}
