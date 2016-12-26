//
//  MineCollectionViewController.swift
//  ZhiMaDi
//
//  Created by haijie on 16/4/8.
//  Copyright © 2016年 ZhiMaDi. All rights reserved.
//

import UIKit
// 我的收藏
class MineCollectionViewController: UIViewController,UITableViewDataSource, UITableViewDelegate,ZMDInterceptorProtocol,ZMDInterceptorMoreProtocol {
    enum StatuType : Int {
//        case Supply = 0,Demand,Product
        case Store = 0,Product
    }
    var currentTableView: UITableView!
    var data = NSMutableArray()
    var statu = StatuType.Store
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
        return 1
    }
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.data.count
    }
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if self.statu == .Product {
            return 150
        }else{
            return zoom(85)
        }
    }
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headView = UIView(frame: CGRectMake(0, 0, kScreenWidth, 16))
        headView.backgroundColor = UIColor.clearColor()
        return headView
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if self.statu == .Product {
            return self.cellForProduct(tableView,indexPath:indexPath)
        }else{
            return self.cellForStore(tableView,indexPath:indexPath)
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let data = self.data[indexPath.section]
        self.goToDetail(self.statu,data:data)
    }
    //MARK: - **************TableViewCell****************
    func cellForProduct(tableView:UITableView, indexPath:NSIndexPath) -> UITableViewCell {
        let cellId = "ProductCell"
        var cell = tableView.dequeueReusableCellWithIdentifier(cellId) as? CollectionGoodsCell
        if cell == nil {
            cell = CollectionGoodsCell(style: .Subtitle, reuseIdentifier: cellId)
        }
        var tag = 10000
        let imgV = cell?.viewWithTag(tag++) as! UIImageView
        let goodsLbl = cell?.viewWithTag(tag++) as! UILabel
        let detailLbl = cell?.viewWithTag(tag++) as! UILabel
        let goodsPriceLbl = cell?.viewWithTag(tag++) as! UILabel
        //        let freightLbl = cell?.viewWithTag(tag++) as! UILabel
        let cancelBtn = cell?.viewWithTag(tag++) as! UIButton
        
        if let item = self.data[indexPath.section] as? ZMDShoppingItem {
            if let imgUrl = item.Picture?.ImageUrl {
                imgV.sd_setImageWithURL(NSURL(string: kImageAddressMain+imgUrl))
            }
            goodsLbl.text = item.ProductName
            detailLbl.text = (item.AttributeInfo as NSString).stringByReplacingOccurrencesOfString("<br />", withString: " ")
            //            goodsPriceLbl.text = item.SubTotal
            goodsPriceLbl.attributedText = "\(item.SubTotal) 原价:\(item.UnitPrice)".AttributeText([item.SubTotal,"原价:\(item.UnitPrice)"], colors: [RGB(235,61,61,1),UIColor.lightGrayColor()], textSizes: [14,12])
            //            freightLbl.text = "不包邮"
            cancelBtn.rac_command = RACCommand(signalBlock: { (sender) -> RACSignal! in
                self.deleteCartItem("\(item.Id.integerValue)")
                return RACSignal.empty()
            })
        }
        return cell!
    }
    
    func cellForStore(tableView:UITableView,indexPath:NSIndexPath) -> UITableViewCell {
        let cellId = "OtherCell"
        var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
        let store = self.data[indexPath.section] as! ZMDStoreDetail
        if cell == nil {
            cell = UITableViewCell(style: .Subtitle, reuseIdentifier: cellId)
            cell?.accessoryType = UITableViewCellAccessoryType.None
            cell!.selectionStyle = .None
            
            ZMDTool.configTableViewCellDefault(cell!)
            var tag = 10000
            let imgV = UIImageView(frame: CGRect(x: zoom(12), y: zoom(12), width: zoom(60), height: zoom(60)))
            imgV.backgroundColor = UIColor.clearColor()
            imgV.tag = tag++
            cell?.contentView.addSubview(imgV)
            
            let storeLbl = ZMDTool.getLabel(CGRect(x: zoom(12+60+10), y: zoom(20), width: kScreenWidth - 82-75-10, height: zoom(15)), text: "", fontSize: 15)
            storeLbl.tag = tag++
            cell?.contentView.addSubview(storeLbl)
            
            let storeGoodsLbl = ZMDTool.getLabel(CGRect(x: zoom(12+60+10), y: zoom(85-35), width: kScreenWidth - 82-75-10, height: zoom(15)), text: "", fontSize: 15,textColor: defaultDetailTextColor)
            storeGoodsLbl.tag = tag++
            cell?.contentView.addSubview(storeGoodsLbl)
            
            let goToBtn = ZMDTool.getButton(CGRect(x: kScreenWidth - 75, y: zoom(20), width: zoom(75), height: zoom(15)), textForNormal: "进入店铺", fontSize: 14, backgroundColor: UIColor.clearColor(), blockForCli: { (sender) -> Void in
                let vc = StoreShowHomeViewController.CreateFromMainStoryboard() as! StoreShowHomeViewController
                if let storeId = store.Id {
                    vc.storeId = storeId
                    self.pushToViewController(vc, animated: true, hideBottom: true)
                }else{
                    print("店铺Id为空")
                }
            })
            goToBtn.tag = tag++
            cell?.contentView.addSubview(goToBtn)
            
            let cancelBtn = ZMDTool.getButton(CGRect(x: kScreenWidth - 75, y: zoom(85-20-15), width: zoom(75), height: zoom(15)), textForNormal: "取消关注", fontSize: 14,textColorForNormal:defaultTextColor, backgroundColor: UIColor.clearColor(), blockForCli: { (sender) -> Void in
                self.cancelCollect(store)
            })
            cancelBtn.tag = tag++
            cell?.contentView.addSubview(cancelBtn)
            cell?.addLine()
        }
        var tag = 10000
        let imgV = cell?.viewWithTag(tag++) as! UIImageView
        let storeLbl = cell?.viewWithTag(tag++) as! UILabel
        let storeGoodsLbl = cell?.viewWithTag(tag++) as! UILabel
        let cancelBtn = cell?.viewWithTag(tag++) as! UIButton
        let goToBtn = cell?.viewWithTag(tag++) as! UIButton
        
        if let urlStr = store.PictureUrl, url = NSURL(string: kImageAddressMain+urlStr) {
            imgV.sd_setImageWithURL(url, placeholderImage: nil)
        }
        if let name = store.Name {
            storeLbl.text = name
        }
        if let host = store.Host {
            storeGoodsLbl.text = "主营: \(host)"
        }
        return cell!
    }

    func cellForDetail(tableView:UITableView, indexPath:NSIndexPath) -> UITableViewCell {
        let cellId = "detailCell"
        var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
        if cell == nil {
            cell = UITableViewCell(style: .Default, reuseIdentifier: cellId)
            ZMDTool.configTableViewCellDefault(cell!)
            let detailView = NSBundle.mainBundle().loadNibNamed("SupplyDemandView", owner: nil, options: nil).first as! CollectionDetailView
            detailView.tag = 10000
            cell?.contentView.addSubview(detailView)
            cell?.addLine()
        }
        let detailView = cell?.contentView.viewWithTag(10000) as! CollectionDetailView
//        let supplyProduct = self.data[indexPath.section] as! ZMDSupplyProduct
//        CollectionDetailView.configDetailView(detailView, data: supplyProduct)
        return cell!
    }
    func cellForAction(tableView:UITableView, indexPath:NSIndexPath) -> UITableViewCell {
        let titles = ["取消收藏","查看详情"]
        let width = zoom(85)
        var index = -1
        let cellId = "actionCell"
        var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
        if cell == nil {
            cell = UITableViewCell(style: .Default, reuseIdentifier: cellId)
//            ZMDTool.configTableViewCellDefault(cell!)
            for title in titles {
                index = index + 1
                let btn = ZMDTool.getButton(CGRect(x: kScreenWidth-zoom(12)-CGFloat(index)*zoom(10+85)-width, y: zoom(10), width: width, height: zoom(34)), textForNormal: title, fontSize: 13, backgroundColor: UIColor.clearColor(), blockForCli: { (sender) -> Void in
                    if (sender as! UIButton).tag == 1000 {
                        //详情
                    }else{
                        //修改
                    }
                })
                btn.tag = 1000+index
                ZMDTool.configViewLayer(btn)
                ZMDTool.configViewLayerFrameWithColor(btn, color: defaultLineColor)
                cell?.contentView.addSubview(btn)
            }
        }
        return cell!
    }
    //MARK: -  *************PrivateMethod****************
    private func subViewInit(){
        self.title = "我的收藏"
        let segment = self.viewForSegment()
        self.view.addSubview(segment)
        self.currentTableView = UITableView(frame: CGRect(x: 0, y: zoom(60), width: kScreenWidth, height: kScreenHeight - 64))
        self.currentTableView.backgroundColor = tableViewdefaultBackgroundColor
        self.currentTableView.separatorStyle = .None
        self.currentTableView.dataSource = self
        self.currentTableView.delegate = self
        self.view.addSubview(self.currentTableView)
    }
    func dataUpdate() {
        ZMDTool.showActivityView(nil)
        if self.statu == .Product {
            QNNetworkTool.fetchShoppingCart(2){ (shoppingItems, dictionary, error) -> Void in
                ZMDTool.hiddenActivityView()
                if shoppingItems != nil {
                    self.data = NSMutableArray(array: shoppingItems!)
                    self.currentTableView.reloadData()
                } else {
                    ZMDTool.showErrorPromptView(dictionary, error: error, errorMsg: nil)
                }
            }
        }else{
            QNNetworkTool.collectStoresList({ (success, stores, error) -> Void in
                ZMDTool.hiddenActivityView()
                if success {
                    self.data = NSMutableArray(array: stores!)
                    self.currentTableView.reloadData()
                }else{
                    ZMDTool.showErrorPromptView(nil, error: error)
                }
            })
        }

    }
    
    func viewForSegment() -> UIView {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: zoom(60)))
        view.backgroundColor = defaultGrayColor
        let bgV = UIView(frame: CGRect(x: zoom(100), y: zoom(12), width: kScreenWidth-zoom(200), height: zoom(36)))
        bgV.backgroundColor = UIColor.clearColor()
        ZMDTool.configViewLayer(bgV)
        ZMDTool.configViewLayerFrameWithColor(bgV, color: defaultDetailTextColor)
