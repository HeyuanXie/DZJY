//
//  ConfirmOrderViewController.swift
//  ZhiMaDi
//
//  Created by haijie on 16/3/30.
//  Copyright © 2016年 ZhiMaDi. All rights reserved.
//

import UIKit
// 确认订单
class ConfirmOrderViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,ZMDInterceptorProtocol {
    
    enum UserCenterCellType{
        case AddressSelect
        
        case Store
        case Goods
        case Discount
        case freight
        case Mark
        case GoodsCount
        
        case Invoice
        case InvoiceType
        case InvoiceDetail
        case InvoiceFor
        
        case UseDiscount
        init(){
            self = AddressSelect
        }
        
        var title : String{
            switch self{
            case Discount:
                return "店铺优惠:"
            case freight:
                return "运费:"
            case Mark:
                return "备注:"
            case GoodsCount:
                return "共一件商品"

            case Invoice:
                return "是否开具发票"
            case InvoiceType:
                return "发票类型:"
            case InvoiceDetail:
                return "发票明细:"
            case InvoiceFor:
                return "发票抬头:"
                
            case UseDiscount:
                return "使用优惠券"
            default :
                return ""
            }
        }
        //
        //        var pushViewController :UIViewController{
        //            let viewController: UIViewController
        //            switch self{
        //            case UserMyOrder:
        //                viewController = MyOrderViewController.CreateFromMainStoryboard() as! MyOrderViewController
        //            case UserMyOrderMenu:
        //                viewController = UIViewController()
        //            case UserWallet:
        //                viewController = UIViewController()
        //            case UserBankCard:
        //                viewController = UIViewController()
        //            case UserCardVolume:
        //                viewController = UIViewController()
        //            case UserMyCrowdFunding:
        //                viewController = UIViewController()
        //
        //            case UserMyStore:
        //                viewController = UIViewController()
        //            case UserVipClub:
        //                viewController = UIViewController()
        //            case UserCommission:
        //                viewController = UIViewController()
        //            case UserInvitation:
        //                viewController = UIViewController()
        //
        //            case UserHelp:
        //                viewController = UIViewController()
        //            default :
        //                viewController = UIViewController()
        //            }
        //            viewController.hidesBottomBarWhenPushed = true
        //            return viewController
        //        }
        //
        //        func didSelect(navViewController:UINavigationController){
        //            navViewController.pushViewController(pushViewController, animated: true)
        //        }
    }
    
    @IBOutlet weak var currentTableView: UITableView!
    var markTF : UITextField!           //单店支付时传递的单个备注textField
    var markArray : NSMutableArray!       //多店支付时传递的所有备注textField的数组
    var payLbl : UILabel!       //实付lbl
    var shippingLbl : UILabel!  //运费lbl
    var totalLbl : UILabel!
    var userCenterData: [[UserCenterCellType]]!
    var tableCellType:[UserCenterCellType]!
    var scis : NSArray!                //从购物车页面传递过来商品的一维数组
    var storeArray : NSMutableArray!  //将选中商品按店铺分组得到的二维数组
    var singleTotalArray : NSMutableArray!      //存放每一个店铺内的orderTotal（ZMDSingleStoreTotal）
    var publicInfo : NSMutableDictionary?
    var total = ""                  //单店时的total
    
    var person = ""
    var phoneNumber = ""
    var address1 = ""
    var address2 = ""
    
    var shipping = 0.00    //运费
    var totalDouble :Double = 0.00  //多店时计算的总的total
    var didChoseAddress = false
    
