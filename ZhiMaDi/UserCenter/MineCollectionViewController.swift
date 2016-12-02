//
//  MineCollectionViewController.swift
//  ZhiMaDi
//
//  Created by haijie on 16/4/8.
//  Copyright © 2016年 ZhiMaDi. All rights reserved.
//

import UIKit
// 收藏的商品
class MineCollectionViewController: UIViewController,UITableViewDataSource, UITableViewDelegate,ZMDInterceptorProtocol,ZMDInterceptorMoreProtocol {
    var currentTableView: UITableView!
    var data = NSMutableArray()
    var goodses  = ["全部   ","种子","农产品","饮料/食品","物资"]
    //let goodses = [全部(self.dataArr.count)，data中product的类型]
    override func viewDidLoad() {
        super.viewDidLoad()
        self.subViewInit()
        self.dataUpdate()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        self.dataUpdate()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //MARK:- UITableViewDataSource,UITableViewDelegate
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 1 : self.data.count
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
        if indexPath.section == 0 {
            return  ZMDMultiselectView.getHeight(goodses)
        }
        return 150
    }
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headView = UIView(frame: CGRectMake(0, 0, kScreenWidth, 16))
        headView.backgroundColor = UIColor.clearColor()
        return headView
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cellId = "HeadCell"
            var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
            if cell == nil {
                cell = UITableViewCell(style: .Subtitle, reuseIdentifier: cellId)
                cell?.accessoryType = UITableViewCellAccessoryType.None
                cell!.selectionStyle = .None
            }
            let multiselectView = ZMDMultiselectView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: ZMDMultiselectView.getHeight(goodses)),titles: goodses)
            multiselectView.finished = { (index) ->Void in
                let title = self.goodses[index]
                // 我要干嘛   ..(点击气泡响应)
                //根据气泡title刷新tableView
                print(title)
            }
            cell?.contentView.addSubview(multiselectView)
            return cell!
        }
        let cellId = "OtherCell"
        var cell = tableView.dequeueReusableCellWithIdentifier(cellId) as? CollectionGoodsCell
        if cell == nil {
            cell = CollectionGoodsCell(style: .Subtitle, reuseIdentifier: cellId)
        }
        var tag = 10000
        let imgV = cell?.viewWithTag(tag++) as! UIImageView
        let goodsLbl = cell?.viewWithTag(tag++) as! UILabel
        let detailLbl = cell?.viewWithTag(tag++) as! UILabel
        let goodsPriceLbl = cell?.viewWithTag(tag++) as! UILabel
        let freightLbl = cell?.viewWithTag(tag++) as! UILabel
        let cancelBtn = cell?.viewWithTag(tag++) as! UIButton
        
        if let item = self.data[indexPath.row] as? ZMDShoppingItem {
            if let imgUrl = item.Picture?.ImageUrl {
                imgV.sd_setImageWithURL(NSURL(string: kImageAddressMain+imgUrl))
            }
            goodsLbl.text = item.ProductName
            detailLbl.text = (item.AttributeInfo as NSString).stringByReplacingOccurrencesOfString("<br />", withString: " ")
//            goodsPriceLbl.text = item.SubTotal
            goodsPriceLbl.attributedText = "\(item.SubTotal) 原价:\(item.UnitPrice)".AttributeText([item.SubTotal,"原价:\(item.UnitPrice)"], colors: [RGB(235,61,61,1),UIColor.lightGrayColor()], textSizes: [14,12])
            freightLbl.text = "不包邮"
            cancelBtn.rac_signalForControlEvents(.TouchUpInside).subscribeNext { (sender) -> Void in
                // 取消收藏
                self.deleteCartItem("\(item.Id)")
            }
        }
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 1 {
            let item = self.data[indexPath.row] as? ZMDShoppingItem
            let vc = HomeBuyGoodsDetailViewController.CreateFromMainStoryboard() as! HomeBuyGoodsDetailViewController
            vc.productId = item?.ProductId.integerValue
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    //MARK: -  PrivateMethod
    private func subViewInit(){
        self.title = "收藏的商品"
        self.currentTableView = UITableView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight - 64))
        self.currentTableView.backgroundColor = tableViewdefaultBackgroundColor
        self.currentTableView.separatorStyle = .None
        self.currentTableView.dataSource = self
        self.currentTableView.delegate = self
        self.view.addSubview(self.currentTableView)
    }
    func dataUpdate() {
        QNNetworkTool.fetchShoppingCart(2){ (shoppingItems, dictionary, error) -> Void in
            if shoppingItems != nil {
                self.data = NSMutableArray(array: shoppingItems!)
                self.goodses[0] = "全部(\(self.data.count))"
                self.currentTableView.reloadData()
            } else {
                ZMDTool.showErrorPromptView(dictionary, error: error, errorMsg: nil)
            }
        }
    }
    func deleteCartItem(id:String) {
        if g_isLogin! {
            QNNetworkTool.deleteCartItem(id,carttype: 2,completion: { (succeed, dictionary, error) -> Void in
                if succeed! {
                    self.data.removeAllObjects()
                    self.dataUpdate()
                    ZMDTool.showPromptView("取消收藏成功")
                } else {
                    ZMDTool.showErrorPromptView(dictionary, error: error, errorMsg: "取消收藏失败")
                }
            })
        }
    }
}
// 收藏商品  cell
class CollectionGoodsCell : UITableViewCell {
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.accessoryType = UITableViewCellAccessoryType.None
        self.selectionStyle = .None
        
