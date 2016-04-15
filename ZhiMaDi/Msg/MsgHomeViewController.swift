//
//  MsgHomeViewController.swift
//  ZhiMaDi
//
//  Created by haijie on 16/4/15.
//  Copyright © 2016年 ZhiMaDi. All rights reserved.
//

import UIKit
// 消息
class MsgHomeViewController: UIViewController,UITableViewDataSource, UITableViewDelegate,ZMDInterceptorProtocol,ZMDInterceptorMoreProtocol {
    enum MsgHomeCellType {
        case Activity
        case Order
        case Goods
        case Chat
        case System
        var data : (title :String,msgImg:UIImage){
            switch self {
            case Activity:
                return ("活动消息",UIImage(named: "message_activity")!)
            case Order:
                return ("订单消息",UIImage(named: "message_order")!)
            case Goods:
                return ("商品消息",UIImage(named: "message_product")!)
            case Chat:
                return ("聊天消息",UIImage(named: "message_chat")!)
            case System:
                return ("系统消息",UIImage(named: "message_system")!)
            }
        }
        
        var pushViewController :UIViewController{
            let viewController: UIViewController
            switch self {
            case Activity:
                viewController = MsgActivityViewController()
            case Order:
                viewController = UIViewController()
            case Goods:
                viewController = UIViewController()
            case Chat:
                viewController = UIViewController()
            case System:
                viewController = UIViewController()
            }
            viewController.hidesBottomBarWhenPushed = true
            return viewController
        }
        
        func didSelect(navViewController:UINavigationController){
            navViewController.pushViewController(pushViewController, animated: true)
        }
    }
    var currentTableView: UITableView!
    var msgCellTypes = [MsgHomeCellType.Activity,.Order,.Goods,.Chat,.System]

    override func viewDidLoad() {
        super.viewDidLoad()
        self.subViewInit()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //MARK:- UITableViewDataSource,UITableViewDelegate
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.msgCellTypes.count
    }
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 16
    }
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 55
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
            cell?.contentView.addSubview(ZMDTool.getLine(CGRect(x: 0, y: 54.5, width: kScreenWidth, height: 0.5)))
        }
        let cellType = self.msgCellTypes[indexPath.row]
        if cellType == .Activity {
            cell?.contentView.setBadgeValue("3", center: CGPoint(x: 130, y: 27.5))
        }
        cell?.imageView?.image = cellType.data.msgImg
        cell?.textLabel?.text = cellType.data.title
        return cell!
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cellType = self.msgCellTypes[indexPath.row]
        cellType.didSelect(self.navigationController!)
    }
    //MARK: -  PrivateMethod
    private func subViewInit(){
        self.title = "消息"
        self.currentTableView = UITableView(frame: self.view.bounds)
        self.currentTableView.backgroundColor = tableViewdefaultBackgroundColor
        self.currentTableView.separatorStyle = .None
        self.currentTableView.dataSource = self
        self.currentTableView.delegate = self
        self.view.addSubview(self.currentTableView)
    }
}