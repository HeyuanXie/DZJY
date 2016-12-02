//
//  FortuneCenterRechargeViewController.swift
//  ZhiMaDi
//
//  Created by haijie on 16/3/8.
//  Copyright © 2016年 ZhiMaDi. All rights reserved.
//

import UIKit
// 充值
class WalletRechargeViewController: UIViewController,UITableViewDataSource, UITableViewDelegate,ZMDInterceptorProtocol,ZMDInterceptorMoreProtocol {
    
    var currentTableView: UITableView!
    var dataArray : NSArray!
    var amountTextField : UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataArray = ["",""]
        
        self.updateUI()
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
        return 2
    }
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 0 : 16
    }
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return indexPath.section == 0 ? 70 : 56
    }
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headView = UIView(frame: CGRectMake(0, 0, kScreenWidth, 16))
        headView.backgroundColor = UIColor.clearColor()
        return headView
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0{
            let cellId = "cardCell"
            var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
            if cell == nil {
                cell = UITableViewCell(style: .Subtitle, reuseIdentifier: cellId)
                cell?.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
                cell!.selectionStyle = .None
                
                ZMDTool.configTableViewCellDefault(cell!)
            }
            cell?.imageView?.image = UIImage(named: "bank_gs")
            cell?.textLabel?.text = "中国工商银行"
            cell?.detailTextLabel?.text = "储蓄卡 尾号0495"
            return cell!
        } else {
            let cellId = "moneyCell"
            var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
            if cell == nil {
                cell = UITableViewCell(style: .Subtitle, reuseIdentifier: cellId)
                cell?.accessoryType = UITableViewCellAccessoryType.None
                cell!.selectionStyle = .None
                
                ZMDTool.configTableViewCellDefault(cell!)
            }
            cell?.textLabel?.text = "金额"
            self.amountTextField = UITextField(frame: CGRect(x: 70, y: 0, width: kScreenWidth - 82, height: 56))
            self.amountTextField.font = defaultSysFontWithSize(17)
            self.amountTextField.textColor = defaultTextColor
            self.amountTextField.placeholder = "请输入充值金额"
            cell?.contentView.addSubview(self.amountTextField)
            return cell!
        }
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 {
            self.selectCashViewShow()
        }
    }
    
    //MARK: -  PrivateMethod
    func updateUI() {
        self.title = "提现"
        
        self.currentTableView = UITableView(frame: self.view.bounds)
        self.currentTableView.backgroundColor = tableViewdefaultBackgroundColor
        self.currentTableView.separatorStyle = .None
        self.currentTableView.dataSource = self
        self.currentTableView.delegate = self
        self.view.addSubview(self.currentTableView)
        
        let footView = UIView(frame: CGRectMake(0, 0, kScreenWidth, 110))
        footView.backgroundColor = UIColor.clearColor()
        let btn = ZMDTool.getButton(CGRect(x: 12, y: 60, width: kScreenWidth - 24, height: 50), textForNormal: "立即充值", fontSize: 20, textColorForNormal: UIColor.whiteColor(), backgroundColor: RGB(235,61,61,1.0)) { (sender) -> Void in
            
        }
        ZMDTool.configViewLayerWithSize(btn, size: 25)
        footView.addSubview(btn)
        self.currentTableView.tableFooterView = footView
        
        let headView = UIView(frame: CGRectMake(0, 0, kScreenWidth, 50))
        headView.backgroundColor = UIColor.clearColor()
        let enabelLbl = ZMDTool.getLabel(CGRectMake(12, 22, kScreenWidth - 24,16), text: "选择充值方式", fontSize: 16)
        headView.addSubview(enabelLbl)
        self.currentTableView.tableHeaderView = headView
    }
    //MARK: -  PrivateMethod
    func selectCashViewShow() {
        let bg = UIButton(frame: self.view.bounds)
        bg.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.4) //半透明色值
        let config = ZMDPopViewConfig()
        config.dismissCompletion = { (view) ->Void in
            bg.removeFromSuperview()
        }
        self.presentPopupView(bg,config: config)
        
        let view = UIView(frame: CGRect(x: 0, y: self.view.bounds.height - 300, width: kScreenWidth, height: 50+60+56))
        view.backgroundColor = UIColor.whiteColor()
        
        let topLbl = ZMDTool.getLabel(CGRect(x: 0, y: 0, width: kScreenWidth, height: 50), text: "选择充值方式", fontSize: 16)
        topLbl.textAlignment = .Center
        view.addSubview(topLbl)
        
        let btn = UIButton(frame: CGRect(x: 0, y: 50, width: kScreenWidth, height: 60))
        let cardlabel = ZMDTool.getLabel(CGRect(x: 20, y: 0, width: kScreenWidth - 20 - 15 - 12, height: 60), text: "中国工商银行 储蓄卡 尾号0425", fontSize: 16)
//        cardlabel.attributedText = "中国工商银行 储蓄卡 尾号0425".AttributedText("储蓄卡 尾号0425", color: UIColor.whiteColor())
        btn.addSubview(cardlabel)
        let selectImgV = UIImageView(frame: CGRect(x: kScreenWidth - 12 - 15, y:22, width: 15, height: 25 ))
        selectImgV.image = UIImage(named: "user_wallet_selected")
        btn.addSubview(selectImgV)
        view.addSubview(btn)
        
        let cancelBtn = ZMDTool.getButton(CGRect(x: 0, y: 110, width: kScreenWidth, height: 56), textForNormal: "取消", fontSize: 17, backgroundColor: RGB(247,247,247,1.0)) { (sender) -> Void in
            self.dismissPopupView(view)
        }
        view.addSubview(cancelBtn)
        var i = 0
        for y in [50,110] {
            i++
            let line = ZMDTool.getLine(CGRect(x: 0, y: CGFloat(y), width: kScreenWidth, height: 0.5))
            view.addSubview(line)
        }
        config.showAnimation = .SlideInFromBottom
        config.dismissAnimation = .SlideOutToBottom
        self.presentPopupView(view,config: config)
        
    }
    
}
