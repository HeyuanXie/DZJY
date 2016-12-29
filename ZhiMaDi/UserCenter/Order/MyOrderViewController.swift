//
//  MyOrderViewController.swift
//  ZhiMaDi
//
//  Created by haijie on 16/3/30.
//  Copyright © 2016年 ZhiMaDi. All rights reserved.
//

import UIKit
import MJRefresh
// 订单状态
enum OrderStatu {
    case All                //  全部
    case UnPay              //  待支付
    case UnShipping         //  待发货
    case WaitShipping       //  待收货
    case UnComment          //  待评价
    case Completed          //  已完成
    case Canceled           //  已取消
    init() {
        self = UnPay
    }
    init(value : Int) {
        switch value {
        case 0 :
            self = All
        case 1 :
            self = UnPay
        case 2 :
            self = UnShipping
        case 3 :
            self = WaitShipping
        case 4 :
            self = UnComment
        case 5:
            self = Completed
        case 6:
            self = Canceled
        default :
            self = All
        }
    }
    //OrderStatusId == 40 时，订单已取消
    init(OrderStatusId:Int,ShippingStatusId:Int?,PaymentStatusId:Int?) {
        self = UnPay
        if OrderStatusId == 10 {
            self = UnPay
        }
        if OrderStatusId == 20 && (ShippingStatusId ?? 0) == 20 && (PaymentStatusId ?? 0) == 30 {
            self = UnShipping
        }
        if OrderStatusId == 20 && (ShippingStatusId ?? 0) == 30 {
            self = WaitShipping
        }
        if OrderStatusId == 20 && (ShippingStatusId ?? 0) == 40 && (PaymentStatusId ?? 0) == 30 {
            self = UnComment
        }
        if OrderStatusId == 40 {
            self = Canceled
        }
        if OrderStatusId == 30 && (ShippingStatusId ?? 0) == 40 && (PaymentStatusId ?? 0) == 30 {
            self = Completed
        }
    }
    
