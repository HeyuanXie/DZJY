//
//  MineSupplyOrDemandViewController.swift
//  ZhiMaDi
//
//  Created by admin on 16/12/8.
//  Copyright © 2016年 ZhiMaDi. All rights reserved.
//

import UIKit
//我的供应（我的求购）
class MineSupplyOrDemandViewController: UIViewController {
    
    enum ContentType {
        case Supply,Demand
    }
    @IBOutlet weak var currentTableView : UITableView!
    var contentType = ContentType.Supply
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initUI()
        // Do any additional setup after loading the view.
    }

    
    //MARK: - ***************PrivateMethod******************
    func initUI() {
        self.title = self.contentType == .Supply ? "我的供应" : "我的求购"
        
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
