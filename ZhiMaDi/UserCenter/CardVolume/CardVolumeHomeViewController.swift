//
//  CardVolumeHomeViewController.swift
//  ZhiMaDi
//
//  Created by haijie on 16/4/8.
//  Copyright © 2016年 ZhiMaDi. All rights reserved.
//

import UIKit
// 卡券
class CardVolumeHomeViewController: UIViewController,UITableViewDataSource, UITableViewDelegate,ZMDInterceptorProtocol,ZMDInterceptorMoreProtocol {
    enum CardType {
        case Consumer  // 消费券
        case Member
        init() {
            self = Consumer
        }
    }
    var currentTableView: UITableView!
    var manageBtn : UIButton!
    var memberArray = NSArray()
    var coupons = NSMutableArray()                         // 优惠券
    let cardTypeAll = [CardType.Consumer,.Member]
    var cardType = CardType()
    var isManage = false
    var consumerIds = NSMutableArray()
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
        return self.cardType == .Consumer ? self.coupons.count : self.memberArray.count
    }
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 16
    }
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return self.isManage ? 30 : 0
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return self.cardType == .Consumer ? 88 : 100
    }
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView?{
        if self.isManage {
            let view = UIView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 30))
            view.backgroundColor = UIColor.clearColor()
            let btn = ZMDTool.getButton(CGRect(x: kScreenWidth - 12 - 68, y: 0, width: 68, height: 30), textForNormal: "删除", fontSize: 15,backgroundColor: UIColor.clearColor(), blockForCli: { (sender) -> Void in
                if self.cardType == .Consumer {
                    let coupon = self.coupons[section] as! ZMDCoupon
                    if !(sender as! UIButton).selected {
                        coupon.indexForDelete = section
                        self.consumerIds.addObject(coupon)
                    } else {
                        self.consumerIds.removeAllObjects()
                    }
                    self.currentTableView.reloadData()
                }
            })
            btn.setImage(UIImage(named: "common_01unselected"), forState: .Normal)
            btn.setImage(UIImage(named: "common_02selected"), forState: .Selected)
            btn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
            view.addSubview(btn)
            btn.selected = false
            let currentItem = self.coupons[section] as! ZMDCoupon
            for tmp in self.consumerIds {
                if (tmp as! ZMDCoupon).Id == currentItem.Id {
                    btn.selected = true
                }
            }
            return view
        }
        let view = UIView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 0))
        return view
    }
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headView = UIView(frame: CGRectMake(0, 0, kScreenWidth, 16))
        headView.backgroundColor = UIColor.clearColor()
        return headView
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if self.cardType == .Member {
            let cellId = "MemberCell"
            var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
            if cell == nil {
                cell = UITableViewCell(style: .Subtitle, reuseIdentifier: cellId)
                cell?.accessoryType = UITableViewCellAccessoryType.None
                cell!.selectionStyle = .None
                cell!.contentView.backgroundColor = tableViewdefaultBackgroundColor
                
                
                let bgV = UIImageView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 100))
                bgV.tag = 100000
                bgV.backgroundColor = UIColor.clearColor()
                cell?.contentView.addSubview(bgV)
                let imgV = UIImageView(frame: CGRect(x: 34, y: 22, width: 60, height: 60))
                imgV.tag = 100001
                cell?.contentView.addSubview(imgV)
                let titleLbl = ZMDTool.getLabel(CGRect(x: 115, y: 32, width: 200, height: 18), text: "", fontSize: 18,textColor: UIColor.whiteColor())
                titleLbl.tag = 100002
                cell?.contentView.addSubview(titleLbl)
                let conditionLbl = ZMDTool.getLabel(CGRect(x: 115, y: 32+18+10, width: 200, height: 13), text: "", fontSize: 13,textColor: UIColor.whiteColor())
                conditionLbl.tag = 100003
                cell?.contentView.addSubview(conditionLbl)
                let vipCardLbl = ZMDTool.getLabel(CGRect(x: kScreenWidth-24-200, y:14, width: 200, height: 13), text: "", fontSize: 13,textColor: UIColor.whiteColor(),textAlignment: .Right)
                vipCardLbl.tag = 100004
                cell?.contentView.addSubview(vipCardLbl)
            }
            let bgV = cell?.viewWithTag(100000) as! UIImageView
            _ = cell?.viewWithTag(100001) as! UIImageView
            let titleLbl = cell?.viewWithTag(100002) as! UILabel
            let conditionLbl = cell?.viewWithTag(100003) as! UILabel
            let vipCardLbl = cell?.viewWithTag(100004) as! UILabel
            
            ZMDTool.configViewLayer(bgV)
            bgV.image = UIImage(named: "user_vipcard_bg")
            bgV.contentMode = .ScaleToFill
            titleLbl.text = "葫芦堡旗舰店"
            conditionLbl.text = "有效期：长期有效"
            vipCardLbl.text = "VIP 银卡"
            return cell!
        } else {
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
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if self.cardType == .Consumer {
            let coupon = self.coupons[indexPath.section] as! ZMDCoupon
            let vc = CardVolumeConsumerDetailViewController()
            vc.coupon = coupon
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            let vc = CardVolumeMemberDetailViewController()
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    //MARK: -  PrivateMethod
    func setNavigation() {
        let rightItem = UIButton(frame: CGRectMake(0, 0, 60, 44))
        rightItem.backgroundColor = UIColor.clearColor()
        rightItem.setTitle("已过期卡券", forState: .Normal)
        rightItem.titleLabel?.font = UIFont.systemFontOfSize(12)
        rightItem.setTitleColor(defaultDetailTextColor, forState: .Normal)
        rightItem.rac_command = RACCommand(signalBlock: { (sender) -> RACSignal! in
            ZMDTool.showPromptView("功能尚未开放")
            return RACSignal.empty()
        })
        let item = UIBarButtonItem(customView: rightItem)
        
        item.customView?.tintColor = defaultTextColor
//        self.navigationItem.rightBarButtonItem = item     //暂时隐藏
    }
    
    func segmentView() {
        let menuTitle = ["消费券","会员卡"]
        let customJumpBtns = CustomJumpBtns(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 55),menuTitle: menuTitle)
        customJumpBtns.backgroundColor = UIColor.whiteColor()
        customJumpBtns.addSeparatedLine()
        self.view.addSubview(customJumpBtns)
        customJumpBtns.finished = { (index) ->Void in
            self.cardType = self.cardTypeAll[index]
            self.currentTableView.reloadData()
        }
    }
    
    func botttomeViewForManage() -> UIView{
        let manageView = UIView(frame: CGRect(x:0, y: self.view.bounds.height - 64-58, width: kScreenWidth, height: 58))
        manageView.backgroundColor = RGB(247,247,247,1)
        let cancelBtn = ZMDTool.getButton(CGRect(x: kScreenWidth - 60, y: 0, width: 60, height: 58), textForNormal: "取消", fontSize: 17, backgroundColor:RGB(247,247,247,1)) { (sender) -> Void in
            manageView.alpha = 0.0
            self.manageBtn.alpha = 1.0
            self.isManage = !self.isManage
            self.currentTableView.reloadData()
        }
        manageView.addSubview(cancelBtn)
        let deleteBtn = ZMDTool.getButton(CGRect(x: kScreenWidth - 120, y: 0, width: 60, height: 58), textForNormal: "删除", fontSize: 17, backgroundColor:RGB(247,247,247,1)) { (sender) -> Void in
            if self.cardType == .Consumer {
                for tmp in self.consumerIds {
                    self.deleteCoupon((tmp as! ZMDCoupon).Id!.integerValue,indexPath:NSIndexPath(forItem: 0, inSection: (tmp as! ZMDCoupon).indexForDelete!))
                }
            }
        }
        manageView.addSubview(deleteBtn)
        
        let btn = ZMDTool.getButton(CGRect(x: 0, y: 0, width: 68, height: 58), textForNormal: "全选", fontSize: 15,backgroundColor: UIColor.clearColor(), blockForCli: { (sender) -> Void in
            (sender as! UIButton).selected = !(sender as! UIButton).selected
            if self.cardType == .Consumer {
                if (sender as! UIButton).selected {
                    var index = -1
                    for item in self.coupons {
                        index++
                        (item as! ZMDCoupon).indexForDelete = index
                        self.consumerIds.addObject(item)
                    }
                } else {
                    self.consumerIds.removeAllObjects()
                }
                self.currentTableView.reloadData()
            }
        })
        btn.setImage(UIImage(named: "common_01unselected"), forState: .Normal)
        btn.setImage(UIImage(named: "common_02selected"), forState: .Selected)
        
        btn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        btn.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right:0)
        manageView.addSubview(btn)
        return manageView
    }
    
    func updateUI() {
        self.title = "卡券"
        self.setNavigation()
        self.segmentView()

        self.currentTableView = UITableView(frame: CGRect(x: 0, y: 55, width: kScreenWidth, height: self.view.bounds.size.height-64-58 - 55))
        self.currentTableView.backgroundColor = tableViewdefaultBackgroundColor
        self.currentTableView.separatorStyle = .None
        self.currentTableView.dataSource = self
        self.currentTableView.delegate = self
        self.view.addSubview(self.currentTableView)
        
        self.view.addSubview(ZMDTool.getLine(CGRect(x: 0, y: self.view.bounds.height - 64-58-0.5, width: kScreenWidth, height: 0.5)))

        let bottomeView = self.botttomeViewForManage()
        bottomeView.alpha = 0.0
        self.view.addSubview(bottomeView)
        
        manageBtn = ZMDTool.getButton(CGRect(x: 0, y: self.view.bounds.height - 64-58, width: kScreenWidth, height: 58), textForNormal: "批量管理", fontSize: 17, backgroundColor:RGB(247,247,247,1)) { ( sender) -> Void in
            bottomeView.alpha = 1.0
            (sender as! UIButton).alpha = 0.0
            self.isManage = !self.isManage
            self.currentTableView.reloadData()
        }
        self.view.addSubview(manageBtn)
    }
    
    func updateData() {
        QNNetworkTool.fetchCustomerCoupons { (coupons, data, error) -> Void in
            if coupons != nil {
                self.coupons = NSMutableArray(array: coupons!)
                self.currentTableView.reloadData()
            }
        }
    }
    
    func deleteCoupon(id:Int,indexPath:NSIndexPath) {
        QNNetworkTool.deleteCoupons(id) { (succeed, dictionary, error) -> Void in
            if succeed! {
                if self.cardType == .Consumer {
                    self.coupons.removeObjectAtIndex(indexPath.section)
                    self.currentTableView.reloadData()
                }
            } else {
                ZMDTool.showErrorPromptView(nil, error: error, errorMsg: nil)
            }
        }
    }
}
