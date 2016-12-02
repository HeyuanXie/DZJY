//
//  CashierViewController.swift
//  ZhiMaDi
//
//  Created by haijie on 16/3/31.
//  Copyright © 2016年 ZhiMaDi. All rights reserved.
//

import UIKit
// 收银台
class CashierViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,ZMDInterceptorProtocol {
    var tableView : UITableView!
    let datas = NSMutableArray()
//    let images = ["pay_alipay","pay_InHome"]
    let images = ["pay_InHome","pay_alipay"]
    var indexTypeRow = 0
    var finished : ((indexType:Int,IndexDetail:Int)->Void)!
    var mark = ""                       //单店支付时的备注
    var marks = NSDictionary()   //多店支付时的备注，字典
    var total = ""
    var payMethods = NSMutableArray()
    var selectPayMethod : ZMDPaymentMethod!
    var selectPayMethodName = ""
    var orderId : Int!
    
    var person = ""
    var phoneNumber = ""
    var address1 = ""
    var address2 = ""

    
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.selectPayMethod = self.payMethods[1] as! ZMDPaymentMethod
        if self.payMethods.count != 0 {
            self.selectPayMethod = self.payMethods[0] as! ZMDPaymentMethod  //默认选中第一个方法
//            self.payMethods.removeObject(self.selectPayMethod)
        }
//        let tmp = payMethods.filter(){
//            let tmp = $0 as! ZMDPaymentMethod
//            return tmp.Selected.boolValue
//        }
//        if tmp.count == 1 {
//            self.selectPayMethod = tmp[0] as! ZMDPaymentMethod
//            payMethods.removeObject(self.selectPayMethod)
//        }
        self.updateUI()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //MARK:- UITableViewDataSource,UITableViewDelegate
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return section == 0 ? 1 : self.payMethods.count
        return self.payMethods.count
    }
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
//        return self.payMethods.count == 0 ? 1 : 2
        return 1
    }
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 12 : 1
    }
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return indexPath.section == 0 ? 70 : 55
    }
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headView = UIView(frame: CGRectMake(0, 0, kScreenWidth, 12))
        headView.backgroundColor = UIColor.clearColor()
        return headView
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cellId = "cell"
        var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
        if cell == nil {
            cell = UITableViewCell(style: .Subtitle, reuseIdentifier: cellId)
            cell!.selectionStyle = .None
            
            ZMDTool.configTableViewCellDefault(cell!)
            
            let imgV = UIImageView(frame: CGRect(x: kScreenWidth - 12 - 20, y: 17, width: 20, height: 20))
            imgV.tag = 10001
            cell?.contentView.addSubview(imgV)
            cell?.addLine()
            
            let selectBtn = UIButton(frame: CGRect(x: kScreenWidth - 40, y: 8, width: 40, height: 40))
            selectBtn.selected = indexPath.section == self.indexTypeRow ? true : false
            selectBtn.setImage(UIImage(named: "common_01unselected"), forState: .Normal)
            selectBtn.setImage(UIImage(named: "common_02selected"), forState: .Selected)
            selectBtn.rac_command = RACCommand(signalBlock: { (sender) -> RACSignal! in
                (sender as!UIButton).selected = !(sender as!UIButton).selected
                self.indexTypeRow = indexPath.row
                tableView.reloadData()
                return RACSignal.empty()
            })
            selectBtn.tag = 1000
            cell?.contentView.addSubview(selectBtn)
        }
        let method = self.payMethods[indexPath.row] as! ZMDPaymentMethod
        self.setPayImage(cell!, method: method)
        cell?.textLabel?.text = method.Name
        (cell?.contentView.viewWithTag(1000) as! UIButton).selected = indexPath.row == self.indexTypeRow ? true : false
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.indexTypeRow = indexPath.section
        tableView.reloadData()
    }
    
    //MARK:设置支付方法图片
    func setPayImage(cell:UITableViewCell, method:ZMDPaymentMethod) {
        //url有效时打开
        /*if let urlStr = method.ImageUrl,url = NSURL(string: kImageAddressMain+urlStr) {
            cell.imageView?.sd_setImageWithURL(url, placeholderImage: nil)
            return
        }*/
        switch method.Name {
        case "货到付款":
            cell.imageView?.image = UIImage(named: "pay_InHome")
            return
        case "支付宝付款":
            cell.imageView?.image = UIImage(named: "pay_alipay")
            return
        case "银联支付":
            cell.imageView?.image = UIImage(named: "pay_UnionPay")
            return
        case "微信支付":
            cell.imageView?.image = UIImage(named: "pay_wechat")
            return
        default :
            return
        }
    }

    /*首次付款和重新付款返回dictionary都为[success,PayModel],payModel[PayString]存在则为支付宝*/
    func respondForPostOrder(succeed : Bool!,dictionary:NSDictionary?,error: NSError?) {
        ZMDTool.hiddenActivityView()
        if succeed! {
            //多店支付由于多个订单没有返回orderId
            //payString==nil为货到付款、否则为支付宝
            if let payModelDic = dictionary!["payModel"] {
                if let payString = payModelDic["PayString"] as? String {
                    self.submitAliOrder(payString, isPayed: true)
                }else{
                    self.submitAliOrder("", isPayed: false)
                }
            }
        }else{
            ZMDTool.showErrorPromptView(dictionary, error: error, errorMsg: dictionary!["error"] as? String)
        }
    }
    
    //MARK; - back
    override func back() {
        if self.orderId != nil {
            let vcs = self.navigationController!.viewControllers
            let vc = vcs[vcs.count - 1 - 2]
            self.navigationController?.popToViewController(vc, animated: true)
        } else {
            super.back()
        }
    }
    //MARK: -  PrivateMethod
    func updateUI() {
        self.title = "收银台"
        tableView = UITableView(frame: self.view.bounds)
        tableView.backgroundColor = tableViewdefaultBackgroundColor
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        self.view.addSubview(tableView)
        
        let footV = UIView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 36+50))
        footV.backgroundColor = UIColor.clearColor()
        let btn = ZMDTool.getButton(CGRect(x: 12, y: 36, width: kScreenWidth - 24, height: 50), textForNormal: "确认", fontSize: 20, textColorForNormal:UIColor.whiteColor(),backgroundColor: UIColor.redColor()) { (sender) -> Void in
            ZMDTool.showActivityView(nil)
            //MARK:--确认付款comfirmOrder
            self.selectPayMethod = self.payMethods[self.indexTypeRow] as! ZMDPaymentMethod
            if self.orderId != nil {
                QNNetworkTool.rePostPayment(self.orderId, Paymentmethod: self.selectPayMethod.PaymentMethodSystemName, completion: { (succeed, dictionary, error) -> Void in
                    ZMDTool.hiddenActivityView()
                    self.respondForPostOrder(succeed, dictionary: dictionary, error: error)
                })
            } else {
                //单店支付
//                QNNetworkTool.confirmOrder(self.mark, Paymentmethod: self.selectPayMethod.PaymentMethodSystemName, completion: { (succeed, dictionary, error) -> Void in
//                    //利用confirmOrder的返回值作为参数，自定义一个方法
//                    self.respondForPostOrder(succeed, dictionary: dictionary, error: error)
//                })
                
                //多店支付
                let dic = self.marks //self.marks中已经添加了"customerId":g_customerId
                QNNetworkTool.confirmOrderWithStores(dic, completion: { (succeed, dictionary, error) -> Void in
                    self.respondForPostOrder(succeed, dictionary: dictionary, error: error)
                })
            }
        }
        
        ZMDTool.configViewLayer(btn)
        footV.addSubview(btn)
        tableView.tableFooterView = footV
    }
    
    //支付宝支付
    private func submitAliOrder(orderString: String,isPayed: Bool){
        //应用注册scheme,在AlixPayDemo-Info.plist定义URL types
        let appScheme: String = "alisdkforJNNT"
        let vc = OrderPaySucceedViewController()
        vc.isPayed = isPayed
        vc.total = self.total
        vc.person = self.person
        vc.phoneNumber = self.phoneNumber
        vc.address1 = self.address1
        vc.address2 = self.address2
        
        vc.finished = {() ->Void in
            let vcs = self.navigationController!.viewControllers
            let vc = vcs[vcs.count - 1 - 3]
            //返回购物车页面
            self.navigationController?.popToViewController(vc, animated: true)
        }
        if isPayed {
            AlipaySDK.defaultService().payOrder(orderString, fromScheme: appScheme, callback: { (resultDic) -> Void in
                if let Alipayjson = resultDic as? NSDictionary {
                    let resultStatus = Alipayjson.valueForKey("resultStatus") as! String
                    if resultStatus == "9000"{
                        //支付成功跳转到支付成功页面
                        self.navigationController?.pushViewController(vc, animated: true)
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
        }else{
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }

}
