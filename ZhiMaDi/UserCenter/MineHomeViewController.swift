//
//  MineViewController.swift
//  ZhiMaDi
//
//  Created by haijie on 16/2/22.
//  Copyright © 2016年 ZhiMaDi. All rights reserved.
//

import UIKit
import ReactiveCocoa
import SDWebImage

//我的
class MineHomeViewController: UIViewController,UITableViewDataSource, UITableViewDelegate,ZMDInterceptorProtocol,ZMDInterceptorMoreProtocol {

    enum UserCenterCellType{
        case UserHead
        case UserMyOrder
        
        case UserSupply
        case UserDemand
        case UserCollect
        
        case UserSetting
        
        case UserOpenStore
        
        case UserPublishSupply
        case UserPublishDemand
        init(){
            self = UserHead
        }
        
        var title : String{
            switch self{
            case UserHead :
                return ""
            case UserMyOrder :
                return "全部订单"

            case UserSupply:
                return "我的供应"
            case UserDemand:
                return "我的求购"
            case UserCollect:
                return "我的收藏"
                
            case UserSetting:
                return "账户设置"
                
            case UserOpenStore:
                return "我要开店"
                
            case .UserPublishSupply:
                return "发布供应"
            case .UserPublishDemand:
                return "发布求购"
            }
        }
        var image : UIImage?{
            switch self{
            case .UserMyOrder:
                return UIImage(named: "全部订单")
            case UserSupply:
                return UIImage(named: "我的供应")
            case UserDemand:
                return UIImage(named: "我的求购")
            case UserCollect:
                return UIImage(named: "我的收藏")
            case UserSetting:
                return UIImage(named: "账户设置")
            case UserOpenStore:
                return UIImage(named: "我要开店")
            case .UserPublishSupply:
                return UIImage(named: "发布供应")
            case .UserPublishDemand:
                return UIImage(named: "发布求购")
            default :
                return UIImage(named: "")
            }
        }
        
        var pushViewController :UIViewController{
            let viewController: UIViewController
            switch self{
            case UserMyOrder:
                viewController = MyOrderViewController.CreateFromMainStoryboard() as! MyOrderViewController
                (viewController as! MyOrderViewController).orderStatuId = 0
                (viewController as! MyOrderViewController).orderStatusIndex = 0
            case .UserSupply:
                viewController = MineSupplyOrDemandViewController.CreateFromMainStoryboard() as! MineSupplyOrDemandViewController
                (viewController as! MineSupplyOrDemandViewController).contentType = .Supply
            case .UserDemand:
                viewController = MineSupplyOrDemandViewController.CreateFromMainStoryboard() as! MineSupplyOrDemandViewController
                (viewController as! MineSupplyOrDemandViewController).contentType = .Demand
            case .UserCollect:
                viewController = MineCollectionViewController()
            case .UserOpenStore:
                viewController = MineOpenStoreFirstViewController.CreateFromStoreStoryboard() as! MineOpenStoreFirstViewController
            case .UserSetting:
                viewController = PersonInfoViewController()
            case .UserPublishSupply:
                viewController = PublishSupplyViewController.CreateFromMainStoryboard() as! PublishSupplyViewController
                (viewController as! PublishSupplyViewController).contentType = .Supply
            case .UserPublishDemand:
                viewController = PublishSupplyViewController.CreateFromMainStoryboard() as! PublishSupplyViewController
                (viewController as! PublishSupplyViewController).contentType = .Demand
            default :
                viewController = UIViewController()
            }
            viewController.hidesBottomBarWhenPushed = true
            return viewController
        }

        func didSelect(navViewController:UINavigationController){
            self.pushViewController.hidesBottomBarWhenPushed = true
            navViewController.pushViewController(pushViewController, animated: true)
        }
    }
    
