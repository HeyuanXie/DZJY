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
                viewController = MsgOrderViewController()
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

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        self.tabBarController!.tabBar.hidden = true
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // 让导航栏支持右滑返回功能
        ZMDTool.addInteractive(self.navigationController)
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
        cell?.imageView?.image = cellType.data.msgImg
        cell?.textLabel?.text = cellType.data.title
        if cellType == .Activity {
        }
        return cell!
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        let cellType = self.msgCellTypes[indexPath.row]
//        cellType.didSelect(self.navigationController!)
        let vc = UIViewController()
        vc.configBackButton()
        vc.title = self.msgCellTypes[indexPath.row].data.title
        let label = ZMDTool.getLabel(CGRect(x: 0, y: 100, width: kScreenWidth, height: 40), text: "暂时没有消息额,去逛逛吧!", fontSize: 17)
        label.backgroundColor = UIColor.clearColor()
        label.textAlignment = .Center
        vc.view.addSubview(label)
        self.navigationController?.pushViewController(vc, animated: true)
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
