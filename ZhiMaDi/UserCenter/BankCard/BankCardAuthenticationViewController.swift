//
//  MineBankCardHomeViewController.swift
//  ZhiMaDi
//
//  Created by haijie on 16/3/7.
//  Copyright © 2016年 ZhiMaDi. All rights reserved.
//

import UIKit
//银行卡认证
class BankCardAuthenticationViewController: UIViewController,UITableViewDataSource, UITableViewDelegate,ZMDInterceptorProtocol,ZMDInterceptorMoreProtocol {
    var currentTableView: UITableView!

    var dataArray : NSArray!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataArray = ["","",""]
        self.subViewInit()
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
        return self.dataArray.count
    }
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 1
    }
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
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
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    }
    //MARK:- Private Method
    private func subViewInit(){
        self.title = "银行卡认证"
        self.currentTableView = UITableView(frame: self.view.bounds)
        self.currentTableView.backgroundColor = tableViewdefaultBackgroundColor
        self.currentTableView.separatorStyle = .None
        self.currentTableView.dataSource = self
        self.currentTableView.delegate = self
        self.view.addSubview(self.currentTableView)
        
        let headV = UIView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 52))
        headV.backgroundColor = UIColor.clearColor()
        let headLbl = ZMDTool.getLabel(CGRect(x: 12, y: 23, width: 200, height: 16), text: "选择已有银行卡", fontSize: 16)
        headV.addSubview(headLbl)
        self.currentTableView.tableHeaderView = headV
        
        let title = "添加银行卡"
        let size = title.sizeWithFont(defaultSysFontWithSize(16), maxWidth: 320)
        let footV = UIView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 50))
        footV.backgroundColor = UIColor.clearColor()
        let footBtn = ZMDTool.getButton(CGRect(x: kScreenWidth - 12 - size.width, y: 15, width: size.width, height: 16), textForNormal: title, fontSize: 16, textColorForNormal: RGB(235,61,61,1.0), backgroundColor: UIColor.clearColor()) { (sender) -> Void in
            ZMDTool.showPromptView("添加银行卡未开放")
        }
        footV.addSubview(footBtn)
        let line = UIView(frame: CGRect(x: kScreenWidth - 12 - size.width, y: 31, width: size.width, height: 1))
        line.backgroundColor = RGB(235,61,61,1.0)
        footV.addSubview(line)
        self.currentTableView.tableFooterView = footV
    }

}