    @IBOutlet weak var currentTableView: UITableView!
    var userCenterData: [[UserCenterCellType]]!
    var orderMenuView : UIView!
    var orderNumberDic:NSMutableDictionary!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 让导航栏支持右滑返回功能
        ZMDTool.addInteractive(self.navigationController)
        self.dataInit()
        self.updateUI()
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        self.dataInit()
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
        return self.userCenterData[section].count
    }
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.userCenterData.count
    }
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0
        }
        return  zoom(12)
    }
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headView = UIView(frame: CGRectMake(0, 0, kScreenWidth, zoom(12)))
        headView.backgroundColor = UIColor.clearColor()
        return headView
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let cellType = self.userCenterData[indexPath.section][indexPath.row]
        switch cellType {
        case .UserHead:
            return zoom(206)
        default :
            return zoom(52)
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellType = self.userCenterData[indexPath.section][indexPath.row]
        switch cellType {
        case .UserHead:
            let cellId = "HeadCell"
            let cell = tableView.dequeueReusableCellWithIdentifier(cellId)
            
            //添加orderMenuView
            if self.orderMenuView != nil {
                self.orderMenuView.removeFromSuperview()
            }
            let menuTitle = ["0\n待付款","0\n待发货","0\n待收货","0\n待评价","0\n退款"]
            var i = 0
            var tag = 10000
            self.orderMenuView = UIView(frame: CGRect(x: 0, y: zoom(206-71), width: kScreenWidth, height: zoom(71)))
            for title  in menuTitle {
                let width = kScreenWidth/5,height = CGFloat(55)
                let x = CGFloat(i) * width
                let btn = ZMDTool.getButton(CGRect(x: x, y: 0, width: width, height: height), textForNormal: title, fontSize: 13, backgroundColor: UIColor.clearColor(), blockForCli: { (sender) -> Void in
                    if !g_isLogin {
                        let vc = LoginViewController.CreateFromLoginStoryboard() as! LoginViewController
                        self.pushToViewController(vc, animated: true, hideBottom: true)
                        return
                    }
                    //点击订单目录(待付款。。。。)
                    let index = Int(x/width)+1  //“+1”是跳过前面的 “全部”btn
                    if index == 5 {
                        //售后
                        let vc = MyOrderViewController.CreateFromMainStoryboard() as! MyOrderViewController
                        vc.orderStatuId = 0
                        vc.orderStatusIndex = 0
                        vc.isAfterSale = true
                        self.pushToViewController(vc, animated: true, hideBottom: true)
                    }else{
                        let vc = MyOrderViewController.CreateFromMainStoryboard() as! MyOrderViewController
                        vc.orderStatusIndex = index
                        vc.orderStatuId = index
                        vc.hidesBottomBarWhenPushed = true
                        self.navigationController?.pushViewController(vc, animated: true)
                        let customButtons = vc.view.viewWithTag(200) as! CustomJumpBtns
                        let btn = customButtons.viewWithTag(1000+index) as! UIButton
                        if index != 0 {
                            (customButtons.viewWithTag(1000) as!UIButton).selected = false
                        }
                        customButtons.selectBtn = btn
                        customButtons.setSelectedBtn(btn:customButtons.selectBtn)
                    }
                })
                btn.tag = tag++
                btn.titleLabel?.numberOfLines = 2
                btn.titleLabel?.textAlignment = .Center
                btn.setTitleColor(UIColor.whiteColor(), forState: .Normal)
                let line = ZMDTool.getLine(CGRect(x: CGRectGetMaxX(btn.frame), y: 30, width: 1, height: 15), backgroundColor: defaultLineColor)
                orderMenuView.addSubview(line)
                orderMenuView.addSubview(btn)
                i++
            }
            cell?.contentView.addSubview(self.orderMenuView)
            cell?.addLine()
            
            if let backgroundV = cell?.viewWithTag(10003) as? UIImageView {
                backgroundV.image = UIImage(named: "store_home_bg")
                cell?.contentView.sendSubviewToBack(backgroundV)
            }
            if let personImgV = cell!.viewWithTag(10001) as? UIImageView {
                ZMDTool.configViewLayerWithSize(personImgV, size: 30)
                if !g_isLogin {
                    personImgV.image = UIImage(named: "示例头像")
                } else if let urlStr = g_customer?.Avatar?.AvatarUrl where urlStr != "" {
                    let url = NSURL(string: urlStr)
                    personImgV.sd_setImageWithURL(url)
                }
            }
            //设置用户名Label.text
            if let usrNameLbl = cell?.viewWithTag(10002) as? UILabel {
                if !g_isLogin {
                    usrNameLbl.text = "登陆 | 注册"
                    usrNameLbl.font = UIFont.boldSystemFontOfSize(17)
                }else{
                    usrNameLbl.text = getObjectFromUserDefaults("realName") as? String
                    usrNameLbl.font = UIFont.systemFontOfSize(15)
                }
            }
            
            tag = 10000
            if let orderNumber = self.orderNumberDic,waitPay = orderNumber["WaitPay"],waitDelivery = orderNumber["WaitDelivery"],waitReceivce = orderNumber["WaitReceivce"],waitReview = orderNumber["WaitReview"],afterSale = orderNumber["AfterSale"],complete = orderNumber["Complete"] {
                let numbers = !g_isLogin ? ["0","0","0","0","0"] : [waitPay,waitDelivery,waitReceivce,waitReview,afterSale]
                let status = ["待付款","待发货","待收货","待评价","退款"]
                for index in 0..<numbers.count {
                    var titles = "\(numbers[index])\n\(status[index])"
                    if !g_isLogin {
                        titles = "0\n\(status[index])"
                    }
                    let button = self.orderMenuView.viewWithTag(tag++) as! UIButton
                    button.setTitle(titles, forState: .Normal)
                }
            }
            return cell!
        default :
            let cellId = "OtherCell"
            var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
            if cell == nil {
                cell = UITableViewCell(style: .Default, reuseIdentifier: cellId)
                cell?.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
                cell!.selectionStyle = .None
                ZMDTool.configTableViewCellDefault(cell!)
                cell?.addLine()
            }
            
            cell?.imageView?.image = cellType.image
            cell!.textLabel?.text = cellType.title
            return cell!
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if !g_isLogin {
            let vc = LoginViewController.CreateFromLoginStoryboard() as! LoginViewController
            self.pushToViewController(vc, animated: true, hideBottom: true)
            return
        }
        let cellType = self.userCenterData[indexPath.section][indexPath.row]
        switch cellType{
        case .UserHead :
            break
        default:
            cellType.didSelect(self.navigationController!)
            break
        }
    }
    //MARK:Private Method
    func configHead() {
        
    }
    func updateUI() {
        self.currentTableView.backgroundColor = tableViewdefaultBackgroundColor
        self.configMoreButton()
    }
    
    private func dataInit(){
        //目前功能
        self.userCenterData = [[.UserHead,.UserMyOrder],[.UserSupply,.UserDemand,.UserCollect],/*[.UserOpenStore],*/[.UserPublishSupply,.UserPublishDemand],[.UserSetting]]
        self.currentTableView.reloadData()
        if g_isLogin! {
            QNNetworkTool.fetchOrder(0, orderNo: "", pageIndex: 0, pageSize: 12) { (orders ,dic, Error) -> Void in
                if let dictionary = dic, dict = dictionary["CustomerOrderStatusModel"] {
                    self.orderNumberDic = NSMutableDictionary(dictionary: dict as! [NSObject : AnyObject])
                    self.currentTableView.reloadData()
                }
            }
        }
    }
}

