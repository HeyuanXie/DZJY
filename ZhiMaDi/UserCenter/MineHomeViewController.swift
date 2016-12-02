//
//  MineViewController.swift
//  ZhiMaDi
//
//  Created by haijie on 16/2/22.
//  Copyright © 2016年 ZhiMaDi. All rights reserved.
//

import UIKit
import ReactiveCocoa

//我的  首页
class MineHomeViewController: UIViewController,UITableViewDataSource, UITableViewDelegate,ZMDInterceptorProtocol {

    enum UserCenterCellType{
        case UserHead
        case UserMyOrder
        case UserMyOrderMenu
        case UserWallet
        case UserBankCard
        case UserCardVolume
        case UserMyCrowdFunding
        
        case UserMyStore
        case UserVipClub
        case UserCommission
        case UserInvitation

        case UserAddress
        case UserHelp
        case UserMore
        
        init(){
            self = UserHead
        }
        
        var title : String{
            switch self{
            case UserHead :
                return ""
            case UserMyOrder :
                return ""
            case UserMyOrderMenu :
                return ""
                
            case UserWallet :
                return "钱包"
            case UserBankCard :
                return "银行卡"
            case UserCardVolume :
                return "卡券"
            case UserMyCrowdFunding :
                return "我的众筹"
                
            case UserMyStore :
                return "我的店铺"
            case UserVipClub :
                return "会员俱乐部"
            case UserCommission :
                return "赚佣金"
            case UserInvitation :
                return "邀请好友注册"
                
            case .UserAddress :
                return "管理收货地址"
            case UserHelp :
                return "帮助与反馈"
            case UserMore :
                return "浏览记录"
            }
        }
        var image : UIImage?{
            switch self{
            case UserWallet :
                return UIImage(named: "user_wallet")
            case UserBankCard :
                return UIImage(named: "user_bankcard")
            case UserCardVolume :
                return UIImage(named: "user_card")
            case UserMyCrowdFunding :
                return UIImage(named: "user_crowdfunding")
                
            case UserMyStore :
                return UIImage(named: "user_myshop")
            case UserVipClub :
                return UIImage(named: "user_vipclub")
            case UserCommission :
                return UIImage(named: "user_earn")
            case UserInvitation :
                return UIImage(named: "user_share")
                
            case .UserAddress :
                return UIImage(named: "user_address")
            case UserHelp :
                return UIImage(named: "user_help")
            default :
                return UIImage(named: "")
            }
        }
        
        var pushViewController :UIViewController{
            let viewController: UIViewController
            switch self{
            case UserMyOrder:
                viewController = MyOrderViewController.CreateFromMainStoryboard() as! MyOrderViewController
            case UserMyOrderMenu:
                viewController = UIViewController()
                
            case UserWallet:
                viewController = WalletHomeViewController.CreateFromMainStoryboard() as! WalletHomeViewController
            case UserBankCard:
                viewController = BankCardHomeViewController()
            case UserCardVolume:
                viewController = CardVolumeHomeViewController()
            case UserMyCrowdFunding:
                viewController = MyCrowdfundHomeViewController()
                
            case UserMyStore:
                viewController = MyStoreHomeViewController.CreateFromStoreStoryboard() as! MyStoreHomeViewController
            case UserVipClub:
                viewController = VipClubHomeViewController.CreateFromMainStoryboard() as! VipClubHomeViewController
            case UserCommission:
                viewController = UIViewController()
            case UserInvitation:
                viewController = InvitationShareHomeViewController()
                
            case .UserAddress:
                viewController = AddressViewController.CreateFromMainStoryboard() as! AddressViewController
                (viewController as! AddressViewController).canSelect = false
            case .UserMore :
                viewController = MineBrowseRecordViewController.CreateFromMainStoryboard() as! MineBrowseRecordViewController
            case UserHelp:
                viewController = MineHomeHelpViewController()
            default :
                viewController = UIViewController()
            }
            viewController.hidesBottomBarWhenPushed = true
            return viewController
        }

        func didSelect(navViewController:UINavigationController){
            navViewController.pushViewController(pushViewController, animated: true)
        }
    }
    
    @IBOutlet weak var currentTableView: UITableView!
    var userCenterData: [[UserCenterCellType]]!
    
    var isTabBarVC = true
    var isSaveImage = false
    
