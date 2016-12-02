//
//  OrderDetailViewController.swift
//  ZhiMaDi
//
//  Created by haijie on 16/3/30.
//  Copyright © 2016年 ZhiMaDi. All rights reserved.
//

import UIKit
// 我的订单详请
class MyOrderDetailViewController: UIViewController,ZMDInterceptorProtocol {
    
    enum UserCenterCellType{
        case OrderNum
        case LogisticsMsg
        case AcceptMsg
        
        case Store
        case Goods
        case Service
        
        case Pay
        case Mark
        case Invoice
        case Discount
        case Jifeng
        
        case Total
        
        init(){
            self = OrderNum
        }
        
        var title : String{
            switch self{
            case Pay :
                return "支付方式:"
            case Mark :
                return "备注"
            case Invoice :
                return "发票:"
            case Discount:
                return "优惠:"
            case Jifeng:
                return "获得积分:"
            default :
                return ""
            }
        }
    }
    
    @IBOutlet weak var currentTableView: UITableView!
    var userCenterData: [[UserCenterCellType]]!
    var orderId = 0  // ??
    var address : ZMDAddress!
    var products = NSMutableArray()
    var orderNotes = NSMutableArray()       //订单日志
    var dic : NSDictionary!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataInit()
//        self.updateUI()
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
    }
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(true)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK:- UITableViewDataSource,UITableViewDelegate
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let cellType = self.userCenterData[section][0]
        if cellType == .Goods {
            return self.products.count
        }
        return self.userCenterData[section].count
    }
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.userCenterData.count
    }
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return  16
    }
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if self.userCenterData[indexPath.section][0] == .Goods {
            return 110
        }
        let cellType = self.userCenterData[indexPath.section][indexPath.row]
        switch cellType {
        case .OrderNum :
            return 54
        case .LogisticsMsg :
            return 118
        case .AcceptMsg :
            return 100
        case .Store:
            return 48
        case .Goods :
            return 110
        case .Service:
            return 62
        case .Total:
            return 75
        default :
            return 56
        }
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if self.userCenterData[indexPath.section][0] == .Goods {
            let cellId = "GoodsCell"
            let cell = tableView.dequeueReusableCellWithIdentifier(cellId) as! OrderGoodsTableViewCell
            let product = self.products[indexPath.row] as! ZMDProductForOrderDetail
            cell.configCellForOrderDetail(product)
            return cell
        }
        let cellType = self.userCenterData[indexPath.section][indexPath.row]
        switch cellType {
        case .OrderNum:
            //订单号cell
            let cellId = "OrderNumCell"
            var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
            if cell == nil {
                cell = UITableViewCell(style: .Subtitle, reuseIdentifier: cellId)
                cell?.accessoryType = UITableViewCellAccessoryType.None
                cell!.selectionStyle = .None
                ZMDTool.configTableViewCellDefault(cell!)
                
                let numLbl = ZMDTool.getLabel(CGRect(x: 12, y: 0, width: 240, height: 54), text: "订单编号 ： 1524235232342", fontSize: 17)
                numLbl.tag = 10001
                cell?.contentView.addSubview(numLbl)
                let typeLbl = ZMDTool.getLabel(CGRect(x: kScreenWidth  - 92, y: 0, width: 80, height: 54), text: "****", fontSize: 17,textColor: RGB(235,61,61,1.0),textAlignment:.Right)
                typeLbl.tag = 10002
                cell?.contentView.addSubview(typeLbl)
                
                let line = ZMDTool.getLine(CGRect(x: 0, y: 53.5, width: kScreenWidth, height: 0.5))
                cell?.contentView.addSubview(line)
            }
            let numLbl = cell?.viewWithTag(10001) as! UILabel
            let typeLbl = cell?.viewWithTag(10002) as! UILabel
            if let orderNumber = self.dic?["OrderNumber"] as? String {
                numLbl.text = "订单编号 ：\(orderNumber)"
            }
            if let dic = self.dic {
                typeLbl.text = self.orderStatu(dic)
            }
            return cell!
        case .LogisticsMsg :
            //查看物流信息cell
            let cellId = "LogisticsMsgCell"
            var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
            if cell == nil {
                cell = UITableViewCell(style: .Subtitle, reuseIdentifier: cellId)
                cell?.accessoryType = UITableViewCellAccessoryType.None
                cell!.selectionStyle = .None
                ZMDTool.configTableViewCellDefault(cell!)
                
                let arrowImgV = UIImageView(frame: CGRect(x: kScreenWidth - 27, y: 12, width: 9, height: 15))
                arrowImgV.image = UIImage(named: "common_forward")
                let numLbl = ZMDTool.getLabel(CGRect(x: 12, y: 12, width: 300, height: 17), text: "订单跟踪", fontSize: 17)
                cell?.contentView.addSubview(numLbl)
                cell?.contentView.addSubview(arrowImgV)
                let wuliuLbl = ZMDTool.getLabel(CGRect(x: 12, y: 12+17+8, width: kScreenWidth-24, height: 38), text: "", fontSize: 15,textColor:defaultDetailTextColor)
                wuliuLbl.numberOfLines = 0
                cell?.contentView.addSubview(wuliuLbl)
                wuliuLbl.tag = 10001
                let orderLbl = ZMDTool.getLabel(CGRect(x: 12, y: 12+17+8+38+8, width: kScreenWidth-24, height: 15), text: "", fontSize: 15,textColor:defaultDetailTextColor)
                cell?.contentView.addSubview(orderLbl)
                orderLbl.tag = 10002
            }
            let wuliuLbl = cell?.contentView.viewWithTag(10001) as! UILabel
            let orderLbl = cell?.contentView.viewWithTag(10002) as! UILabel
            if self.orderNotes.count != 0 {
                let orderNote = self.orderNotes.firstObject as! ZMDOrderNote
                wuliuLbl.text = orderNote.Note
                //                wuliuLbl.text = "您的订单已发货，物流公司:同城快递，物流单号:45436565465"
                let str = orderNote.CreatedOn.stringByReplacingOccurrencesOfString("T", withString: " ")
                let timeText = str.componentsSeparatedByString(".").first
                orderLbl.text = "动态时间: " + timeText!
            }
            cell?.addLine()
            return cell!
        case .AcceptMsg :
            //收货地址cell
            let cellId = "AcceptMsgCell"
            var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
            if cell == nil {
                cell = UITableViewCell(style: .Subtitle, reuseIdentifier: cellId)
                cell?.accessoryType = UITableViewCellAccessoryType.None
                cell!.selectionStyle = .None
                ZMDTool.configTableViewCellDefault(cell!)
                
                var tag = 10001
                let userLbl = ZMDTool.getLabel(CGRect(x: 12, y: 16, width: 300, height: 17), text: "", fontSize: 17)
                userLbl.tag = tag++
                cell?.contentView.addSubview(userLbl)
                let phoneLbl = ZMDTool.getLabel(CGRect(x: kScreenWidth - 12 - 120, y: 16, width: 300, height: 17), text: "", fontSize: 17)
                phoneLbl.tag = tag++
                cell?.contentView.addSubview(phoneLbl)
                let addressStr = ""
                let addressSize = addressStr.sizeWithFont(defaultSysFontWithSize(17), maxWidth: kScreenWidth - 24)
                let addressLbl = ZMDTool.getLabel(CGRect(x: 12, y: 16 + 17 + 15, width: kScreenWidth - 24, height: addressSize.height), text: addressStr, fontSize: 17)
                addressLbl.numberOfLines = 2
                addressLbl.tag = tag++
                cell?.contentView.addSubview(addressLbl)
            }
            var tag = 10001
            let userLbl = cell?.viewWithTag(tag++) as! UILabel
            let phoneLbl = cell?.viewWithTag(tag++) as! UILabel
            let addressLbl = cell?.viewWithTag(tag++) as! UILabel

            if let dicForAddress = self.dic?["ShippingAddress"] as? NSDictionary,address = ZMDAddress.mj_objectWithKeyValues(dicForAddress) {
                userLbl.text = "收货人 ：\(address.FirstName)"
                phoneLbl.text = "\(address.PhoneNumber)"
                addressLbl.text = "收货地址:\(address.Address1!)\(address.Address2!)"
                let addressStr = addressLbl.text
                let addressSize = addressStr!.sizeWithFont(defaultSysFontWithSize(17), maxWidth: kScreenWidth - 24)
                addressLbl.frame = CGRect(x: 12, y: 16 + 17 + 15, width: kScreenWidth - 24, height: addressSize.height)
            }
            return cell!
        case .Store :
            //商家cell
            let cellId = "StoreCell"
            let cell = tableView.dequeueReusableCellWithIdentifier(cellId)
            let line = ZMDTool.getLine(CGRect(x: 0, y: 47.5, width: kScreenWidth, height: 0.5))
            cell?.contentView.addSubview(line)
            return cell!
        case .Goods :
            //商品cell
            let cellId = "GoodsCell"
            let cell = tableView.dequeueReusableCellWithIdentifier(cellId) as! OrderGoodsTableViewCell
            let product = self.products[indexPath.row] as! ZMDProductForOrderDetail
            cell.configCellForOrderDetail(product)
            return cell
        case .AcceptMsg :
            //收货地址cell
            let cellId = "AcceptMsgCell"
            var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
            if cell == nil {
                cell = UITableViewCell(style: .Subtitle, reuseIdentifier: cellId)
                cell?.accessoryType = UITableViewCellAccessoryType.None
                cell!.selectionStyle = .None
                ZMDTool.configTableViewCellDefault(cell!)
            }
            let userLbl = ZMDTool.getLabel(CGRect(x: 12, y: 16, width: 300, height: 54), text: "收货人 ：葫芦一娃", fontSize: 17)
            cell?.contentView.addSubview(userLbl)
            let phoneLbl = ZMDTool.getLabel(CGRect(x: 12, y: 16, width: 300, height: 54), text: "13780338447", fontSize: 17)
            cell?.contentView.addSubview(phoneLbl)
            let addressLbl = ZMDTool.getLabel(CGRect(x: 12, y: 16 + 17 + 15, width: kScreenWidth - 24, height: 54), text: "收货地址:广东省东莞市松山湖高新技术产业园新新", fontSize: 17)
            addressLbl.numberOfLines = 2
            cell?.contentView.addSubview(addressLbl)
            return cell!
        case .Service :
            //联系商家,退款售后
            let cellId = "ServiceCell"
            var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
            if cell == nil {
                cell = UITableViewCell(style: .Subtitle, reuseIdentifier: cellId)
                cell?.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
                cell!.selectionStyle = .None
                ZMDTool.configTableViewCellDefault(cell!)
            }
            let contactBtn = ZMDTool.getButton(CGRect(x: kScreenWidth/2-14-130 , y: 12, width: 130, height: 40), textForNormal: "联系商家", fontSize: 16, backgroundColor: UIColor.whiteColor(), blockForCli: { (sender) -> Void in
                
            })
            ZMDTool.configViewLayerFrameWithColor(contactBtn, color: defaultTextColor)
            ZMDTool.configViewLayer(contactBtn)
            contactBtn.setImage(UIImage(named: "product_chat"), forState: .Normal)
            cell?.contentView.addSubview(contactBtn)
            let fefundBtn = ZMDTool.getButton(CGRect(x: kScreenWidth/2+14 , y: 12, width: 130, height: 40), textForNormal: "退款/售后", fontSize: 16, backgroundColor: UIColor.whiteColor(), blockForCli: { (sender) -> Void in
                let vc = AfterSalesHomeViewController()
                self.navigationController?.pushViewController(vc, animated: true)
            })
            ZMDTool.configViewLayerFrameWithColor(fefundBtn, color: defaultTextColor)
            ZMDTool.configViewLayer(fefundBtn)
            fefundBtn.setImage(UIImage(named: "pay_shouhou"), forState: .Normal)
            cell?.contentView.addSubview(fefundBtn)
            return cell!
        case .Total :
            //实付cell
            let cellId = "TotalCell"
            var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
            if cell == nil {
                cell = UITableViewCell(style: .Subtitle, reuseIdentifier: cellId)
                cell?.accessoryType = UITableViewCellAccessoryType.None
                cell!.selectionStyle = .None
                ZMDTool.configTableViewCellDefault(cell!)
                
                var tag = 10001
                let leftLbl = ZMDTool.getLabel(CGRect(x: 12, y: 16, width: 100, height: 17), text: "共*件商品", fontSize: 17)
                leftLbl.tag = tag++
                cell?.contentView.addSubview(leftLbl)
                let payLbl = ZMDTool.getLabel(CGRect(x: kScreenWidth - 12 - 200, y: 20, width: 200, height: 17), text: "实付：*.**", fontSize: 17)
                payLbl.textAlignment = .Right
                payLbl.tag = tag++
                cell?.contentView.addSubview(payLbl)
                let monnyLbl = ZMDTool.getLabel(CGRect(x: 12, y: 20 + 17 + 10, width: kScreenWidth - 24, height: 15), text: "(含运费*.**)", fontSize: 15,textColor: defaultDetailTextColor)
                monnyLbl.textAlignment = .Right
                monnyLbl.tag = tag++
                cell?.contentView.addSubview(monnyLbl)
            }
            var tag = 10001
            let leftLbl = cell?.viewWithTag(tag++) as! UILabel
            let payLbl = cell?.viewWithTag(tag++) as! UILabel
            let monnyLbl = cell?.viewWithTag(tag++) as! UILabel
            
            var count = 0
            for item in self.products {
                let item = item as! ZMDProductForOrderDetail
                count += item.Quantity.integerValue
            }
            leftLbl.text = "共\(count)件商品"
            if let total = self.dic?["OrderTotal"] as? String {
                payLbl.text = "实付：\(total)"
                payLbl.attributedText = payLbl.text?.AttributedText("\(total)", color: UIColor.redColor())
            }
            if let shipping = self.dic?["OrderShipping"] as? String {
                monnyLbl.text = "(含运费\(shipping))"
            }
            return cell!
        default :
            //支付方式、备注、发票、优惠、积分
            let cellId = "OtherCell"
            var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
            if cell == nil {
                cell = UITableViewCell(style: .Default, reuseIdentifier: cellId)
                cell?.accessoryType = UITableViewCellAccessoryType.None
                cell!.selectionStyle = .None
                ZMDTool.configTableViewCellDefault(cell!)
                
                cell?.contentView.addSubview(ZMDTool.getLine(CGRect(x: 0, y: 55.5, width: kScreenWidth, height: 0.5)))
                let lbl = UILabel(frame: CGRectMake(kScreenWidth - 100 - 38, 0,100, 56))
                lbl.tag = 10001
                lbl.font = UIFont.systemFontOfSize(17)
                lbl.textAlignment = NSTextAlignment.Right
                lbl.textColor = defaultDetailTextColor
                cell!.contentView.addSubview(lbl)
            }
            cell!.textLabel?.text = cellType.title
            let lbl = cell?.viewWithTag(10001) as! UILabel
            if cellType == .Pay {
                if let paymentMethod = self.dic?["PaymentMethod"] as? String {
                    lbl.text = paymentMethod
                }
            } /*else if cellType == .Mark {
                if let mark = self.dic["Mark"] as? String{
                    lbl.text = mark
                }
            } else if cellType == .Invoice {
                if let invoice = self.dic["Invoice"] as? String {
                    lbl.text = invoice
                }
            }else if cellType == .Discount {
                if let discount = self.dic["Discount"] as? String {
                    lbl.text = discount
                }
            }else if cellType == .Jifeng {
                if let jiFeng = self.dic["JiFeng"] as? String {
                    lbl.text = jiFeng
                }
            }*/

            return cell!
        }
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if self.userCenterData[indexPath.section][0] == .Goods {
            let item = self.products[indexPath.row] as! ZMDProductForOrderDetail
            let vc = HomeBuyGoodsDetailViewController.CreateFromMainStoryboard() as! HomeBuyGoodsDetailViewController
            vc.productId = item.ProductId.integerValue
            self.pushToViewController(vc, animated: true, hideBottom: true)
            return
        }
        let cellType = self.userCenterData[indexPath.section][indexPath.row]
        switch cellType{
        case .LogisticsMsg:
             let vc = OrderLogisticsMsgViewController()
             vc.orderId = self.orderId
            self.navigationController?.pushViewController(vc, animated: true)
        default:
            break
        }
    }
    //MARK:Private Method
    func fetchData() {
        QNNetworkTool.orderDetail(self.orderId) { (succeed, dictionary, error) -> Void in
            if succeed!  {
                if let dicForAddress = dictionary!["ShippingAddress"] as? NSDictionary,address = ZMDAddress.mj_objectWithKeyValues(dicForAddress) {
                    self.address = address
                }
                if let items = dictionary!["Items"] as? NSArray,products = ZMDProductForOrderDetail.mj_objectArrayWithKeyValuesArray(items) {
                    self.products.addObjectsFromArray(products as [AnyObject])
                }
                if let notes = dictionary!["OrderNotes"] as? NSArray,orderNotes = ZMDOrderNote.mj_objectArrayWithKeyValuesArray(notes) {
                    self.orderNotes.addObjectsFromArray(orderNotes as [AnyObject])
                    if self.orderNotes.count != 0 {
                        self.userCenterData = [[.OrderNum,.LogisticsMsg,.AcceptMsg], [.Goods],[.Pay,.Mark/*,.Invoice*/],[.Total]]
                    }
                }
                self.dic = dictionary
                self.currentTableView.reloadData()
                self.updateFoot()
            }
        }
    }
    
    /**订单详情页获取订单状态*/
    func orderStatu(dictionary:NSDictionary) -> String {
        if let OrderStatus = dictionary["OrderStatus"] as? String,OrderStatusId = dictionary["OrderStatusId"] as? NSNumber,PaymentStatusId = dictionary["PaymentStatusId"] as? NSNumber,ShippingStatusId = dictionary["ShippingStatusId"] as? NSNumber,PaymentMethod = dictionary["PaymentMethod"] as? String {
            if OrderStatus == "已取消" || OrderStatus == "已完成" {
                return OrderStatus
            }
            if OrderStatusId == 10 && PaymentMethod == "货到付款" {
                return "处理中"
            }
            if PaymentStatusId == 10 {
                return PaymentMethod == "货到付款" ? "待发货" : "待付款"
            }
            return ShippingStatusId == 20 ? "待发货" : "待收货"
        }
        return ""
    }

    
    func updateUI() {
        self.currentTableView.backgroundColor = tableViewdefaultBackgroundColor
        self.currentTableView.showsHorizontalScrollIndicator = false
        self.currentTableView.showsVerticalScrollIndicator = false
        self.currentTableView.frame = self.view.bounds
    }
    func updateFoot() {
        let view = UIView(frame: CGRect(x: 0, y: kScreenHeight - 64 - 58, width: kScreenWidth, height: 58))
        view.backgroundColor = RGB(247,247,247,1.0)
        
        guard let orderStatusId = self.dic["OrderStatusId"] as? Int else {
            return
        }
        let shippingStatusId = self.dic["ShippingStatusId"] as? Int
        let paymentStatusId = self.dic["PaymentStatusId"] as? Int
        let orderStatu = OrderStatu(OrderStatusId: orderStatusId, ShippingStatusId: shippingStatusId, PaymentStatusId: paymentStatusId)
        let payMethod = self.dic["PaymentMethod"] as? String
        
        if orderStatu != .UnPay || (orderStatu == .UnPay && payMethod == "货到付款") {
            view.hidden = true
            self.currentTableView.snp_makeConstraints(closure: { (make) -> Void in
                make.bottom.equalTo(0)
            })
        }
        
        let confirmBtn = ZMDTool.getButton(CGRect(x: kScreenWidth - 12 - 90, y: 12, width: 90, height: 34), textForNormal: "", fontSize: 15,textColorForNormal:RGB(235,61,61,1.0), backgroundColor: UIColor.whiteColor()) { (sender) -> Void in
            //点击Footer上的付款
            if orderStatu == .Canceled {
                //如果订单已经取消
                ZMDTool.showPromptView("订单已取消,无法付款")
            } else if orderStatu == .UnShipping || orderStatu == .WaitShipping {
                ZMDTool.showPromptView("订单已付款,无需重新付款")
            } else if orderStatu == .WaitShipping {
                //确认收货
                QNNetworkTool.completeOrder(self.orderId, completion: { (succeed, dictionary, error) -> Void in
                    if succeed == true {
                        ZMDTool.showPromptView("确认收货成功!")
                    }else{
                        ZMDTool.showErrorPromptView(dictionary, error: error)
                    }
                })
            } else if orderStatu == .UnComment {
                //评价
                let vc = OrderGoodsScoreViewController()
                self.pushToViewController(vc, animated: true, hideBottom: true)
            } else if orderStatu == .Completed {
                
            } else {
                if payMethod == "货到付款" {
                    //货到付款订单为未支付状态,此时点击付款提示
                    ZMDTool.showPromptView("收到货物后付款即可!")
                    return
                }
                QNNetworkTool.fetchRePaymentMethod(self.orderId, completion: { (paymentMethods, dictionary, error) -> Void in
                    if paymentMethods != nil {
                        let vc = CashierViewController()
                        vc.orderId = self.orderId
                        vc.total = self.dic.valueForKey("OrderTotal") as! String
                        vc.payMethods = NSMutableArray(array: paymentMethods)
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                })
            }
        }
        ZMDTool.configViewLayerFrameWithColor(confirmBtn, color: RGB(235,61,61,1.0))
        ZMDTool.configViewLayer(confirmBtn)
        view.addSubview(confirmBtn)
        //        let checkBtn = ZMDTool.getButton(CGRect(x: kScreenWidth - 12 - 90 - 10 - 90, y: 12, width: 90, height: 34), textForNormal: "查看物流", fontSize: 15,backgroundColor: UIColor.whiteColor()) { (sender) -> Void in
        //
        //        }
        //        ZMDTool.configViewLayerFrameWithColor(checkBtn, color: defaultTextColor)
        //        ZMDTool.configViewLayer(checkBtn)
        //        view.addSubview(checkBtn)
        self.view.addSubview(view)
        var titles = ""

        switch orderStatu {
        case .UnPay :
            titles = "去付款"
            break
        case .UnShipping :
            titles = "去付款"
            break
        case .WaitShipping :
            titles = "确认收货"
            break
        case .UnComment :
            titles = "立即评价"
            break
        case .Canceled :
            titles = "去付款"
            break
        case .Completed :
            titles = "已完成"
            break
        default:
            break
        }
        confirmBtn.setTitle(titles, forState: .Normal)
    }
    private func dataInit(){
        self.userCenterData = [[.OrderNum,/*.LogisticsMsg,*/.AcceptMsg], [.Goods],[.Pay,.Mark,.Invoice],[.Total]]
        self.fetchData()
    }
    
    //MARK:提交订单提交成功后直接完成支付
    func respondForPostOrder(succeed : Bool!,dictionary:NSDictionary?,error: NSError?) {
        ZMDTool.hiddenActivityView()
        if succeed! {
            if let payString = dictionary?["PayString"] as? String {
                self.submitAliOrder(payString)
            } else {
                let vc = OrderPaySucceedViewController()
                vc.finished = {()->Void in
                    let vcs = self.navigationController!.viewControllers
                    let vc = vcs[vcs.count - 1 - 3]
                    self.navigationController?.popToViewController(vc, animated: true)
                }
                self.navigationController?.pushViewController(vc, animated: true)
            }
        } else {
            ZMDTool.showErrorPromptView(nil, error: error)
        }
    }
    
    private func submitAliOrder(orderString: String){
        //应用注册scheme,在AlixPayDemo-Info.plist定义URL types
        let appScheme: String = "alisdkforHLB"
        let orderString = "_input_charset=\"utf-8\"&body=\"支付葫芦堡订单：0615100039\"&notify_url=\"http://localhost:2726/Plugins/AliPay/AppNotify\"&out_trade_no=\"39\"&partner=\"2088411055133951\"&payment_type=\"1\"&seller_id=\"2088411055133951\"&service=\"mobile.securitypay.pay\"&subject=\"葫芦堡订单：0615100039\"&total_fee=\"0.01\"&sign=\"RNoYCPH%2fSpp%2fxWQnmhd8kkKmobosYtzzwuYyn3jJQJHZg8GN4qKmghfdMM38roe014WjSuKimF7%2fwUukQgq%2b2vsMrTw0HrkH%2b2V6ksM%2bz5KzZBzToOzv%2fL79DdfKVt4327s89%2fMM8ypbD9t6dcFYDn6o1floUJMFo6RStPp6rdQ%3d\"&sign_type=\"RSA\""
        //dic["payInfo"] as! String
        
        AlipaySDK.defaultService().payOrder(orderString, fromScheme: appScheme, callback: { (resultDic) -> Void in
            if let Alipayjson = resultDic as? NSDictionary {
                let resultStatus = Alipayjson.valueForKey("resultStatus") as! String
                if resultStatus == "9000"{
                    let vc = OrderPaySucceedViewController()
                    self.navigationController?.pushViewController(vc, animated: true)
                    //                    ZMDTool.showPromptView( "支付成功")
                }else if resultStatus == "8000" {
                    ZMDTool.showPromptView( "正在处理中")
                }else if resultStatus == "4000" {
                    ZMDTool.showPromptView( "订单支付失败")
                }else if resultStatus == "6001" {
                    ZMDTool.showPromptView( "用户中途取消")
                }else if resultStatus == "6002" {
                    ZMDTool.showPromptView( "网络连接出错")
                }
            }
        })
    }
}