        ZMDTool.configTableViewCellDefault(self)
        var tag = 10000
        let imgV = UIImageView(frame: CGRect(x: 12, y: 12, width: 125, height: 125))
        imgV.backgroundColor = UIColor.clearColor()
        imgV.tag = tag++
        self.contentView.addSubview(imgV)
        
        let goodsLbl = ZMDTool.getLabel(CGRect(x: 12+125+10, y: 12, width: kScreenWidth - 12-125-10-12, height: 15), text: "", fontSize: 15)
        goodsLbl.tag = tag++
        self.contentView.addSubview(goodsLbl)
        
        let detailLbl = ZMDTool.getLabel(CGRect(x: 12+125+10, y: CGRectGetMaxY(goodsLbl.frame)+14, width: kScreenWidth-12-125-10-12, height: 150-12-14-14-15-12-15), text: "", fontSize: 15,textColor: RGB(235,61,61,1.0))
        detailLbl.tag = tag++
        self.contentView.addSubview(detailLbl)
        
        let goodsPriceLbl = ZMDTool.getLabel(CGRect(x: 12+125+10, y: 150-12-14-14-15, width: kScreenWidth - 12-125-10-12, height: 15), text: "", fontSize: 15,textColor: RGB(235,61,61,1.0))
        goodsPriceLbl.tag = tag++
        self.contentView.addSubview(goodsPriceLbl)
        
        let freightLbl = ZMDTool.getLabel(CGRect(x: 12+125+10, y: 150-12-14, width: kScreenWidth - 12-125-10-100, height: 15), text: "", fontSize: 15,textColor: defaultDetailTextColor)
        freightLbl.tag = tag++
        self.contentView.addSubview(freightLbl)
        
        let cancelBtn = ZMDTool.getButton(CGRect(x: kScreenWidth - 80, y: 150-12-15, width: 80, height: 15), textForNormal: "取消收藏", fontSize: 15,textColorForNormal:defaultDetailTextColor, backgroundColor: UIColor.clearColor(), blockForCli: { (sender) -> Void in
            //
            
        })
        cancelBtn.tag = tag++
        self.contentView.addSubview(cancelBtn)
        
        self.contentView.addSubview(ZMDTool.getLine(CGRect(x: 0, y: 149.5, width: kScreenWidth, height: 0.5)))
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
