//
//  TradeSuccessedViewController.swift
//  ZhiMaDi
//
//  Created by admin on 16/8/25.
//  Copyright © 2016年 ZhiMaDi. All rights reserved.
//

import UIKit

class TradeSuccessedViewController: UIViewController, UITableViewDataSource, UITableViewDelegate,ZMDInterceptorMoreProtocol {
    enum CellType {
        case cellTypeHead;
        case cellTypeMenu;
        case cellTypeReccomend
    }
    
    var currentTableView :UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.updateUI()
        self.currentTableView.reloadData()
        
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
    }
    
    //MARK:UITableViewDelegate,UITableViewDataSource
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 4
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return kScreenWidth/2
        }else if indexPath.section == 1{
            return 56
        }else{
            return 325
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0{
            let cellId = "HeadCell"
            var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
            if cell == nil{
                cell = UITableViewCell(style: .Default, reuseIdentifier: cellId)
                let bgView = UIView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenWidth/2))
                bgView.backgroundColor = UIColor(red: 254/255, green: 154/255, blue: 96/255, alpha: 1)
                cell?.contentView.addSubview(bgView)
                let width = kScreenWidth/3,height = width
                let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: width, height: height))
                imageView.image = UIImage(named: "pay_box")
                imageView.center.x = self.view.center.x
                imageView.center.y = kScreenWidth/6
                bgView.addSubview(imageView)
                
                let lbl = ZMDTool.getLabel(CGRect(x: 0, y: CGRectGetMaxY(imageView.frame)+15, width: kScreenWidth, height: 20), text: "交易成功!", fontSize: 20, textColor: UIColor.whiteColor(), textAlignment: NSTextAlignment.Center)
                bgView.addSubview(lbl)
            }
            ZMDTool.configTableViewCellDefault(cell!)
            return cell!
        }else if indexPath.section == 1 {
            let cellId = "MenuCell"
            var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
            if cell == nil {
                cell = UITableViewCell(style: .Default, reuseIdentifier: cellId)
                let view = UIView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 56))
                view.backgroundColor = UIColor.whiteColor()
                cell?.contentView.addSubview(view)
                
                let titles = ["立即评价","继续购物"]
                let width = kScreenWidth*3/11,height = CGFloat(40)
                var i = 0
                for title in titles {
                    let btn = UIButton(frame: CGRect(x: CGFloat(i)*(width+kScreenWidth/11)+kScreenWidth*2/11, y: 8, width: width, height: height))
                    btn.tag = 1000 + i
                    btn.setTitle(title, forState: .Normal)
                    btn.setTitleColor(defaultTextColor, forState: .Normal)
                    ZMDTool.configViewLayer(btn)
                    ZMDTool.configViewLayerFrame(btn)
                    btn.rac_command = RACCommand(signalBlock: { (sender) -> RACSignal! in
                        if sender.tag == 1000 {
                            //立即评价
                            let vc = OrderGoodsScoreViewController()
                            vc.hidesBottomBarWhenPushed = true
                            self.navigationController?.pushViewController(vc, animated: true)
                        } else {
                            //继续购物
                            ZMDTool.enterHomePageViewController()
                        }
                        return RACSignal.empty()
                    })
                    view.addSubview(btn)
                    i++
                }
            }
            ZMDTool.configTableViewCellDefault(cell!)
            cell?.contentView.backgroundColor = UIColor.whiteColor()
            return cell!
        }else{
            let cellId = "DoubleGoodsTableViewCell"
            var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
            if cell == nil {
                cell = UITableViewCell(style: .Default, reuseIdentifier: cellId)
            }
            ZMDTool.configTableViewCellDefault(cell!)
            return cell!
        }
    }
    
    
    
    
    
    func updateUI(){
        self.title = "交易成功"
        self.currentTableView = UITableView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight), style: UITableViewStyle.Plain)
        self.currentTableView.delegate = self
        self.currentTableView.dataSource = self
        self.currentTableView.separatorStyle = .None
        self.view.addSubview(self.currentTableView)
        
        self.configMoreButton()
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