    var headImageData : NSData!
    var btn :UIButton!
    
    var orderNumberDic:NSMutableDictionary!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.btn = UIButton(frame: self.view.bounds)
        self.btn.rac_command = RACCommand(signalBlock: { (sender) -> RACSignal! in
            let vc = LoginViewController.CreateFromLoginStoryboard() as! LoginViewController
            self.pushToViewController(vc, animated: true, hideBottom: true)
            return RACSignal.empty()
        })
        self.view.addSubview(self.btn)
        
        // 让导航栏支持右滑返回功能
        ZMDTool.addInteractive(self.navigationController)
        self.dataInit()
        self.updateUI()
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        if g_isLogin! {
            self.btn.userInteractionEnabled = false
        }else{
            self.btn.userInteractionEnabled = true
        }
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
        return  16
    }
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headView = UIView(frame: CGRectMake(0, 0, kScreenWidth, 16))
        headView.backgroundColor = UIColor.clearColor()
        return headView
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let cellType = self.userCenterData[indexPath.section][indexPath.row]
        switch cellType {
        case .UserHead:
            return 190
        default :
            return 55
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellType = self.userCenterData[indexPath.section][indexPath.row]
        switch cellType {
        case .UserHead:
            let cellId = "HeadCell"
            let cell = tableView.dequeueReusableCellWithIdentifier(cellId)
            //设置背景图和用户图像(圆形)
            if let backgroundV = cell?.viewWithTag(10000) as? UIImageView {
                ZMDTool.configViewLayer(backgroundV)
                if let urlStr = g_customer?.Avatar?.AvatarUrl,url = NSURL(string: urlStr){
                    backgroundV.sd_setImageWithURL(url, placeholderImage: nil)
                }
                cell?.sendSubviewToBack(backgroundV)
            }
            
            if let personImgV = cell!.viewWithTag(10001) as? UIImageView{
                ZMDTool.configViewLayerWithSize(personImgV, size: 42)
                if let urlStr = g_customer?.Avatar?.AvatarUrl,url = NSURL(string: urlStr) {
                    personImgV.sd_setImageWithURL(url, placeholderImage: nil)
                }
            }
            //设置用户名Label.text
            if let usrNameLbl = cell?.viewWithTag(10002) as? UILabel {
                usrNameLbl.text = g_customer?.FirstName ?? ""
                usrNameLbl.textColor = UIColor.whiteColor()
                if g_isLogin! {
                    usrNameLbl.text = getObjectFromUserDefaults("nickName") as? String
                }else{
                    usrNameLbl.text = "登陆 | 注册"
                    usrNameLbl.font = UIFont.boldSystemFontOfSize(17)
                }
            }
            
            //收藏的商品
            let collectionBtn = cell?.viewWithTag(10003) as! UIButton
            collectionBtn.rac_command = RACCommand(signalBlock: { (sender) -> RACSignal! in
                let vc = MineCollectionViewController()
                vc.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(vc, animated: true)
                return RACSignal.empty()
            })
            
            //关注的店铺
            let followBtn = cell?.viewWithTag(10004) as! UIButton
            followBtn.rac_command = RACCommand(signalBlock: { (sender) -> RACSignal! in
                
                ZMDTool.showPromptView("功能暂未开放")
                return RACSignal.empty()
            })
            return cell!
        case .UserMyOrder :
            let cellId = "MyOrderCell"
            let cell = tableView.dequeueReusableCellWithIdentifier(cellId)
            if let dic = self.orderNumberDic,total = dic["Total"] {
                (cell?.viewWithTag(1000) as!UILabel).attributedText = "我的订单 (\(total))".AttributedText("\(total)", color: defaultSelectColor)
            }
            return cell!
        case .UserMyOrderMenu :
            let cellId = "MyOrderMenuCell"
            var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
            if cell == nil {
                cell = UITableViewCell(style: .Subtitle, reuseIdentifier: cellId)
                cell?.accessoryType = UITableViewCellAccessoryType.None
                cell!.selectionStyle = .None
                ZMDTool.configTableViewCellDefault(cell!)
                
                let menuTitle = ["0\n待付款","0\n待发货","0\n待收货","0\n待评价","0\n退货/售后"]
                var i = 0
                var tag = 10000
                for title  in menuTitle {
                    let width = kScreenWidth/5,height = CGFloat(55)
                    let x = CGFloat(i) * width
                    let btn = ZMDTool.getButton(CGRect(x: x, y: 0, width: width, height: height), textForNormal: title, fontSize: 14, backgroundColor: UIColor.clearColor(), blockForCli: { (sender) -> Void in
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
                    let line = ZMDTool.getLine(CGRect(x: CGRectGetMaxX(btn.frame), y: 30, width: 1, height: 15), backgroundColor: defaultLineColor)
                    cell?.contentView.addSubview(line)
                    cell?.contentView.addSubview(btn)
                    i++
                }
            }
            
            var tag = 10000
            if let orderNumber = self.orderNumberDic,waitPay = orderNumber["WaitPay"],waitDelivery = orderNumber["WaitDelivery"],waitReceivce = orderNumber["WaitReceivce"],waitReview = orderNumber["WaitReview"],afterSale = orderNumber["AfterSale"],complete = orderNumber["Complete"] {
                /*let numbers = [waitPay,waitDelivery,waitReceivce,complete,afterSale]
                let status = ["待付款","待发货","待收货","已完成","退货/售后"]*/
                let numbers = [waitPay,waitDelivery,waitReceivce,waitReview,afterSale]
                let status = ["待付款","待发货","待收货","待评价","退货/售后"]
                for index in 0..<numbers.count {
                    let title = "\(numbers[index])\n\(status[index])"
                    let button = cell?.contentView.viewWithTag(tag++) as! UIButton
                    button.setTitle(title, forState: .Normal)
//                    button.titleLabel?.attributedText = title.AttributedText("\(numbers[index])", color: defaultSelectColor)
                }
            }
            return cell!
        case .UserMore :
            let cellId = "MoreCell"
            var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
            if cell == nil {
                cell = UITableViewCell(style: .Subtitle, reuseIdentifier: cellId)
                cell?.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
                cell!.selectionStyle = .None
                ZMDTool.configTableViewCellDefault(cell!)
                
                let label = ZMDTool.getLabel(CGRect(x: kScreenWidth - 34 - 100, y: 0, width: 100, height: 55), text: "更多", fontSize: 15,textColor:defaultDetailTextColor)
                label.textAlignment = .Right
                cell?.contentView.addSubview(label)
            }
            cell!.textLabel?.text = cellType.title
            return cell!
        default :
            let cellId = "OtherCell"
            var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
            if cell == nil {
                cell = UITableViewCell(style: .Default, reuseIdentifier: cellId)
                cell?.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
                cell!.selectionStyle = .None
                ZMDTool.configTableViewCellDefault(cell!)
                
                cell?.contentView.addSubview(ZMDTool.getLine(CGRect(x: 0, y: 54.5, width: kScreenWidth, height: 0.5)))
            }
            
            cell?.imageView?.image = cellType.image
            cell!.textLabel?.text = cellType.title
            return cell!
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cellType = self.userCenterData[indexPath.section][indexPath.row]
        switch cellType{
        case .UserHead :
            break
        case .UserMyOrder:
            let vc = MyOrderViewController.CreateFromMainStoryboard() as! MyOrderViewController
            vc.orderStatusIndex = 0
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
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
        let rightItem = UIBarButtonItem(image: UIImage(named: "user_set"), style: .Done, target: nil, action: nil)
        rightItem.rac_command = RACCommand(signalBlock: { (sender) -> RACSignal! in
            let vc = PersonInfoViewController()
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
            return RACSignal.empty()
        })
        self.navigationItem.rightBarButtonItem = rightItem
        
        /*if !self.isTabBarVC {
            let leftItem = UIBarButtonItem(image: UIImage(named: "common_return_black"), style: .Plain, target: self, action: "back")
            self.navigationItem.leftBarButtonItem = leftItem
        }*/
    }
    
    private func dataInit(){
        //目前功能
        self.userCenterData = [[.UserHead,.UserMyOrder,.UserMyOrderMenu], [.UserCardVolume],[.UserAddress],[.UserHelp],]
        //全部功能
        //        self.userCenterData = [[.UserHead,.UserMyOrder,.UserMyOrderMenu],[.UserWallet,.UserCardVolume,.UserMyCrowdFunding],[.UserMyStore,.UserVipClub,.UserCommission,.UserInvitation],[.UserHelp],[.UserMore]]
        
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