    var personalInvoice = ""        //个人发票抬头
    override func viewDidLoad() {
        super.viewDidLoad()
        self.markArray = NSMutableArray()
        
        self.getTheStoreArray()
        //设置默认地址
        self.setDefaultAddress()
        self.updateUI()
        self.getSingleTotalWithUrl()
        self.dataInit()
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

        if section == 0 {
            return 1
        }else{
            return 5 + self.storeArray[section - 1].count
        }
    }
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {

        return self.storeArray.count + 1
    }
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return  16
    }
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.row > 0 && indexPath.row <= self.storeArray[indexPath.section - 1].count {
            return 110
        }else{
            return 56
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cellId = "AddressSelectCell"
            var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
            if cell == nil {
                cell = UITableViewCell(style: .Default, reuseIdentifier: cellId)
                cell?.accessoryType = .DisclosureIndicator
                cell?.selectionStyle = .None
                ZMDTool.configTableViewCellDefault(cell!)
                cell?.imageView?.image = UIImage(named: "pay_select_adress")
                let addressLbl = ZMDTool.getLabel(CGRect(x: 44, y: 0, width: kScreenWidth-45-30, height: 55), text: "选择收货地址", fontSize: 17)
                addressLbl.numberOfLines = 0
                addressLbl.tag = 1000
                cell?.contentView.addSubview(addressLbl)
            }
            return cell!
        } else {
            if indexPath.row == 0 {
                //店家
                let cellId = "StoreCell"
                let cell = tableView.dequeueReusableCellWithIdentifier(cellId)
                let line = ZMDTool.getLine(CGRect(x: 0, y: 47.5, width: kScreenWidth, height: 0.5))
                cell?.contentView.addSubview(line)
                let store = (self.storeArray[indexPath.section-1][0] as! ZMDShoppingItem).Store
                (cell?.viewWithTag(1000) as! UILabel).text = store.Name
                return cell!
            }else if indexPath.row > 0 && indexPath.row <= self.storeArray[indexPath.section - 1].count {
                //商品cell
                let cellId = "GoodsCell"
                let cell = tableView.dequeueReusableCellWithIdentifier(cellId) as! OrderGoodsTableViewCell
                let item = self.storeArray[indexPath.section-1][indexPath.row-1] as! ZMDShoppingItem
                cell.configCellForConfig(item)
                return cell
            }else if indexPath.row == self.storeArray[indexPath.section - 1].count + 100 {
                //使用优惠券
                let cellId = "UseDiscountCell"
                var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
                if cell == nil {
                    cell = UITableViewCell(style: .Default, reuseIdentifier: cellId)
                    cell?.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
                    cell!.selectionStyle = .None
                    ZMDTool.configTableViewCellDefault(cell!)
        
                    let label = ZMDTool.getLabel(CGRect(x: kScreenWidth - 32 - 150, y: 0, width: 150, height: 55.5), text: "可使用优惠券：0张", fontSize: 17,textColor: defaultDetailTextColor)
                    cell?.contentView.addSubview(label)
                    cell?.contentView.addSubview(ZMDTool.getLine(CGRect(x: 0, y: 55.5, width: kScreenWidth, height: 0.5)))
                }
                cell!.textLabel?.text = "使用优惠券"
                return cell!
            }else if indexPath.row == self.storeArray[indexPath.section - 1].count + 1 {
                //运费
                let cellId = "freightCell"
                var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
                if cell == nil {
                    cell = UITableViewCell(style: .Default, reuseIdentifier: cellId)
                    cell?.selectionStyle = .None
                    ZMDTool.configTableViewCellDefault(cell!)
                    
                    cell?.textLabel?.text = "运费:"
                    let label = ZMDTool.getLabel(CGRect(x: kScreenWidth-12-80, y: 0, width: 80, height: 55.5), text: "", fontSize: 17)
                    label.tag = 10000
                    label.textAlignment = .Right
                    label.textColor = defaultTextColor
                    cell?.contentView.addSubview(ZMDTool.getLine(CGRect(x: 0, y: 55.5, width: kScreenWidth, height: 0.5)))
                    cell?.contentView.addSubview(label)
                }
                //运费
                (cell?.contentView.viewWithTag(10000) as! UILabel).text = self.singleTotalArray.count == 0 ? "" : (self.singleTotalArray[indexPath.section-1] as!ZMDSingleStoreTotal).Shipping
                return cell!
            }else if indexPath.row == self.storeArray[indexPath.section - 1].count + 2 {
                //是否开发票
                let cellId = "InvoiceCell\(indexPath.section)"
                var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
                if cell == nil {
                    cell = UITableViewCell(style: .Default, reuseIdentifier: cellId)
                    cell?.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
                    cell!.selectionStyle = .None
                    ZMDTool.configTableViewCellDefault(cell!)
                    cell?.contentView.addSubview(ZMDTool.getLine(CGRect(x: 0, y: 55.5, width: kScreenWidth, height: 0.5)))
                    
                    cell!.textLabel?.text = "是否开发票"
                    let label = ZMDTool.getLabel(CGRect(x:kScreenWidth - 32 - 20 - 150, y: 0, width: 150 + 20, height: 56), text: "未选择", fontSize: 15)
                    label.tag = 1000
                    label.textAlignment = .Right
                    cell?.contentView.addSubview(label)

                    label.textColor = defaultDetailTextColor
                }                
                return cell!
            }else if indexPath.row == self.storeArray[indexPath.section - 1].count + 3 {
                //备注
                let cellId = "MarkCell\(indexPath.section)"
                var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
                if cell == nil {
                    cell = UITableViewCell(style: .Subtitle, reuseIdentifier: cellId)
                    cell?.accessoryType = UITableViewCellAccessoryType.None
                    cell!.selectionStyle = .None
                    ZMDTool.configTableViewCellDefault(cell!)
                    
                    let textField = UITextField(frame: CGRect(x: 64, y: 0, width: kScreenWidth - 64 - 12, height: 55))
                    textField.textColor = defaultDetailTextColor
                    textField.font = defaultSysFontWithSize(17)
                    textField.tag = 10001
                    textField.placeholder = "给商家留言"
                    cell?.contentView.addSubview(textField)
                    //把所有备注的textField加入到全局数组中,方便后面提交订单的时候全部拿到
                    self.markArray.addObject(textField)
                    cell?.contentView.addSubview(ZMDTool.getLine(CGRect(x: 0, y: 55.5, width: kScreenWidth, height: 0.5)))
                    cell!.textLabel?.text = "备注"
                }
                return cell!
            }else if indexPath.row == self.storeArray[indexPath.section - 1].count + 4 {
                //合计
                let cellId = "GoodsCountCell\(indexPath.section)"
                var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
                if cell == nil {
                    cell = UITableViewCell(style: .Default, reuseIdentifier: cellId)
                    cell?.accessoryType = UITableViewCellAccessoryType.None
                    cell!.selectionStyle = .None
                    ZMDTool.configTableViewCellDefault(cell!)
                    
                    let label = ZMDTool.getLabel(CGRect(x: kScreenWidth - 12 - 150, y: 0, width: 150, height: 55.5), text: "", fontSize: 17)
                    label.textAlignment = .Right
                    self.totalLbl = label
                    self.totalLbl.tag = 10000
                    cell?.contentView.addSubview(self.totalLbl)
                    cell?.contentView.addSubview(ZMDTool.getLine(CGRect(x: 0, y: 55.5, width: kScreenWidth, height: 0.5)))
                }
                
                //单店合计有数据用下面
                //利用orderTotal
//                if self.singleTotalArray.count != 0 {
//                    self.totalLbl.attributedText = "合计 : \((self.singleTotalArray[indexPath.section-1] as! ZMDSingleStoreTotal).SubTotal)".AttributedText("\((self.singleTotalArray[indexPath.section-1] as! ZMDSingleStoreTotal).SubTotal)", color: RGB(235,61,61,1.0))
//                }
                //计算商品件数
                var count = 0,money = 0.00
                let arr = self.storeArray[indexPath.section-1] as! NSMutableArray
                for item in arr {
                    let item = item as! ZMDShoppingItem
                    count += item.Quantity.integerValue
                    let str = item.UnitPrice.componentsSeparatedByString("¥").last
                    let price = (str!.stringByReplacingOccurrencesOfString(",", withString: "") as NSString).doubleValue
                    money += price*(item.Quantity.doubleValue)
                }
                cell?.textLabel?.text = "共\(count)件商品"
                (cell?.contentView.viewWithTag(10000) as! UILabel).attributedText = "合计 : ¥\(money)".AttributedText("¥\(money)", color: RGB(235,61,61,1.0))
                return cell!
            }
        }
        return UITableViewCell(style: .Default, reuseIdentifier: "cell")
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 {
            //收货地址
            let vc = AddressViewController.CreateFromMainStoryboard() as! AddressViewController
            vc.finished = { (address:ZMDAddress) -> Void in
                ZMDTool.showActivityView(nil)
                QNNetworkTool.selectShoppingAddress((address.Id?.integerValue)!) { (succeed, dictionary, error) -> Void in
                    ZMDTool.hiddenActivityView()
                    if succeed! {
                        ZMDTool.showPromptView("选择地址成功")
                        //选择地址成功后，回来时将选择的地址显示出来
                        (tableView.cellForRowAtIndexPath(indexPath)?.viewWithTag(1000) as!UILabel).text = "收件人: \(address.FirstName )" + "   Tel:\(address.PhoneNumber)" + "\n" + "收件地址:" + address.Address1! + address.Address2!
                        (tableView.cellForRowAtIndexPath(indexPath)?.viewWithTag(1000) as!UILabel).font = UIFont.systemFontOfSize(13)
                        self.didChoseAddress = true
                        self.getSingleTotalWithUrl()
                        //记录收件人、电话、地址，传递给付款成功页面
                        self.person = address.FirstName
                        self.phoneNumber = address.PhoneNumber
                        self.address1 = address.Address1!
                        self.address2 = address.Address2!
                    } else {
                        if let message = dictionary?["message"] as? String {
                            ZMDTool.showErrorPromptView(dictionary, error: error, errorMsg: message)
                        }
                        (tableView.cellForRowAtIndexPath(indexPath)?.viewWithTag(1000) as!UILabel).text = "选择收货地址"
                        (tableView.cellForRowAtIndexPath(indexPath)?.viewWithTag(1000) as!UILabel).font = UIFont.systemFontOfSize(17)
                        self.didChoseAddress = false
                    }
                }
            }
            self.navigationController?.pushViewController(vc, animated: true)
        }else{
            if indexPath.row > 0 && indexPath.row <= self.storeArray[indexPath.section - 1].count {
                //商品cell
                let item = self.storeArray[indexPath.section-1][indexPath.row-1] as! ZMDShoppingItem
                let vc = HomeBuyGoodsDetailViewController.CreateFromMainStoryboard() as! HomeBuyGoodsDetailViewController
                vc.productId = item.ProductId.integerValue
                self.pushToViewController(vc, animated: true, hideBottom: true)
                print("点击商品Cell")
            }else{
                switch indexPath.row {
                case 0 ://商家
                    let vc = StoreShowHomeViewController.CreateFromMainStoryboard() as! StoreShowHomeViewController
                    vc.storeId = (self.storeArray[indexPath.section-1][0] as!ZMDShoppingItem).Store.Id
                    vc.hidesBottomBarWhenPushed = true
                    self.navigationController?.pushViewController(vc, animated: true)
                    break
                case self.storeArray[indexPath.section-1].count + 100 : //使用优惠券
                    let vc = DiscountCardViewController()
                    vc.finished = {(couponcode)->Void in
                        QNNetworkTool.useDiscountCoupo(couponcode, completion: { (succeed, dictionary, error) -> Void in
                            if !succeed! {
                                ZMDTool.showErrorPromptView(nil, error: error, errorMsg: nil)
                            } else {
                                self.getSingleTotalWithUrl()    //使用优惠券后重新获取total
                            }
                        })
                    }
                    self.navigationController?.pushViewController(vc, animated: true)
                    break
                case self.storeArray[indexPath.section-1].count + 2: //是否开发票
                    let cell = tableView.cellForRowAtIndexPath(indexPath)
                    let vc = InvoiceTypeViewController()
                    if self.publicInfo != nil {
                        vc.invoiceFinish = self.publicInfo
                    }
                    vc.finished = {(dic)->Void in
                        self.publicInfo = NSMutableDictionary(dictionary: dic!)
                        if dic!["Category"] as! String == "个人" {
                            self.publicInfo?.setValue(self.personalInvoice, forKey: "HeadTitle")
                        }
                        
                        if let type = dic?["Type"],body = dic?["Body"],headTitle = dic?["HeadTitle"],singleOrCompany = dic?["singleOrCompany"] {
                            if type as! String == "不开发票" {
                                (cell?.viewWithTag(1000) as! UILabel).text = "不开发票"
                            }else{
                                (cell?.viewWithTag(1000) as! UILabel).text = "\(type) \(singleOrCompany) \(body)"
                            }
                        }
                    }
                    self.navigationController?.pushViewController(vc, animated: true)
                    break
                case 5 : //self.dataArr[indexPath].someArr.count + 4    备注
                    break
                default :
                    break
                }
            }
        }
    }
    
    private func setDefaultAddress() {
        QNNetworkTool.fetchAddresses { (addresses, error, dictionary) in
            if let addresses = addresses {
                var index = 0
                for ;index<addresses.count;index++ {
                    let address = addresses[index] as! ZMDAddress
                    if address.IsDefault == true {
                        self.choseDefaultAddress(address)
                        break
                    }
                }
            }
        }
    }
    
    func choseDefaultAddress(address:ZMDAddress) {
        QNNetworkTool.selectShoppingAddress(address.Id.integerValue) { (succeed, dictionary, error) in
            if succeed! {
                //选择默认地址成功，设置addressCell
                let cell = self.currentTableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0))
                (cell?.viewWithTag(1000) as!UILabel).text = "收件人: \(address.FirstName )" + "   Tel:\(address.PhoneNumber)" + "\n" + "收件地址:" + address.Address1! + address.Address2!
                (cell?.viewWithTag(1000) as!UILabel).font = UIFont.systemFontOfSize(13)
                
                //选择默认地址成功,记录收件人、电话、地址，传递给付款成功页面
                self.person = address.FirstName
                self.phoneNumber = address.PhoneNumber
                self.address1 = address.Address1!
                self.address2 = address.Address2!

                self.didChoseAddress = true
                self.getSingleTotalWithUrl()
            }
        }
    }

    //MARK:Private Method
    func updateUI() {
        self.currentTableView.backgroundColor = tableViewdefaultBackgroundColor
        
        let view = UIView(frame: CGRect(x: 0, y: kScreenHeight - 64 - 58, width: kScreenWidth, height: 58))
        view.backgroundColor = UIColor.whiteColor()
        self.view.addSubview(view)
        view.addSubview(ZMDTool.getLine(CGRect(x: 0, y: 0, width: kScreenWidth, height: 0.5), backgroundColor: defaultLineColor))
        let size = "提交订单".sizeWithFont(UIFont.systemFontOfSize(15), maxWidth: 200)
        let confirmBtn = ZMDTool.getButton(CGRect(x: kScreenWidth - 12 - size.width - 20, y: 12, width: size.width+20, height: 34), textForNormal: "提交订单", fontSize: 15,textColorForNormal:UIColor.whiteColor(), backgroundColor:RGB(235,61,61,1.0)) { (sender) -> Void in
            self.view.endEditing(true)
            //判断是否选择地址
            guard self.didChoseAddress else {
                ZMDTool.showPromptView("请选择收货地址")
                return
            }
            //提交订单时只是获取支付方式，跳转到收银台页面支付时才confirm订单
            self.fetchPayMethods()
        }
        
        ZMDTool.configViewLayerWithSize(confirmBtn, size: 15)
        view.addSubview(confirmBtn)
        
        self.payLbl = ZMDTool.getLabel(CGRect(x: 12, y: 12, width: 200, height: 15), text: "实付: ¥ \(self.total)", fontSize: 16,textColor: defaultTextColor)
        self.payLbl.attributedText = self.payLbl.text?.AttributedText("¥ \(self.total)", color: defaultSelectColor)
        view.addSubview(self.payLbl)
        
        self.shippingLbl = ZMDTool.getLabel(CGRect(x: 12, y: 12+15+7, width: 200, height: 12), text: "", fontSize: 16)
        self.shippingLbl.textColor = defaultTextColor
//        view.addSubview(self.shippingLbl)
        
        let jifengLbl = ZMDTool.getLabel(CGRect(x: 12, y: 12 + 15 + 7, width: 200, height: 12), text: "可获得20积分", fontSize: 12,textColor: defaultDetailTextColor)
        jifengLbl.text = "积分功能暂未开放"
        view.addSubview(jifengLbl)
    }
    private func dataInit(){
        self.userCenterData = [[.AddressSelect],[.Goods],[.GoodsCount,.Mark], [.Invoice,.InvoiceType,.InvoiceDetail,.InvoiceFor],[.UseDiscount]]
    }
    
    //MARK:- getTheStoreArray,把商品按店铺分组
    func getTheStoreArray() {
        let storeArray = NSMutableArray()
        for(var i=0;i<self.scis.count;i++){
            let item = self.scis[i] as! ZMDShoppingItem
            item.Store.Id = i%2
            var j = 0
            for (;j<storeArray.count;j++){
                let arr = storeArray[j] as! NSMutableArray
                if item.Store.Id == (arr.firstObject as! ZMDShoppingItem).Store.Id {
                    arr.addObject(item)
                    break
                }
            }
            if j == storeArray.count {
                let arr = NSMutableArray(array: [item])
                storeArray.addObject(arr)
            }
        }
        self.storeArray = NSMutableArray(array: storeArray as [AnyObject])
        self.currentTableView.reloadData()
    }
    
    //MARK: -getSingleTotal,计算出每个店铺内商品小计和运费，存入数组中
    func getSingleTotalWithUrl() {
        ZMDTool.showActivityView(nil)
        self.singleTotalArray = NSMutableArray()
        self.totalDouble = 0.00
        self.shipping = 0.00
        self.singleTotalArray.removeAllObjects()
        for var i = 0;i<self.storeArray.count;i++ {
            let arr = self.storeArray[i] as! NSMutableArray //每一个店铺的数组
            if arr.count != 0 {
                let store = (arr.firstObject as! ZMDShoppingItem).Store
                let storeId = store.Id.integerValue
                QNNetworkTool.singleStoreTotal(g_customerId,storeId: storeId, Completion: { (total, error, dictionary) -> Void in
                    ZMDTool.hiddenActivityView()
                    if total != nil {
                        self.singleTotalArray.addObject(total!)
                    
                        //单店订单合计有数据后用来计算总金额(含所有运费)和总运费
                        let str = total?.OrderTotal?.stringByReplacingOccurrencesOfString("¥", withString: "") ?? ""
                        let str1 = str.stringByReplacingOccurrencesOfString(",", withString: "")
                        self.totalDouble += (str1 as NSString).doubleValue
                        self.shipping += ((total?.Shipping?.stringByReplacingOccurrencesOfString("¥", withString: "")) ?? "" as NSString).doubleValue
                        //更新总合计
                        if i == self.storeArray.count {
                            self.payLbl.attributedText = "实付: ¥ \(self.totalDouble)".AttributedMutableText(["实付","¥ \(self.totalDouble)"], colors: [defaultTextColor,defaultSelectColor])
                            self.payLbl.attributedText = "实付: ¥ \(self.totalDouble) (含运费:¥\(self.shipping))".AttributeText(["¥ \(self.totalDouble)","¥\(self.shipping)","(含运费:",")"], colors: [defaultSelectColor,defaultSelectColor,defaultTextColor,defaultTextColor], textSizes: [16,15,15,15])
                            self.shippingLbl.attributedText = "含运费: ¥ \(self.shipping)".AttributedText("¥ \(self.shipping)", color: defaultSelectColor)
                            self.currentTableView.reloadData()
                        }
                    }
                })
                if self.didChoseAddress == true {
                    self.userCenterData = [[.AddressSelect],[.Goods],[.GoodsCount,.freight,.Mark], [.Invoice,.InvoiceType,.InvoiceDetail,.InvoiceFor],[.UseDiscount]]
                }
                self.currentTableView.reloadData()
            }
        }
    }
    
    
    
    func fetchPayMethods() {
        ZMDTool.showActivityView(nil)
        
        //遍历self.markArray取到所有店铺的备注信息加入字典
        let marks = NSMutableDictionary()
        for var i=0;i<self.markArray.count;i++ {
            let text:String = (self.markArray[i] as! UITextField).text!
            let store = (self.storeArray[i].firstObject as! ZMDShoppingItem).Store
            marks.setValue(text, forKey: "customercommenthidden_"+"\(store.Id.integerValue)")
        }
        marks.setValue(g_customerId!, forKey: "customerId")
        
        QNNetworkTool.fetchPaymentMethod { (paymentMethods, dictionary, error) -> Void in
        ZMDTool.hiddenActivityView()
        if paymentMethods != nil {
            var mark = ""
            if self.markTF != nil {
                mark = self.markTF!.text!
            }
            let vc = CashierViewController()
            vc.mark = mark
            
            vc.marks = marks
            vc.total = "\(self.totalDouble)"
            vc.person = self.person
            vc.phoneNumber = self.phoneNumber
            vc.address1 = self.address1
            vc.address2 = self.address2
            vc.payMethods = NSMutableArray(array: paymentMethods)
            self.navigationController?.pushViewController(vc, animated: true)
        }
        }
    }
}

