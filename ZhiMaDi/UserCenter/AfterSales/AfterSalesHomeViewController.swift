//
//  AfterSalesHomeViewController.swift
//  ZhiMaDi
//
//  Created by haijie on 16/4/8.
//  Copyright © 2016年 ZhiMaDi. All rights reserved.
//

import UIKit
// 退款/售后
enum ReturnCellType {
    case ReturnGoods
    case Refund
    case EXchangeGoods
    case ReturnLease
    var title : String {
        switch self {
        case .ReturnGoods :
            return "退货退款"
        case .Refund :
            return "仅退款"
        case .EXchangeGoods :
            return "换货"
        case .ReturnLease :
            return "租赁商品归还"
        }
    }
    var returnReasonTitle:String{
        switch self {
        case .ReturnGoods :
            return "退货原因"
        case .Refund :
            return "货品状态"
        case .EXchangeGoods :
            return "换货原因"
        case .ReturnLease :
            return "退货原因"
        }
    }
    var returnReason:String{
        switch self {
        case .ReturnGoods :
            return "请选择退款原因"
        case .Refund :
            return "请选择货品状态"
        case .EXchangeGoods :
            return "请选择换货原因"
        case .ReturnLease :
            return "请选择退货原因"
        }
    }
    var returnExplan:String{
        switch self {
        case .ReturnGoods :
            return "退货说明 ："
        case .Refund :
            return "退款说明 ："
        case .EXchangeGoods :
            return "换货说明 ："
        case .ReturnLease :
            return ""
        }
    }
}
class AfterSalesHomeViewController: UIViewController,UITableViewDataSource, UITableViewDelegate,ZMDInterceptorProtocol,ZMDInterceptorMoreProtocol {
    var currentTableView: UITableView!
    let celltype = [ReturnCellType.ReturnGoods,.Refund,.EXchangeGoods,.ReturnLease]
    override func viewDidLoad() {
        super.viewDidLoad()
        self.subViewInit()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    //MARK:- UITableViewDataSource,UITableViewDelegate
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.celltype.count
    }
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 1
    }
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 56
    }
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headView = UIView(frame: CGRectMake(0, 0, kScreenWidth, 10))
        headView.backgroundColor = UIColor.clearColor()
        return headView
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellId = "OtherCell"
        var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
        if cell == nil {
            cell = UITableViewCell(style: .Subtitle, reuseIdentifier: cellId)
            cell?.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
            cell!.selectionStyle = .None
            
            ZMDTool.configTableViewCellDefault(cell!)
        }
        cell?.textLabel!.text = self.celltype[indexPath.section].title
        return cell!
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let vc = AfterSalesReturnViewController()
        vc.returnType = self.celltype[indexPath.section]
        self.navigationController?.pushViewController(vc, animated: true)
    }
    //MARK: -  PrivateMethod
    private func subViewInit(){
        self.title = "退款/售后"
        self.currentTableView = UITableView(frame: self.view.bounds)
        self.currentTableView.backgroundColor = tableViewdefaultBackgroundColor
        self.currentTableView.separatorStyle = .None
        self.currentTableView.dataSource = self
        self.currentTableView.delegate = self
        let headView = UIView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 16))
        self.currentTableView.tableHeaderView = headView
        self.view.addSubview(self.currentTableView)
    }
}
