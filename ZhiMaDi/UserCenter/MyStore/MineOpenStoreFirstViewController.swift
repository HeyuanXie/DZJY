//
//  MineOpenStoreFirstViewController.swift
//  ZhiMaDi
//
//  Created by admin on 16/12/8.
//  Copyright © 2016年 ZhiMaDi. All rights reserved.
//

import UIKit
//我要开店第一步
class MineOpenStoreFirstViewController: UIViewController,ZMDInterceptorProtocol,ZMDInterceptorStoreProtocol {

    @IBAction func openPersonalStore(sender: AnyObject) {
        let vc = MineOpenStoreSecondViewController.CreateFromStoreStoryboard() as! MineOpenStoreSecondViewController
        vc.contentType = .Personal
        self.pushToViewController(vc, animated: true, hideBottom: true)
    }
    
    @IBAction func openCompanyStore(sender: AnyObject) {
        let vc = MineOpenStoreSecondViewController.CreateFromStoreStoryboard() as! MineOpenStoreSecondViewController
        vc.contentType = .Company
        self.pushToViewController(vc, animated: true, hideBottom: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }

    
    //MARK: - **********PrivateMethod***********
    func initUI() {
        self.view.backgroundColor = defaultBackgroundColor
        
        let rightItem = UIBarButtonItem(title: "开店规则", style: .Plain, target: nil, action: nil)
        rightItem.rac_command = RACCommand(signalBlock: { (sender) -> RACSignal! in
            //...
            return RACSignal.empty()
        })
        rightItem.setTitleTextAttributes([NSFontAttributeName:UIFont.systemFontOfSize(14)], forState: .Normal)
        self.navigationItem.rightBarButtonItem = rightItem
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
