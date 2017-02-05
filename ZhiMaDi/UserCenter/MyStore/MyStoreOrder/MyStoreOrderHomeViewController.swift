//
//  MyStoreOrderHomeViewController.swift
//  ZhiMaDi
//
//  Created by haijie on 16/4/27.
//  Copyright © 2016年 ZhiMaDi. All rights reserved.
//

import UIKit
// 订单管理
class MyStoreOrderHomeViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,ZMDInterceptorProtocol {
    @IBOutlet weak var currentTableView: UITableView!
    var dataArray : NSArray!
    override func viewDidLoad() {
        super.viewDidLoad()
        dataArray = [["","","","",""],[""],[""]]
        self.updateUI()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    //MARK:- UITableViewDataSource,UITableViewDelegate
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataArray[section].count
    }
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.dataArray.count
    }
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 0 : 16
    }
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let data = self.dataArray[indexPath.section]
        if indexPath.row == 0 {
            return 48
        } else if indexPath.row == data.count - 1 {
            return 56
        } else if indexPath.row == data.count - 2 {
            return 56
        }
        return 110
    }
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headView = UIView(frame: CGRectMake(0, 0, kScreenWidth, 16))
        headView.backgroundColor = UIColor.clearColor()
        return headView
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let data = self.dataArray[indexPath.section]
        if indexPath.row == 0 {
            let cellId = "StoreCell"
            let cell = tableView.dequeueReusableCellWithIdentifier(cellId)
            let line = ZMDTool.getLine(CGRect(x: 0, y: 47.5, width: kScreenWidth, height: 0.5))
            cell?.contentView.addSubview(line)
            return cell!
        } else if indexPath.row == data.count - 2 {
            let cellId = "TotalCell"
            var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
            if cell == nil {
                cell = UITableViewCell(style: .Subtitle, reuseIdentifier: cellId)
                cell?.accessoryType = UITableViewCellAccessoryType.None
                cell!.selectionStyle = .None
                ZMDTool.configTableViewCellDefault(cell!)
                
                let line = ZMDTool.getLine(CGRect(x: 0, y: 55.5, width: kScreenWidth, height: 0.5))
                cell?.contentView.addSubview(line)
            }
            let label = ZMDTool.getLabel(CGRect(x: 12, y: 0, width: kScreenWidth - 24, height: 55.5), text: "共2件商品,合计:318.0(含运费 : 0.00)", fontSize: 14)
            label.textAlignment = .Right
            cell?.contentView.addSubview(label)
            
            return cell!
        } else if indexPath.row == data.count - 1 {
            let cellId = "MenuCell"
            var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
            if cell == nil {
                cell = UITableViewCell(style: .Subtitle, reuseIdentifier: cellId)
                cell?.accessoryType = UITableViewCellAccessoryType.None
                cell!.selectionStyle = .None
                ZMDTool.configTableViewCellDefault(cell!)
                
                let line = ZMDTool.getLine(CGRect(x: 0, y: 55.5, width: kScreenWidth, height: 0.5))
                cell?.contentView.addSubview(line)
            }
            let titles = ["立即发货","联系卖家"]
            var i = 0,minX = CGFloat(0)
            for title in titles {
                let size = title.sizeWithFont(UIFont.systemFontOfSize(14), maxWidth: 100)
                let width = size.width + 32 ,height = CGFloat(35)
                let x = kScreenWidth - 12 - width - minX,y = CGFloat(12)
                minX = kScreenWidth - x
                let btn = ZMDTool.getMutilButton(CGRect(x: x, y: y, width: width, height: height), textForNormal: title, fontSize: 14, backgroundColor: UIColor.whiteColor(), blockForCli: { (sender) -> Void in
                    if titles[sender.tag-1000] == "订单详情" {
                        let vc = MyOrderDetailViewController.CreateFromMainStoryboard() as! MyOrderDetailViewController
                        self.navigationController?.pushViewController(vc, animated: true)
                    }else if titles[sender.tag-1000] == "评价" {
                        let vc = OrderCommentViewController()
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                })
                btn.tag = 1000+i
                i++
                ZMDTool.configViewLayerFrameWithColor(btn, color: RGB(151,151,151,1))
                ZMDTool.configViewLayer(btn)
                cell?.contentView.addSubview(btn)
            }
            return cell!
            
        } else {
            let cellId = "GoodsCell"
            let cell = tableView.dequeueReusableCellWithIdentifier(cellId) as! OrderGoodsTableViewCell
            return cell
        }
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == 0 {
            let vc = MyStoreOrderDetailViewController.CreateFromStoreStoryboard() as! MyStoreOrderDetailViewController
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    //MARK: -  PrivateMethod
    func updateUI() {
        self.currentTableView.backgroundColor = tableViewdefaultBackgroundColor
        let menuTitle = ["未发货","未付款","退款","已完成","已关闭"]
        let customJumpBtns = CustomJumpBtns(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 55),menuTitle: menuTitle)
        customJumpBtns.addSeparatedLine()
        self.view.addSubview(customJumpBtns)
    }
}