    func url(skip:Int) -> String {
        let tmp = NSMutableString(string: "/Orders?$top=10")
        switch self {
        case .All:
            tmp.appendString("&$filter= CustomerId eq \(g_customerId!)")
        case .UnPay:
            tmp.appendString("&$filter=OrderStatusId eq 10 and CustomerId eq \(g_customerId!)")
        case .UnShipping:
            tmp.appendString("&$filter=OrderStatusId eq 20 and ShippingStatusId eq 20 and PaymentStatusId eq 30 and CustomerId eq \(g_customerId!)")
        case .WaitShipping:
            tmp.appendString("&$filter=OrderStatusId eq 20 and ShippingStatusId eq 30 and PaymentStatusId eq 30 and CustomerId eq \(g_customerId!)")
        case .UnComment:
            tmp.appendString("&$filter=OrderStatusId eq 20 and ShippingStatusId eq 40 and PaymentStatusId eq 30 and CustomerId eq \(g_customerId!)")
        case .Completed:
            tmp.appendString("&$filter=OrderStatusId eq 30 and ShippingStatusId eq 40 and PaymentStatusId eq 30 and CustomerId eq \(g_customerId!)")
        case .Canceled:
            break
        }
        tmp.appendString("&$expand=OrderItems,OrderItems/Product,OrderItems/Product/ProductPictures&$select=OrderTotal,OrderItems/Product/Name,OrderItems/UnitPriceInclTax,OrderItems/UnitPriceExclTax,OrderItems/Quantity,Id,OrderItems/AttributeDescription,OrderItems/Product/ProductPictures/PictureId,OrderStatusId,ShippingStatusId,PaymentStatusId&$skip=\(skip)")
        return tmp as String
    }
}
// 我的订单
class MyOrderViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,ZMDInterceptorProtocol {
    @IBOutlet weak var currentTableView: UITableView!
    var dataArray = NSMutableArray()
    var footer :MJRefreshFooter!
    var currentOrderStatu = OrderStatu.All
    var orderStatuId = 0
    var skip = 0
    var hasNext = true
    var orderStatusIndex: Int!
    var isAfterSale = false     //区分 售后/退货
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.updateUI()
        self.currentOrderStatu = self.orderStatusIndex == 4 ? .UnComment : OrderStatu(value: self.orderStatusIndex)
//        self.updateData1()
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        self.updateData1()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    //MARK:- UITableViewDataSource,UITableViewDelegate
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let order = (self.dataArray[section] as! ZMDOrderDetail2).Order
        return self.isAfterSale ? 2 + order.Items.count : 3 + order.Items.count
    }
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.isAfterSale ? 0 : self.dataArray.count   //TODO:暂时没有售后的
    }
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 16
    }
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let order = (self.dataArray[indexPath.section] as! ZMDOrderDetail2).Order
        
        if indexPath.row == 0 {
            return 40
        }else if indexPath.row < order.Items.count + 1 {
            return 110
        }else{
            return 56
        }
    }
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headView = UIView(frame: CGRectMake(0, 0, kScreenWidth, 8))
        headView.backgroundColor = UIColor.clearColor()
        return headView
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == self.dataArray.count - 1 && self.hasNext {
            self.skip += 1
            self.updateData1()
        }
        let orderDetail = self.dataArray[indexPath.section] as! ZMDOrderDetail2
        let Items = orderDetail.Order.Items
        if indexPath.row == 0 {
            return self.cellForStatu(tableView, cellForRowAtIndexPath: indexPath)
        }
        if indexPath.row <  Items.count + 1 {
            return self.cellForgoods(tableView, cellForRowAtIndexPath: indexPath)
        }
        if indexPath.row == Items.count + 1 {
            return self.cellForTotal(tableView, cellForRowAtIndexPath: indexPath)
        }
        if indexPath.row == Items.count + 2 {
            return self.cellForMenu(tableView, cellForRowAtIndexPath: indexPath)
        }
        
        if indexPath.row == 0 {
            let cellId = "StoreCell"
            let cell = tableView.dequeueReusableCellWithIdentifier(cellId)
            let line = ZMDTool.getLine(CGRect(x: 0, y: 47.5, width: kScreenWidth, height: 0.5))
            cell?.contentView.addSubview(line)
            return cell!
        } else if indexPath.row == 2 {
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
        } else if indexPath.row == 3 {
            let cellId = "MenuCell"
            var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
            if cell == nil {
                cell = UITableViewCell(style: .Subtitle, reuseIdentifier: cellId)
                cell?.accessoryType = UITableViewCellAccessoryType.None
                cell!.selectionStyle = .None
                ZMDTool.configTableViewCellDefault(cell!)
                
                let line = ZMDTool.getLine(CGRect(x: 0, y: 55.5, width: kScreenWidth, height: 0.5))
                cell?.contentView.addSubview(line)
                
                let titles = ["到期归还","到期续租","评价","订单详情"]
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
                            let vc = OrderGoodsScoreViewController()
                            self.navigationController?.pushViewController(vc, animated: true)
                        }
                    })
                    btn.tag = 1000+i
                    i++
                    ZMDTool.configViewLayerFrame(btn)
                    ZMDTool.configViewLayer(btn)
                    cell?.contentView.addSubview(btn)
                }
            }
            return cell!
            
        } else if indexPath.row == 4 {
            let cellId = "ReturnCell"
            var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
            if cell == nil {
                cell = UITableViewCell(style: .Subtitle, reuseIdentifier: cellId)
                cell?.accessoryType = UITableViewCellAccessoryType.None
                cell!.selectionStyle = .None
                ZMDTool.configTableViewCellDefault(cell!)
            }
            let label = ZMDTool.getLabel(CGRect(x: 12, y: 0, width: kScreenWidth - 24, height: 42), text: "剩余归还时间：47时:56分:10秒", fontSize: 14,textColor:RGB(235,61,61,1.0))
            label.textAlignment = .Right
            cell?.contentView.addSubview(label)
            return cell!
        } else {
            let cellId = "GoodsCell"
            let cell = tableView.dequeueReusableCellWithIdentifier(cellId) as! OrderGoodsTableViewCell
            return cell
        }
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let orderDetail = self.dataArray[indexPath.section] as! ZMDOrderDetail2
        let Items = orderDetail.Order.Items
        if indexPath.row <  Items.count+1 && indexPath.row != 0 {
            let item = Items[indexPath.row-1]
            let vc = HomeBuyGoodsDetailViewController.CreateFromMainStoryboard() as! HomeBuyGoodsDetailViewController
            vc.productId = item.ProductId.integerValue
            self.pushToViewController(vc, animated: true, hideBottom: true)
        }

    }
    //MARK: -  PrivateMethod
    func updateUI() {
        self.currentTableView.backgroundColor = tableViewdefaultBackgroundColor
        self.currentTableView.showsVerticalScrollIndicator = false
        footer = MJRefreshFooter(refreshingTarget: self, refreshingAction: Selector("footerRefresh"))
        self.currentTableView.mj_footer = footer
        let orderStatuIds = [0,1,2,3,4,5,6]
        let menuTitle = ["全部","待付款","待发货","待收货","待评价"]
        let customJumpBtns = CustomJumpBtns(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 55),menuTitle: menuTitle)
        customJumpBtns.finished = {(index)->Void in
            self.currentTableView.contentOffset = CGPoint(x: 0, y: 0) //切换订单状态时让tableView回到第一行
            let orderStatus = OrderStatu(value: index)
            self.currentOrderStatu = orderStatus
            self.orderStatuId = orderStatuIds[index]
            self.skip = 0
            self.hasNext = false
            self.updateData1()
        }
        customJumpBtns.tag = 200
        self.view.addSubview(customJumpBtns)
        
        if self.isAfterSale {
            self.title = "退款/售后"
            customJumpBtns.hidden = true
            self.currentTableView.snp_updateConstraints(closure: { (make) -> Void in
                make.top.equalTo(0)
                make.bottom.equalTo(0)
            })
        }
    }
    
    /*func updateData() {
    ZMDTool.showActivityView(nil)
    QNNetworkTool.fetchOrder(self.currentOrderStatu.url(self.skip*10)) { (value, error) -> Void in
    ZMDTool.hiddenActivityView()
    self.hasNext = false
    
    if error == nil {
    let orders = ZMDOrderDetail.mj_objectArrayWithKeyValuesArray(value)
    if orders.count == 10 {
    self.hasNext = true
    }
    if self.skip == 0 {
    self.dataArray.removeAllObjects()
    }
    self.dataArray.addObjectsFromArray(orders as [AnyObject])
    self.currentTableView.reloadData()
    }else{
    ZMDTool.showErrorPromptView(nil, error: error)
    }
    }
    }*/
    
    func updateData1() {
        ZMDTool.showActivityView(nil)
        QNNetworkTool.fetchOrder(self.orderStatuId, orderNo: "", pageIndex: self.skip, pageSize: 10) { (orders ,dic, Error) -> Void in
            ZMDTool.hiddenActivityView()
            self.hasNext = false
            if let orders = orders {
                if orders.count == 10 {
                    self.hasNext = true
                }
                if self.skip == 0 {
                    self.dataArray.removeAllObjects()
                }
                self.dataArray.addObjectsFromArray(orders as [AnyObject])
                self.currentTableView.reloadData()
            }else{
                ZMDTool.showErrorPromptView(dic, error: Error)
            }
        }
    }
    
    //MARK: FooterRefresh
    func footerRefresh() {
        self.skip += 1
        self.updateData1()
        if self.hasNext == false {
            self.currentTableView.mj_footer.endRefreshingWithNoMoreData()
        }else {
            self.currentTableView.mj_footer.endRefreshing()
        }
    }
    
    func cellForgoods(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellId = "GoodsCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellId) as! OrderGoodsTableViewCell
        let order = (self.dataArray[indexPath.section] as! ZMDOrderDetail2).Order
        let orderItem = order.Items[indexPath.row-1]
        cell.configCellForMyOrder(orderItem)
        return cell
    }
    func cellForTotal(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if self.isAfterSale {
            let  cellId = "AfterSaleTotalCell"
            var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
            if cell == nil {
                cell = UITableViewCell(style: .Subtitle, reuseIdentifier: cellId)
                cell?.accessoryType = UITableViewCellAccessoryType.None
                cell!.selectionStyle = .None
                ZMDTool.configTableViewCellDefault(cell!)
                
                let width = (kScreenWidth-2*12)/2
                for i in 0..<2 {
                    let label = ZMDTool.getLabel(CGRect(x: 12+CGFloat(i)*width, y: 0, width: width, height: 56), text: "", fontSize: 14, textColor: defaultTextColor, textAlignment: .Right)
                    cell?.contentView.addSubview(label)
                    label.tag = 10000 + i
                }
            }
            //UpdaeCell
            let orderDetail = self.dataArray[indexPath.section] as! ZMDOrderDetail2
            let orderTotal = orderDetail.OrderTotal
            let texts = ["交易金额:\(orderTotal)","退款金额:\(orderTotal)"]
            for i in 0..<2 {
                let label = cell?.contentView.viewWithTag(10000+i) as! UILabel
                label.text = texts[i]
            }
            return cell!
        }
        let cellId = "TotalCell"
        var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
        if cell == nil {
            cell = UITableViewCell(style: .Subtitle, reuseIdentifier: cellId)
            cell?.accessoryType = UITableViewCellAccessoryType.None
            cell!.selectionStyle = .None
            ZMDTool.configTableViewCellDefault(cell!)
            
            let line = ZMDTool.getLine(CGRect(x: 0, y: 55.5, width: kScreenWidth, height: 0.5))
            cell?.contentView.addSubview(line)
            let label = ZMDTool.getLabel(CGRect(x: 12, y: 0, width: kScreenWidth - 24, height: 55.5), text: "共\(self.dataArray.count)件商品,合计:0.0", fontSize: 14) // (含运费 : 0.00)
            label.textAlignment = .Right
            label.tag = 10001
            cell?.contentView.addSubview(label)
        }
        let orderDetail = self.dataArray[indexPath.section] as! ZMDOrderDetail2
        let orderTotal = orderDetail.OrderTotal
        let order = (self.dataArray[indexPath.section] as! ZMDOrderDetail2).Order
        let orderShipping = order.OrderShipping
        
        let lbl = cell?.viewWithTag(10001) as! UILabel
        //计算商品数量和运费
        var count : Int = 0
        for item in order.Items {
            count += item.Quantity.integerValue
        }
        
        let text = "共\(count)件商品 合计:\(orderTotal)(含运费:\(orderShipping))"
        lbl.attributedText = text.AttributeText([orderTotal], colors: [UIColor.blackColor()], textSizes: [16])
        return cell!
    }
    
    func cellForStatu(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath)->UITableViewCell {
        let cellId = "StatuCell"
        var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
        if cell == nil {
            cell = UITableViewCell(style: .Default, reuseIdentifier: cellId)
            cell?.selectionStyle = .None
            ZMDTool.configTableViewCellDefault(cell!)
            
            let height = CGFloat(40.0)
            let orderNumberLbl = ZMDTool.getLabel(CGRectZero, text: "", fontSize: 14, textColor: defaultTextColor, textAlignment: .Left)
            orderNumberLbl.tag = 10001
            let statuLbl = ZMDTool.getLabel(CGRectZero, text: "", fontSize: 14, textColor: defaultSelectColor, textAlignment: .Right)
            statuLbl.tag = 10002
            let statuImg = UIImageView(frame: CGRectZero)
            statuImg.image = UIImage(named: "order_status")
            cell?.contentView.addSubview(statuLbl)
            cell?.contentView.addSubview(statuImg)
            cell?.contentView.addSubview(orderNumberLbl)
            cell?.contentView.addSubview(ZMDTool.getLine(CGRect(x: 0, y: height-0.5, width: kScreenWidth, height: 0.5), backgroundColor: defaultLineColor))
            statuLbl.snp_makeConstraints(closure: { (make) -> Void in
                make.top.equalTo(0)
                make.right.equalTo(-12)
                make.size.equalTo(CGSize(width: 50, height: height-0.5))
            })
            statuImg.snp_makeConstraints(closure: { (make) -> Void in
                make.top.equalTo((height-20)/2)
                make.right.equalTo(-54)
                make.size.equalTo(CGSize(width: 20, height: 20))
            })
            orderNumberLbl.snp_makeConstraints(closure: { (make) -> Void in
                make.left.equalTo(12)
                make.top.equalTo(0)
                make.height.equalTo(height-0.4)
                make.rightMargin.equalTo(statuImg).offset(3)
            })
        }
        
        let orderDetail = self.dataArray[indexPath.section] as! ZMDOrderDetail2
        let orderNumberLbl = cell?.contentView.viewWithTag(10001) as! UILabel
        let statuLbl = cell?.contentView.viewWithTag(10002) as! UILabel
        
        orderNumberLbl.text = "订单号: "+orderDetail.OrderNumber
        
        statuLbl.text = orderDetail.Order.orderStatu()
        
        return cell!
    }
    
    func cellForMenu(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellId = "MenuCell"
        var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
        if cell == nil {
            cell = UITableViewCell(style: .Subtitle, reuseIdentifier: cellId)
            cell?.accessoryType = UITableViewCellAccessoryType.None
            cell!.selectionStyle = .None
            ZMDTool.configTableViewCellDefault(cell!)
            let line = ZMDTool.getLine(CGRect(x: 0, y: 55.5, width: kScreenWidth, height: 0.5))
            cell?.contentView.addSubview(line)
            
            let titles = ["删除订单","取消订单","订单详情","付款"]
            var i = 0,minX = CGFloat(0)
            for title in titles {
                let size = title.sizeWithFont(UIFont.systemFontOfSize(14), maxWidth: 100)
                let width = size.width+32 ,height = CGFloat(35)
                let x = kScreenWidth - 12 - width - minX,y = CGFloat(12)
                minX = kScreenWidth - x
                let btn = ZMDTool.getMutilButton(CGRect(x: x, y: y, width: width, height: height), textForNormal: title, fontSize: 14, backgroundColor: UIColor.whiteColor(), blockForCli: { (sender) -> Void in
                })
                btn.tag = 1000+i
                i++
                ZMDTool.configViewLayerFrame(btn)
                ZMDTool.configViewLayer(btn)
                cell?.contentView.addSubview(btn)
                //这里只是将btn的frame计算出来并加载到cell.contentView，btn的title根据情况再设置，所以这里将btn隐藏
                btn.hidden = true
            }
        }
        
        let orderDetail = self.dataArray[indexPath.section] as! ZMDOrderDetail2
        let orderStatusId = orderDetail.Order.OrderStatusId.integerValue
        let shippingStatusId = orderDetail.Order.ShippingStatusId.integerValue
        let paymentStatusId = orderDetail.Order.PaymentStatusId.integerValue
        let payMethod = orderDetail.Order.PaymentMethod
        
//        let orderStatu = OrderStatu(OrderStatusId: orderStatusId, ShippingStatusId: shippingStatusId, PaymentStatusId: paymentStatusId)
        let orderStatu = self.orderStatuId == 4 ? .UnComment : OrderStatu(OrderStatusId: orderStatusId, ShippingStatusId: shippingStatusId, PaymentStatusId: paymentStatusId)

        switch orderStatu {
        case .UnPay :
            let titles = payMethod == "货到付款" ? ["取消订单","订单详情","",""] : [" 付款 ","取消订单","订单详情",""]
            self.doForOrderStatus(cell,titles: titles,orderDetail: orderDetail)
            break
        case .UnShipping :
            let titles = ["订单详情","","",""]
            self.doForOrderStatus(cell,titles: titles,orderDetail: orderDetail)
            break
        case .WaitShipping :
            let titles = ["确认签收","订单详情","",""]
            self.doForOrderStatus(cell,titles: titles,orderDetail: orderDetail)
            break
        case .UnComment :
            let titles = [" 评价 ","订单详情",""]
            self.doForOrderStatus(cell,titles: titles,orderDetail: orderDetail)
            break
        case .Completed :
            let titles = ["订单详情","","",""]
            self.doForOrderStatus(cell, titles: titles, orderDetail: orderDetail)
            break
        case .Canceled :
            let titles = ["订单详情","","",""]
            self.doForOrderStatus(cell, titles: titles, orderDetail: orderDetail)
            break
        default:
            let titles = ["订单详情","","",""]
            self.doForOrderStatus(cell, titles: titles, orderDetail: orderDetail)
            break
        }
        return cell!
    }
    
    func doForOrderStatus(cell:UITableViewCell?,titles : [String],orderDetail:ZMDOrderDetail2) {
        var i = 0,minX = CGFloat(0)
        let order = orderDetail.Order
        for title in titles {
            let size = title.sizeWithFont(UIFont.systemFontOfSize(14), maxWidth: 100)
            let width = size.width + 16 ,height = CGFloat(35)
            let x = kScreenWidth - 12 - width - minX,y = CGFloat(12)
            minX = kScreenWidth - x
            
            let btn = cell?.viewWithTag(1000+i) as! UIButton
            btn.setTitle(title, forState: .Normal)
            
            btn.frame = CGRect(x: x, y: y, width: width, height: height)
            btn.rac_command = RACCommand(signalBlock: { (sender) -> RACSignal! in
                if titles[sender.tag-1000] == "订单详情" {
                    let vc = MyOrderDetailViewController.CreateFromMainStoryboard() as! MyOrderDetailViewController
                    vc.orderId = order.Id.integerValue
                    self.navigationController?.pushViewController(vc, animated: true)
                } else if titles[sender.tag-1000] == " 评价 " {
                    let vc = OrderCommentViewController()
                    vc.orderId = order.Id
                    self.pushToViewController(vc, animated: true, hideBottom: true)
                } else if titles[sender.tag-1000] == "取消订单" {
                    let orderId = order.Id.integerValue
                    let alert = UIAlertController(title: "提醒", message: "确定删除此订单?", preferredStyle: .Alert)
                    let action1 = UIAlertAction(title: "确定", style: UIAlertActionStyle.Destructive, handler: { (sender) -> Void in
                        ZMDTool.showActivityView(nil)
                        QNNetworkTool.cancelOrder(orderId, completion: { (succeed, dictionary, error) -> Void in
                            ZMDTool.hiddenActivityView()
                            if succeed! {
                                self.skip = 0
                                self.updateData1()
                                ZMDTool.showPromptView("订单已取消")
                            } else {
                                ZMDTool.showPromptView("订单已取消,请勿重新操作")
                            }
                        })
                    })
                    let action2 = UIAlertAction(title: "取消", style: .Cancel, handler: { (sender) -> Void in
                        
                    })
                    alert.addAction(action1)
                    alert.addAction(action2)
                    self.presentViewController(alert, animated: true, completion: nil)
                }else if titles[sender.tag-1000] == "确认签收" {
                    let orderId = order.Id.integerValue
                    ZMDTool.showActivityView(nil)
                    QNNetworkTool.completeOrder(orderId, completion: { (succeed, dictionary, error) -> Void in
                        ZMDTool.hiddenActivityView()
                        if succeed! {
                            let vc = TradeSuccessedViewController()
                            vc.hidesBottomBarWhenPushed = true
                            self.navigationController?.pushViewController(vc, animated: true)
                        }else{
                            ZMDTool.showErrorPromptView(dictionary, error: error, errorMsg: nil)
                        }
                    })
                } else if titles[sender.tag-1000] == " 付款 " {
                    if order.OrderStatusId == 40 {
                        ZMDTool.showPromptView("订单已取消,无法付款")
                    } else {
                        let orderId = order.Id.integerValue
                        ZMDTool.showActivityView(nil)
                        /*重新获取支付方式*/
                        QNNetworkTool.fetchRePaymentMethod(orderId, completion: { (paymentMethods, dictionary, error) -> Void in
                            ZMDTool.hiddenActivityView()
                            if paymentMethods != nil {
                                let vc = CashierViewController()
                                vc.total = order.OrderTotal
                                vc.orderId = orderId
                                vc.payMethods = NSMutableArray(array: paymentMethods)
                                vc.hidesBottomBarWhenPushed = true
                                self.navigationController?.pushViewController(vc, animated:true)
                            }
                        })
                    }
                } else if titles[sender.tag-1000] == "删除订单"{
                    self.dataArray.removeObject(order)
                    self.currentTableView.reloadData()
                    //从服务器删除
                    //                    QNNetworkTool.deleteOrder...
                } else if titles[sender.tag-1000] == "跟踪物流"{
                    //跟踪物流
                    ZMDTool.showPromptView("功能暂未开放!")
                    print("跟踪物流")
                } else if titles[sender.tag-1000] == "确认签收"{
                    let orderId = order.Id.integerValue
                    QNNetworkTool.completeOrder(orderId, completion: { (succeed, dictionary, error) -> Void in
                        if succeed! {
                            let vc = TradeSuccessedViewController()
                            vc.hidesBottomBarWhenPushed = true
                            self.navigationController?.pushViewController(vc, animated: true)
                        }
                    })
                }
                return RACSignal.empty()
            })
            i++
            btn.hidden = title == "" ? true : false
        }
    }
    
    override func back() {
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
}
