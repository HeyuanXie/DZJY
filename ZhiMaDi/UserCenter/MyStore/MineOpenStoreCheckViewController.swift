//
//  MineOpenStoreCheckViewController.swift
//  ZhiMaDi
//
//  Created by admin on 16/12/8.
//  Copyright © 2016年 ZhiMaDi. All rights reserved.
//

import UIKit
//我要开店 审核中
class MineOpenStoreCheckViewController: UIViewController,ZMDInterceptorStoreProtocol {

    @IBOutlet weak var timeLbl : UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        let dateStr = QNFormatTool.dateString(NSDate(), format: "yyyy-MM-ddTHH:mm:ss+08:00").componentsSeparatedByString("T").first
        self.timeLbl.text = "提交审核日期 : \(dateStr!)"
        // Do any additional setup after loading the view.
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
