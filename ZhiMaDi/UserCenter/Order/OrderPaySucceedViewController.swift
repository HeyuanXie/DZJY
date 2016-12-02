//
//  OrderPaySucceedViewController.swift
//  ZhiMaDi
//
//  Created by haijie on 16/3/31.
//  Copyright © 2016年 ZhiMaDi. All rights reserved.
//

import UIKit
// 支付成功
class OrderPaySucceedViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,ZMDInterceptorProtocol,ZMDInterceptorMoreProtocol {
    var tableView : UITableView!
    var total = ""
    var person = ""
    var phoneNumber = ""
    var address1 = ""
    var address2 = ""
    var finished : (()->Void)!
    var isPayed = false

    override func viewDidLoad() {
        super.viewDidLoad()
        self.updateUI()
//        self.fetchData()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //MARK:- UITableViewDataSource,UITableViewDelegate
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 175
        } else if indexPath.row == 1 {
            return 102
        }
        return 56
    }
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headView = UIView(frame: CGRectMake(0, 0, kScreenWidth, 10))
        headView.backgroundColor = UIColor.clearColor()
        return headView
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cellId = "HeadCell"
            var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
            if cell == nil {
                cell = UITableViewCell(style: .Subtitle, reuseIdentifier: cellId)
                cell?.accessoryType = UITableViewCellAccessoryType.None
                cell!.selectionStyle = .None
                
                ZMDTool.configTableViewCellDefault(cell!)
            }
            cell?.contentView.backgroundColor = RGB(255,145,89,1.0)
            
            let imgV = UIImageView(frame: CGRect(x: kScreenWidth/2 - 57, y: 32, width: 94, height: 65))
            imgV.image = UIImage(named: "pay_express")
            cell?.contentView.addSubview(imgV)
            let topLbl = ZMDTool.getLabel(CGRect(x: 0, y: 32 + 65 + 23 , width: kScreenWidth, height: 18), text: "订单提交成功,等待卖家发货!", fontSize: 18)
            if self.isPayed == true {
                topLbl.text = "嘿嘿~你已付款成功！"
            }
            topLbl.textAlignment = .Center
            let botLbl = ZMDTool.getLabel(CGRect(x: 0, y: 32 + 65 + 23 + 18+8 , width: kScreenWidth, height: 16), text: "请等待卖家发货", fontSize: 16)
            botLbl.textAlignment = .Center
            cell?.contentView.addSubview(topLbl)
            cell?.contentView.addSubview(botLbl)
            return cell!
        }else if indexPath.row == 1 {
            let cellId = "msgCell"
            var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
            if cell == nil {
                cell = UITableViewCell(style: .Subtitle, reuseIdentifier: cellId)
                cell?.accessoryType = UITableViewCellAccessoryType.None
                cell!.selectionStyle = .None
                ZMDTool.configTableViewCellDefault(cell!)
                
                cell?.addSubview(ZMDTool.getLine(CGRect(x: 0, y: 101.5, width: kScreenWidth, height: 0.5)))
                
                var tag = 10001
                let userLbl = ZMDTool.getLabel(CGRect(x: 12, y: 16, width: 300, height: 17), text: "", fontSize: 17)
                userLbl.tag = tag++
                cell?.contentView.addSubview(userLbl)
                let phoneLbl = ZMDTool.getLabel(CGRect(x: kScreenWidth - 12 - 120, y: 16, width: 300, height: 17), text: "", fontSize: 17)
                phoneLbl.tag = tag++
                cell?.contentView.addSubview(phoneLbl)
                let addressStr = ""
                let addressSize = addressStr.sizeWithFont(defaultSysFontWithSize(17), maxWidth: kScreenWidth - 24)
                let addressLbl = ZMDTool.getLabel(CGRect(x: 12, y: 16 + 17 + 15, width: kScreenWidth - 24, height: addressSize.height), text: addressStr, fontSize: 17)
                addressLbl.numberOfLines = 2
                addressLbl.tag = tag++
                cell?.contentView.addSubview(addressLbl)
            }
            var tag = 10001
            let userLbl = cell?.viewWithTag(tag++) as! UILabel
            let phoneLbl = cell?.viewWithTag(tag++) as! UILabel
            let addressLbl = cell?.viewWithTag(tag++) as! UILabel
        
            userLbl.text = "收货人 ：\(self.person)"
            phoneLbl.text = "\(self.phoneNumber)"
            addressLbl.text = "收货地址:\(self.address1)\(self.address2)"
            let addressStr = addressLbl.text
            let addressSize = addressStr!.sizeWithFont(defaultSysFontWithSize(17), maxWidth: kScreenWidth - 24)
            addressLbl.frame = CGRect(x: 12, y: 16 + 17 + 15, width: kScreenWidth - 24, height: addressSize.height)

            return cell!
        } else if indexPath.row == 2 {
            let cellId = "totalCell"
            var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
            if cell == nil {
                cell = UITableViewCell(style: .Subtitle, reuseIdentifier: cellId)
                cell?.accessoryType = UITableViewCellAccessoryType.None
                cell!.selectionStyle = .None
                
                ZMDTool.configTableViewCellDefault(cell!)
                
                let botLbl = ZMDTool.getLabel(CGRect(x: 12, y: 0 , width: kScreenWidth, height: 55.5), text: "实付：0.0 获得0积分", fontSize: 16)
                botLbl.tag = 10001
                cell?.contentView.addSubview(botLbl)
                
                cell?.addSubview(ZMDTool.getLine(CGRect(x: 0, y: 55.5, width: kScreenWidth, height: 0.5)))
            }
            let botLbl = cell?.viewWithTag(10001) as! UILabel
            botLbl.attributedText = ((self.isPayed ? "实付: " : "应付: ") + "¥\(self.total)").AttributedText("¥\(self.total)", color: defaultSelectColor)
            return cell!
        }else {
            let cellId = "botCell"
            var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
            if cell == nil {
                cell = UITableViewCell(style: .Default, reuseIdentifier: cellId)
                cell?.selectionStyle = .None
                ZMDTool.configTableViewCellDefault(cell!)
                
                let titles = ["查看订单","继续购物"]
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
                            //查看订单
                            let vc = MyOrderViewController.CreateFromMainStoryboard() as! MyOrderViewController
                            vc.orderStatuId = 0
                            vc.orderStatusIndex = 0
                            vc.hidesBottomBarWhenPushed = true
                            self.navigationController?.pushViewController(vc, animated: true)
                        } else {
                            //继续购物
                            ZMDTool.enterHomePageViewController()
                        }
                        return RACSignal.empty()
                    })
                    cell?.contentView.addSubview(btn)
                    i++
                }
            }
            return cell!
        }
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        /*let homeBuyListViewController = HomeBuyListViewController.CreateFromMainStoryboard() as! HomeBuyListViewController
        self.navigationController?.pushViewController(homeBuyListViewController, animated: true)*/
        
    }
    //MARK: -  PrivateMethod
    func updateUI() {
        tableView = UITableView(frame: self.view.bounds)
        tableView.backgroundColor = tableViewdefaultBackgroundColor
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        self.view.addSubview(tableView)
    }
    override func back() {
        if self.finished != nil {
            self.finished()
        } else {
            super.back()
        }
    }
    
    //多店支付没有orderId，不通过fetchData获得订单信息
    /*func fetchData() {
        QNNetworkTool.orderDetail(self.orderId) { (succeed, dictionary, error) -> Void in
            if succeed!  {
                self.dic = dictionary
                self.tableView.reloadData()
            }
        }
    }*/
}
