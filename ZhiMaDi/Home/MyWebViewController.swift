//
//  MyWebViewController.swift
//  ZhiMaDi
//
//  Created by admin on 16/9/8.
//  Copyright © 2016年 ZhiMaDi. All rights reserved.
//

import UIKit
import WebKit

class MyWebViewController: UIViewController {
    var webUrl :String!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initUI()
        self.loadWebView()
        // Do any additional setup after loading the view.
    }

    func initUI() {
        
        self.configBackButton()
        self.configMoreButton()
        
        UIApplication.sharedApplication().statusBarStyle = .Default
        let lbl = UILabel(frame: CGRect(x: 0, y: 0, width: 40, height: 20))
        lbl.text = APP_NAME
        lbl.font = UIFont.systemFontOfSize(17)
        lbl.textAlignment = .Center
        lbl.textColor = RGB(79/255,79/255,79/255,1)
        self.navigationItem.titleView = lbl
        
        self.navigationController?.navigationBar.barTintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.tintColor = UIColor.blackColor()
        ZMDTool.showActivityView(nil)
    }
    func loadWebView() {
        let wkUController = WKUserContentController()
        let jScript = "var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width'); document.getElementsByTagName('head')[0].appendChild(meta);"
        let wkUScript = WKUserScript(source: jScript, injectionTime: .AtDocumentEnd, forMainFrameOnly: true)
        wkUController.addUserScript(wkUScript)
        let wkWebConfig = WKWebViewConfiguration()
        wkWebConfig.userContentController = wkUController
        
        let webView = WKWebView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight-64), configuration: wkWebConfig)
        webView.scrollView.showsVerticalScrollIndicator = false
        webView.scrollView.showsHorizontalScrollIndicator = false
        let request = NSURLRequest(URL: NSURL(string: self.webUrl)!)
        webView.loadRequest(request)
        ZMDTool.hiddenActivityView()


        self.view.addSubview(webView)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
