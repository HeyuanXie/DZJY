//
//  CardVolumeDetailViewController.swift
//  ZhiMaDi
//
//  Created by haijie on 16/4/11.
//  Copyright © 2016年 ZhiMaDi. All rights reserved.
//

import UIKit
// 消费券详情
class CardVolumeConsumerDetailViewController: UIViewController,UITableViewDataSource, UITableViewDelegate,ZMDInterceptorProtocol,ZMDInterceptorMoreProtocol {
    enum CellType {
        case Head
        case Count
        case Method
        case Explain
        
        var height : CGFloat {
            switch self {
            case Head :
                return 135
            case Count:
                return 55
            case Method:
                return 80
            case Explain:
                return 170
            }
        }
        
    }
    var currentTableView: UITableView!
    var cellType = [[CellType.Head,.Count],[CellType.Method,.Explain]]
    var coupon : ZMDCoupon!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.updateUI()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //MARK:- UITableViewDataSource,UITableViewDelegate
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.cellType[section].count
    }
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.cellType.count
    }
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 16
    }
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let type = self.cellType[indexPath.section][indexPath.row]
        return type.height
    }
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headView = UIView(frame: CGRectMake(0, 0, kScreenWidth, 16))
        headView.backgroundColor = UIColor.clearColor()
        return headView
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let type = self.cellType[indexPath.section][indexPath.row]
        switch type {
        case .Head :
            let cellId = "HeadCell"
            var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
            if cell == nil {
                cell = UITableViewCell(style: .Subtitle, reuseIdentifier: cellId)
                cell?.accessoryType = UITableViewCellAccessoryType.None
                cell!.selectionStyle = .None
                cell!.contentView.backgroundColor = RGB(234,196,64,1)
            }
            if self.coupon.Discount.Name == nil {
                return cell!
            }
            let titleLbl = ZMDTool.getLabel(CGRect(x: 0, y: 15, width: kScreenWidth, height: 16), text: self.coupon.Discount.Name, fontSize: 16,textColor: UIColor.whiteColor(),textAlignment:.Center)
            cell?.contentView.addSubview(titleLbl)
            let starts = coupon.Discount.StartDateUtc!.componentsSeparatedByString("T")[0].stringByReplacingOccurrencesOfString("-", withString: ".")
            let ends = coupon.Discount.EndDateUtc!.componentsSeparatedByString("T")[0].stringByReplacingOccurrencesOfString("-", withString: ".")
            let text = "使用期限 ：\(starts)-\(ends)"
            let size = text.sizeWithFont(defaultSysFontWithSize(14), maxWidth: 300)
            let termLbl = ZMDTool.getLabel(CGRect(x: kScreenWidth/2-size.width/2, y: 15+16+12, width: size.width, height: 14), text: text, fontSize: 14,textColor: UIColor.whiteColor(),textAlignment:.Center)
            cell?.contentView.addSubview(termLbl)
            cell?.contentView.addSubview(ZMDTool.getLine(CGRect(x: 12, y: 15+16+12+7, width: kScreenWidth/2-size.width/2 - 24, height: 0.5)))
            cell?.contentView.addSubview(ZMDTool.getLine(CGRect(x: CGRectGetMaxX(termLbl.frame)+12, y: 15+16+12+7, width: kScreenWidth - CGRectGetMaxX(termLbl.frame) - 24, height: 0.5)))
            
            let moneyLbl = ZMDTool.getLabel(CGRect(x: 0, y: 15+16+12+14+28, width: kScreenWidth, height: 16), text: "", fontSize: 32,textColor: UIColor.whiteColor(),textAlignment:.Center)
            let money = String(format: "%.2f元", self.coupon.Discount.DiscountAmount.doubleValue)
            let moneys = money.componentsSeparatedByString(".")
            moneyLbl.attributedText = money.AttributeText(moneys, textSizes: [32,20])
            cell?.contentView.addSubview(moneyLbl)
            return cell!
        case .Count :
            let cellId = "CountCell"
            var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
            if cell == nil {
                cell = UITableViewCell(style: .Subtitle, reuseIdentifier: cellId)
                cell?.accessoryType = UITableViewCellAccessoryType.None
                cell!.selectionStyle = .None
                cell!.contentView.backgroundColor = UIColor.whiteColor()
            }
            let lbl = ZMDTool.getLabel(CGRect(x: 0, y: 0, width: kScreenWidth-12, height: 55), text: "共一份", fontSize: 17,textAlignment:.Right)
            cell?.contentView.addSubview(lbl)
            return cell!
        case .Method :
                let cellId = "MethodCell"
                var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
                if cell == nil {
                    cell = UITableViewCell(style: .Subtitle, reuseIdentifier: cellId)
                    cell?.accessoryType = UITableViewCellAccessoryType.None
                    cell!.selectionStyle = .None
                    ZMDTool.configTableViewCellDefault(cell!)
                }
                cell?.textLabel!.text = "获得途径"
                cell?.detailTextLabel!.text = "新用户下载APP获赠"
                cell?.contentView.addSubview(ZMDTool.getLine(CGRect(x: 0, y: 79.5, width: kScreenWidth, height: 0.5)))
                return cell!
        case .Explain :
            let cellId = "ExplainCell"
            var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
            if cell == nil {
                cell = UITableViewCell(style: .Subtitle, reuseIdentifier: cellId)
                cell?.accessoryType = UITableViewCellAccessoryType.None
                cell!.selectionStyle = .None
                cell!.contentView.backgroundColor = UIColor.whiteColor()
            }
            let titleLbl = ZMDTool.getLabel(CGRect(x: 12, y: 20, width: kScreenWidth, height: 16), text: "使用说明", fontSize: 17)
            cell?.contentView.addSubview(titleLbl)
            let detailLbl = ZMDTool.getLabel(CGRect(x: 12, y: 20+16+12, width: kScreenWidth, height: 40), text: self.coupon.Discount.Explain, fontSize: 15,textColor: defaultDetailTextColor)
            detailLbl.numberOfLines = 2
            cell?.contentView.addSubview(detailLbl)
            return cell!
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

    }
    
    //MARK: -  PrivateMethod
    func updateUI() {
        self.title = "详情"
        let rightBtn = ZMDTool.getButton(CGRect(x: 0, y: 0, width: 62, height: 44), textForNormal: "删除", fontSize: 16,backgroundColor: UIColor.clearColor(), blockForCli: { (sender) -> Void in
            QNNetworkTool.deleteCoupons(self.coupon.Id!.integerValue) { (succeed, dictionary, error) -> Void in
                if succeed! {
                    ZMDTool.showPromptView("删除成功")
                    self.navigationController?.popViewControllerAnimated(true)
                } else {
                    ZMDTool.showErrorPromptView(nil, error: error, errorMsg: nil)
                }
            }
        })
        rightBtn.setImage(UIImage(named: "common_delete"), forState: .Normal)
        rightBtn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        rightBtn.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right:0)
        let item = UIBarButtonItem(customView: rightBtn)
        item.rac_command = RACCommand(signalBlock: { (sender) -> RACSignal! in
            return RACSignal.empty()
        })
        item.customView?.tintColor = defaultDetailTextColor
        self.navigationItem.rightBarButtonItem = item
        
        self.currentTableView = UITableView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: self.view.bounds.size.height-64-58))
        self.currentTableView.backgroundColor = tableViewdefaultBackgroundColor
        self.currentTableView.separatorStyle = .None
        self.currentTableView.dataSource = self
        self.currentTableView.delegate = self
        self.view.addSubview(self.currentTableView)
        
        self.view.addSubview(ZMDTool.getLine(CGRect(x: 0, y: self.view.bounds.height - 64-58-0.5, width: kScreenWidth, height: 0.5)))
        let useBtn = ZMDTool.getButton(CGRect(x: 0, y: self.view.bounds.height - 64-58, width: kScreenWidth, height: 58), textForNormal: "立即使用", fontSize: 17, backgroundColor:RGB(247,247,247,1)) { ( sender) -> Void in
            ZMDTool.showPromptView("使用卡券功能暂未开放")
        }
        self.view.addSubview(useBtn)
        
    }
}
