//
//  InvitatinCodeViewController.swift
//  ZhiMaDi
//
//  Created by haijie on 16/4/14.
//  Copyright © 2016年 ZhiMaDi. All rights reserved.
//

import UIKit
// 二维码邀请
class InvitatinCodeViewController: UIViewController,QNShareViewDelegate,ZMDInterceptorProtocol,ZMDInterceptorMoreProtocol{

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    //MARK: QNShareViewDelegate
    func qnShareView(view: ShareView) -> (image: UIImage, url: String, title: String?, description: String)? {
        return (UIImage(named: "Share_Icon")!, "http://www.baidu.com", self.title ?? "", "成为喜特用户，享有更多服务!")
    }
    func present(alert: UIAlertController) -> Void {
        self.presentViewController(alert, animated: false, completion: nil)
    }
    //MARK: - Action
    @IBAction func saveBtnCli(sender: UIButton) {
        UIImageWriteToSavedPhotosAlbum(UIImage(named: "user_interview_QRcode")!, nil, nil, nil)
    }
    @IBAction func shareBtnCli(sender: UIButton) {
        let shareView = ShareView()
        shareView.delegate = self
        shareView.showShareView()
    }
}