//        let titles = ["供应信息","求购信息","商品"]
        let titles = ["店铺","商品"]
        let btnArray = NSMutableArray()
        let (titleNormalColor,bgNormalColor) = (defaultTextColor,UIColor.clearColor())
        let (titleSelectColor,bgSelectColor) = (UIColor.whiteColor(),appThemeColor)
        var index = -1
        let width = (kScreenWidth-zoom(200.0))/2
        for title in titles {
            index = index + 1
            let btn = ZMDTool.getButton(CGRect(x:CGFloat(index) * width, y: 0, width: width, height: zoom(36)), textForNormal: title, fontSize: 14, backgroundColor: UIColor.clearColor(), blockForCli: { (sender) -> Void in
                if (sender as! UIButton).selected {return}
                for item in btnArray {
                    if (item as! UIButton).tag == (sender as! UIButton).tag {
                        (item as! UIButton).selected = true
                        self.statu = StatuType(rawValue: (item as! UIButton).tag)!
                    }else{
                        (item as! UIButton).selected = false
                    }
                }
                self.dataUpdate()
            })
            btnArray.addObject(btn)
            if index != 2 {
                btn.addSubview(ZMDTool.getLine(CGRect(x: width-0.5, y: 0, width: 0.5, height: zoom(36)), backgroundColor: defaultLineColor))
            }
            btn.tag = index
            btn.setTitleColor(titleNormalColor, forState: UIControlState.Normal)
            btn.setTitleColor(titleSelectColor, forState: UIControlState.Selected)
            btn.setBackgroundImage(UIImage.colorImage(bgNormalColor, size: CGSize(width: width, height: zoom(35))), forState: .Normal)
            btn.setBackgroundImage(UIImage.colorImage(bgSelectColor, size: CGSize(width: width, height: zoom(35))), forState: .Selected)
            bgV.addSubview(btn)
            btn.selected = index == 0
        }
        view.addSubview(bgV)
        return view
    }
    
    //取消收藏商品
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
    
    //取消收藏店铺
    func cancelCollect(store:ZMDStoreDetail) {
        if store.Id == nil {
            ZMDTool.showPromptView("店铺Id为空")
            return
        }
        QNNetworkTool.cancelCollectStores(store.Id.integerValue) { (succeed, error, dictionary) -> Void in
            if succeed! {
                ZMDTool.showPromptView("取消关注成功")
                self.dataUpdate()
            }else{
                ZMDTool.showPromptView("取消关注失败")
            }
        }
    }
    
    //进入商品详情或店铺详情
    func goToDetail(statu:StatuType,data:AnyObject) {
        if statu == .Product {
            if let productId = (data as! ZMDProduct).Id {
                let vc = HomeBuyGoodsDetailViewController.CreateFromMainStoryboard() as! HomeBuyGoodsDetailViewController
                vc.productId = productId.integerValue
                self.pushToViewController(vc, animated: true, hideBottom: true)
            }else{
                print("商品Id为空")
            }
        }else{
            if let storeId = (data as! ZMDStoreDetail).Id {
                let vc = StoreShowHomeViewController.CreateFromMainStoryboard() as! StoreShowHomeViewController
                vc.storeId = storeId
                self.pushToViewController(vc, animated: true, hideBottom: true)
            }else{
                print("店铺Id为空")
            }
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
//        freightLbl.tag = tag++
//        self.contentView.addSubview(freightLbl)
        
        let width = "取消收藏".sizeWithFont(UIFont.systemFontOfSize(14), maxWidth: 120).width
        let cancelBtn = ZMDTool.getButton(CGRect(x: 12+125+10, y: 150-12-14, width: width, height: 15), textForNormal: "取消收藏", fontSize: 14,textColorForNormal:defaultDetailTextColor, backgroundColor: UIColor.clearColor(), blockForCli: { (sender) -> Void in
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
