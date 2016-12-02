//
//  DiscountCardViewController.swift
//  ZhiMaDi
//
//  Created by haijie on 16/6/6.
//  Copyright © 2016年 ZhiMaDi. All rights reserved.
//

import UIKit
// 确认订单-优惠券
class DiscountCardViewController: UIViewController,UITableViewDataSource, UITableViewDelegate,ZMDInterceptorProtocol {
    var currentTableView: UITableView!
    var manageBtn : UIButton!
    var coupons = NSArray()                         // 优惠券
    var finished : ((couponcode:String)->Void)!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.updateUI()
        self.updateData()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //MARK:- UITableViewDataSource,UITableViewDelegate
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.coupons.count
    }
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 16
    }
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return  0
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return  88
    }
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headView = UIView(frame: CGRectMake(0, 0, kScreenWidth, 16))
        headView.backgroundColor = UIColor.clearColor()
        return headView
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellId = "CardCell"
        var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
        if cell == nil {
            cell = UITableViewCell(style: .Subtitle, reuseIdentifier: cellId)
            cell?.accessoryType = UITableViewCellAccessoryType.None
            cell!.selectionStyle = .None
            cell!.contentView.backgroundColor = tableViewdefaultBackgroundColor
            
            
            let bgV = UIImageView(frame: CGRect(x: 12, y: 0, width: kScreenWidth - 24, height: 88))
            bgV.tag = 100000
            bgV.backgroundColor = UIColor.clearColor()
            cell?.contentView.addSubview(bgV)
            let titleLbl = ZMDTool.getLabel(CGRect(x: 112, y: 15, width: 200, height: 15), text: "", fontSize: 15)
            titleLbl.tag = 100002
            cell?.contentView.addSubview(titleLbl)
            let conditionLbl = ZMDTool.getLabel(CGRect(x: 112, y: 30+6, width: kScreenWidth-112-60, height: 13), text: "", fontSize: 13,textColor: defaultDetailTextColor)
            conditionLbl.tag = 100003
            cell?.contentView.addSubview(conditionLbl)
            let cardTermLbl = ZMDTool.getLabel(CGRect(x: 112, y: 36+13+16, width: kScreenWidth-112-12, height: 13), text: "", fontSize: 13,textColor: defaultDetailTextColor)
            cardTermLbl.tag = 100004
            
            cell?.contentView.addSubview(cardTermLbl)
            
            let typeImgV = UIImageView(frame: CGRect(x: kScreenWidth-12-16-20, y: 0, width: 20, height: 60))
            typeImgV.tag = 100005
            cell?.contentView.addSubview(typeImgV)
        }
        let bgV = cell?.viewWithTag(100000) as! UIImageView
        let titleLbl = cell?.viewWithTag(100002) as! UILabel
        let conditionLbl = cell?.viewWithTag(100003) as! UILabel
        let cardTermLbl = cell?.viewWithTag(100004) as! UILabel
        let typeImgV = cell?.viewWithTag(100005) as! UIImageView
        
        ZMDTool.configViewLayer(bgV)
        bgV.contentMode = .ScaleToFill
        
        let coupon = self.coupons[indexPath.section] as! ZMDCoupon
        if coupon.Discount.Name != nil {
            titleLbl.text = coupon.Discount.Name
            conditionLbl.text = coupon.Discount.Explain
            let starts = coupon.Discount.StartDateUtc!.componentsSeparatedByString("T")[0].stringByReplacingOccurrencesOfString("-", withString: ".")
            let ends = coupon.Discount.EndDateUtc!.componentsSeparatedByString("T")[0].stringByReplacingOccurrencesOfString("-", withString: ".")
            cardTermLbl.text = "使用期限 ：\(starts)-\(ends)"
            let formatter = NSDateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let date = formatter.dateFromString(coupon.Discount.EndDateUtc!.stringByReplacingOccurrencesOfString("T", withString: " "))
            if NSDate().compare(date!) == .OrderedDescending {
                // 小于
                bgV.image = UIImage(named: "user_coupon_invaild")
            } else {
                bgV.image = UIImage(named: "user_coupon")
                typeImgV.image =  UIImage(named: "user_coupon_tip")
            }
        }
        return cell!

    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let coupon = self.coupons[indexPath.section] as! ZMDCoupon
        self.finished(couponcode: coupon.CouponCode!)
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    //MARK: -  PrivateMethod
    func updateUI() {
        self.title = "卡券"
        self.currentTableView = UITableView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: self.view.bounds.size.height-64))
        self.currentTableView.backgroundColor = tableViewdefaultBackgroundColor
        self.currentTableView.separatorStyle = .None
        self.currentTableView.dataSource = self
        self.currentTableView.delegate = self
        self.view.addSubview(self.currentTableView)
    }
    func updateData() {
        QNNetworkTool.fetchCustomerCouponsForOrder { (coupons, dictionary, error) -> Void in
            if coupons != nil {
                self.coupons = coupons!
                if self.coupons.count == 0 {
                    ZMDTool.showPromptView("暂时没有可用的优惠券!")
                } else {
                    self.currentTableView.reloadData()
                }
            }
        }
    }
}
