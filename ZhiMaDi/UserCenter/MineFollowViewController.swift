//
//  MineCollectionViewController.swift
//  ZhiMaDi
//
//  Created by haijie on 16/4/8.
//  Copyright © 2016年 ZhiMaDi. All rights reserved.
//

import UIKit
// 关注的店铺
class MineFollowViewController: UIViewController,UITableViewDataSource, UITableViewDelegate,ZMDInterceptorProtocol,ZMDInterceptorMoreProtocol {
    var currentTableView: UITableView!
    var data : NSArray!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.subViewInit()
        self.data = ["","",""]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //MARK:- UITableViewDataSource,UITableViewDelegate
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.data.count
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
        return 85
    }
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headView = UIView(frame: CGRectMake(0, 0, kScreenWidth, 16))
        headView.backgroundColor = UIColor.clearColor()
        return headView
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellId = "OtherCell"
        var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
        if cell == nil {
            cell = UITableViewCell(style: .Subtitle, reuseIdentifier: cellId)
            cell?.accessoryType = UITableViewCellAccessoryType.None
            cell!.selectionStyle = .None
            
            ZMDTool.configTableViewCellDefault(cell!)
            var tag = 10000
            let imgV = UIImageView(frame: CGRect(x: 12, y: 12, width: 60, height: 60))
            imgV.backgroundColor = UIColor.clearColor()
            imgV.image = UIImage(named: "product_pic")
            imgV.tag = tag++
            cell?.contentView.addSubview(imgV)
            
            let storeLbl = ZMDTool.getLabel(CGRect(x: 12+60+10, y: 12, width: kScreenWidth - 82-75-10, height: 15), text: "", fontSize: 15)
            storeLbl.tag = tag++
            cell?.contentView.addSubview(storeLbl)
            
            let storeGoodsLbl = ZMDTool.getLabel(CGRect(x: 12+60+10, y: 85-12-15, width: kScreenWidth - 82-75-10, height: 15), text: "", fontSize: 15,textColor: defaultDetailTextColor)
            storeGoodsLbl.tag = tag++
            cell?.contentView.addSubview(storeGoodsLbl)
            
            let getVolumeBtn = ZMDTool.getButton(CGRect(x: kScreenWidth - 75, y: 12, width: 75, height: 15), textForNormal: "领券", fontSize: 15, backgroundColor: UIColor.clearColor(), blockForCli: { (sender) -> Void in
            })
            getVolumeBtn.tag = tag++
            cell?.contentView.addSubview(getVolumeBtn)
            
            let cancelBtn = ZMDTool.getButton(CGRect(x: kScreenWidth - 75, y: 85-12-15, width: 62, height: 15), textForNormal: "取消关注", fontSize: 15,textColorForNormal:defaultDetailTextColor, backgroundColor: UIColor.clearColor(), blockForCli: { (sender) -> Void in
            })
            cancelBtn.tag = tag++
            cell?.contentView.addSubview(cancelBtn)
            
            cell?.contentView.addSubview(ZMDTool.getLine(CGRect(x: 0, y: 84.5, width: kScreenWidth, height: 0.5)))
            cell?.contentView.addSubview(ZMDTool.getLine(CGRect(x: kScreenWidth - 75, y: 12, width: 0.5, height: 15)))
        }
        var tag = 10000
        let imgV = cell?.viewWithTag(tag++) as! UIImageView
        let storeLbl = cell?.viewWithTag(tag++) as! UILabel
        let storeGoodsLbl = cell?.viewWithTag(tag++) as! UILabel
        let cancelBtn = cell?.viewWithTag(tag++) as! UIButton
        let getVolumeBtn = cell?.viewWithTag(tag++) as! UIButton
        
        imgV.image = UIImage(named: "product_pic")
        storeLbl.text = "葫芦堡旗舰店"
        storeGoodsLbl.text = "主营：婴儿床、婴儿床、婴儿床、婴儿床、婴儿床"
        getVolumeBtn.rac_signalForControlEvents(.TouchUpInside).subscribeNext { (sender) -> Void in
            
        }
        cancelBtn.rac_signalForControlEvents(.TouchUpInside).subscribeNext { (sender) -> Void in
            
        }
        return cell!
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let vc = StoreShowHomeViewController.CreateFromMainStoryboard() as! StoreShowHomeViewController
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    //MARK: -  PrivateMethod
    private func subViewInit(){
        self.title = "关注的店铺"
        self.currentTableView = UITableView(frame: self.view.bounds)
        self.currentTableView.backgroundColor = tableViewdefaultBackgroundColor
        self.currentTableView.separatorStyle = .None
        self.currentTableView.dataSource = self
        self.currentTableView.delegate = self
        self.view.addSubview(self.currentTableView)
    }
}
