//
//  OrderLogisticsMsgViewController.swift
//  ZhiMaDi
//
//  Created by haijie on 16/4/1.
//  Copyright © 2016年 ZhiMaDi. All rights reserved.
//

import UIKit
// 查看物流信息
class OrderLogisticsMsgViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,ZMDInterceptorProtocol,ZMDInterceptorMoreProtocol {
    var currentTableView : UITableView!
//    var msgData : NSArray!
    var dataArray = NSMutableArray()
    
    var orderId : NSNumber!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "订单跟踪"
//        self.msgData = ["","","",""]
        self.fetchData()
        self.updateUI()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //MARK:- UITableViewDataSource,UITableViewDelegate
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 0 : self.dataArray.count + 1
    }
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 16
    }
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return indexPath.row == 0 ? 120 : 45
        } else if indexPath.row == 1 {
            return 94
        } else if indexPath.row > 1 {
            return 70
        }
        return 56
    }
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headView = UIView(frame: CGRectMake(0, 0, kScreenWidth, 10))
        headView.backgroundColor = UIColor.clearColor()
        return headView
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                let cellId = "MsgCell"
                var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
                if cell == nil {
                    cell = UITableViewCell(style: .Subtitle, reuseIdentifier: cellId)
                    cell?.accessoryType = UITableViewCellAccessoryType.None
                    cell!.selectionStyle = .None
                    
                    ZMDTool.configTableViewCellDefault(cell!)
                    cell?.addSubview(ZMDTool.getLine(CGRect(x: 0, y: 119.5, width: kScreenWidth, height: 0.5)))
                }
                
                let nameLbl = ZMDTool.getLabel(CGRect(x: 12, y: 20 , width: kScreenWidth - 24, height: 17), text: "顺丰物流", fontSize: 17)
                let numLbl = ZMDTool.getLabel(CGRect(x: 12, y: CGRectGetMaxY(nameLbl.frame)+15 , width: kScreenWidth-24, height: 17), text: "物流单号 ： 2532424324242", fontSize: 17)
                let paijianPersonLbl = ZMDTool.getLabel(CGRect(x: 12, y: CGRectGetMaxY(numLbl.frame)+15 , width: kScreenWidth-24, height: 17), text: "物流单号 ： 派件员 : 莎拉波", fontSize: 17)
                cell?.contentView.addSubview(nameLbl)
                cell?.contentView.addSubview(numLbl)
                cell?.contentView.addSubview(paijianPersonLbl)
                return cell!
            }else{
                let cellId = "CopyCell"
                var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
                if cell == nil {
                    cell = UITableViewCell(style: .Subtitle, reuseIdentifier: cellId)
                    cell?.accessoryType = UITableViewCellAccessoryType.None
                    cell!.selectionStyle = .None
                    ZMDTool.configTableViewCellDefault(cell!)
                }
                let btn = ZMDTool.getButton(CGRect(x: kScreenWidth - 12 - 90, y: 0, width: 90, height: 45), textForNormal: "复制单号", fontSize: 14,textColorForNormal: defaultDetailTextColor, backgroundColor: UIColor.whiteColor(), blockForCli: { (sender) -> Void in
                    
                })
                btn.setImage(UIImage(named: "pay_copy"), forState: .Normal)
                cell?.contentView.addSubview(btn)
                return cell!
            }
        }
        if indexPath.section == 1 && indexPath.row > 0 {
            if indexPath.row == 1 {
                let cellId = "MsgFirstCell"
                var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
                let orderNote = self.dataArray[0] as! ZMDOrderNote
                if cell == nil {
                    cell = UITableViewCell(style: .Subtitle, reuseIdentifier: cellId)
                    cell?.accessoryType = UITableViewCellAccessoryType.None
                    cell!.selectionStyle = .None
                    
                    ZMDTool.configTableViewCellDefault(cell!)
                    
                    let imgV = UIImageView(frame: CGRect(x: 46-12, y: 14, width: 25, height: 25))
                    imgV.image = UIImage(named: "pay_location")
                    let line = ZMDTool.getLine(CGRect(x: 46, y: CGRectGetMaxY(imgV.frame), width: 0.5, height: 94-CGRectGetMaxY(imgV.frame)))
                    let titleLbl = ZMDTool.getLabel(CGRect(x:90, y: 15 , width: kScreenWidth-90-12, height: 48), text: "", fontSize: 15)
                    titleLbl.numberOfLines = 2
                    titleLbl.text = orderNote.Note.stringByReplacingOccurrencesOfString("。", withString: "")
                    let timeLbl = ZMDTool.getLabel(CGRect(x: 90, y:94-15-13 , width: kScreenWidth-90-12, height: 13), text: "", fontSize: 13)
                    timeLbl.text = orderNote.CreatedOn.stringByReplacingOccurrencesOfString("T", withString: " ").componentsSeparatedByString(".").first
                    
                    cell?.addLine(hiddenLine: self.dataArray.count==1, leftOffset: 90, rightOffset: 0)
                    cell?.contentView.addSubview(imgV)
                    cell?.contentView.addSubview(line)
                    cell?.contentView.addSubview(titleLbl)
                    cell?.contentView.addSubview(timeLbl)
                }
                return cell!
            } else {
                let cellId = "MsgCell"
                var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
                let orderNote = self.dataArray[indexPath.row-1] as! ZMDOrderNote
                if cell == nil {
                    cell = UITableViewCell(style: .Subtitle, reuseIdentifier: cellId)
                    cell?.accessoryType = UITableViewCellAccessoryType.None
                    cell!.selectionStyle = .None
                    
                    ZMDTool.configTableViewCellDefault(cell!)
                    cell?.addLine(hiddenLine: self.dataArray.count==indexPath.row, leftOffset: 90, rightOffset: 0)
                    
                    let line = ZMDTool.getLine(CGRect(x: 46, y: 0, width: 0.5, height:70))
                    cell?.contentView.addSubview(line)
                    
                    let blackPointV = UIView(frame: CGRect(x: 46-4, y: 19, width: 8, height: 8))
                    ZMDTool.configViewLayerRound(blackPointV)
                    blackPointV.backgroundColor = RGB(194,194,194,1)
                    cell?.contentView.addSubview(blackPointV)
                    
                    let titleLbl = ZMDTool.getLabel(CGRect(x:90, y: 15 , width: kScreenWidth-90-12, height: 15), text: "广东省 配送中", fontSize: 15,textColor: defaultDetailTextColor)
                    titleLbl.text = orderNote.Note.stringByReplacingOccurrencesOfString("。", withString: "")
                    titleLbl.tag = 10001
                    cell?.contentView.addSubview(titleLbl)
                    let timeLbl = ZMDTool.getLabel(CGRect(x: 90, y:70-15-13 , width: kScreenWidth-90-12, height: 13), text: "2015-7-3 09:23:22", fontSize: 13,textColor: defaultDetailTextColor)
                    timeLbl.text = orderNote.CreatedOn.stringByReplacingOccurrencesOfString("T", withString: " ").componentsSeparatedByString(".").first
                    timeLbl.tag = 10002
                    cell?.contentView.addSubview(timeLbl)
                }
                return cell!
            }
        } else {
            let cellId = "TopCell"
            var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
            if cell == nil {
                cell = UITableViewCell(style: .Subtitle, reuseIdentifier: cellId)
                cell?.accessoryType = UITableViewCellAccessoryType.None
                cell!.selectionStyle = .None
                
                ZMDTool.configTableViewCellDefault(cell!)
                cell?.addSubview(ZMDTool.getLine(CGRect(x: 0, y: 55.5, width: kScreenWidth, height: 0.5)))
            }
            cell?.textLabel!.text = "订单跟踪"
            return cell!
        }
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        let homeBuyListViewController = HomeBuyListViewController.CreateFromMainStoryboard() as! HomeBuyListViewController
//        self.navigationController?.pushViewController(homeBuyListViewController, animated: true)
    }
    //MARK: -  PrivateMethod
    func fetchData() {
        QNNetworkTool.orderDetail(self.orderId.integerValue/*self.orderId*/) { (succeed, dictionary, error) -> Void in
            if let dic = dictionary {
                let notes = ZMDOrderNote.mj_objectArrayWithKeyValuesArray(dic["OrderNotes"])
                self.dataArray.addObjectsFromArray(notes as [AnyObject])
                self.currentTableView.reloadData()
            }
        }
    }
    
    func updateUI() {
        currentTableView = UITableView(frame: self.view.bounds)
        currentTableView.backgroundColor = tableViewdefaultBackgroundColor
        currentTableView.delegate = self
        currentTableView.dataSource = self
        currentTableView.separatorStyle = UITableViewCellSeparatorStyle.None
        self.view.addSubview(currentTableView)
    }
}
