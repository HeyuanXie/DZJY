//
//  HomeViewController.swift
//  ZhiMaDi
//
//  Created by haijie on 16/2/19.
//  Copyright © 2016年 ZhiMaDi. All rights reserved.
//

import UIKit
//首页
class HomePageViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate,UIScrollViewDelegate,CycleScrollViewDelegate,ZMDInterceptorProtocol,UITextFieldDelegate {
    
    let specialHeights : [String:CGFloat] = ["supplyDetailCell":324,"fruitDetailCell":515]
    
    //首页section的枚举
    enum UserCenterCellType{
        case HomeContentTypeAd                      /* 广告显示页 */
        case HomeContentTypeMenu                    /* 菜单选择栏目 */
        case HomeContentTypeState                   /* 交易动态 */
        case HomeContentTypeDoubleGood              /* 连个商品的cell */
        case HomeContentTypeMulityGood              /* 多个商品的cell */
        case HomeContentTypeRecommend               /* 推荐的商品和农业基地 */
        case HomeContentTypeMiniAd                  /* 第二个小广告 */
        case HomeContentTypeSupplyHead              /* 供应、求购头部segmentcell */
        case HomeContentTypeSupplyDetail            /* 供应、求购详情cell*/
        case HomeContentTypeSupplyFoot              /* 供应、求购底部cell */
        case HomeContentTypeFruitHead               /* 水果、蔬菜segmentCell */
        case HomeContentTypeFruitSort               /* 水果、蔬菜删选 */
        case HomeContentTypeFruitDetail             /* 水果、蔬菜详情cell*/
        
        init(){
            self = HomeContentTypeAd
        }
        
        var heightForHeadOfSection : CGFloat {
            switch  self {
            case .HomeContentTypeAd :
                return 0
            case .HomeContentTypeMenu :
                return 0
            default :
                return 12
            }
        }
        
        var height : CGFloat {
            switch  self {
            case .HomeContentTypeAd :
                return kScreenWidth * 400 / 750
                
                //*******MenuSection********
            case .HomeContentTypeMenu :
                return kScreenWidth * 210 / 750
            case .HomeContentTypeState :

                //******MiniAdSection********
                return kScreenWidth * 80 / 750
            case .HomeContentTypeMiniAd :
                return 90
                
                //*******GoodSection********
            case .HomeContentTypeDoubleGood :
                return kScreenWidth * 98 / 375
            case .HomeContentTypeMulityGood:
                return kScreenWidth * 110 / 375
            case .HomeContentTypeRecommend:
                return kScreenWidth * 140 / 750
                
                //********SupplySection*******
            case .HomeContentTypeSupplyHead:
                return kScreenWidth * 44 / 375
//            case .HomeContentTypeSupplyDetail:
//                return kScreenWidth * 324 / 750
            case .HomeContentTypeSupplyFoot:
                return kScreenWidth * 50 / 375
                
                //********FruitSection********
            case .HomeContentTypeFruitHead:
                return kScreenWidth * 44 / 375
            case .HomeContentTypeFruitSort:
                return kScreenWidth * 55 / 375
//            case .HomeContentTypeFruitDetail:
//                return kScreenWidth * 515 / 750
            default :
                //supplyDetail和FruitDetail两个cell高度通过specialHeights获取
                return 40
            }
        }
    }
    
    //菜单选择类型枚举
    enum MenuType {
        
        case kFeature
        case kECommerce
        case kSupply
        case kDemand
        case kEnterprise
        
        init(){
            self = kFeature
        }
        
        //菜单选择名称枚举
        var title : String{
            switch self{
            case kFeature:
                return "喀什农特"
            case .kECommerce:
                return "农村电商"
            case .kSupply:
                return "供应"
            case .kDemand:
                return "求购"
            case .kEnterprise:
                return "交易企业"
            }
        }
        
        //菜单选择图片枚举
        var image : UIImage?{
            switch self{
            case .kFeature:
                return UIImage(named: "home_new")
            case .kECommerce:
                return UIImage(named: "home_list")
            case .kSupply:
                return UIImage(named: "home_zulin")
            case .kDemand:
                return UIImage(named: "home_coupons")
            case .kEnterprise:
                return UIImage(named: "home_new")
            }
        }
        
        //点击菜单选择，跳转目标VC的枚举
        var pushViewController :UIViewController{
            let viewController: UIViewController
            switch self{
            case .kFeature:
                viewController = UIViewController()
            case .kECommerce:
                viewController = UIViewController()
            case .kSupply:
                viewController = SupplyDemandListViewController.CreateFromMainStoryboard() as! SupplyDemandListViewController
                (viewController as! SupplyDemandListViewController).vcTitle = "供应"
                viewController.hidesBottomBarWhenPushed = true
            case .kDemand:
                viewController = SupplyDemandListViewController.CreateFromMainStoryboard() as! SupplyDemandListViewController
                (viewController as! SupplyDemandListViewController).vcTitle = "求购"
                (viewController as! SupplyDemandListViewController).check = 2
                viewController.hidesBottomBarWhenPushed = true
            case .kEnterprise:
                viewController = UIViewController()
            }
            viewController.title = self.title
            return viewController
        }
        
        //点击菜单选择，调用方法跳转
        func didSelect(navViewController:UINavigationController){
            navViewController.pushViewController(self.pushViewController, animated: false)
        }
    }
    
    @IBOutlet weak var currentTableView: UITableView!
    
    var userCenterData = [[UserCenterCellType.HomeContentTypeAd],[.HomeContentTypeMenu,.HomeContentTypeState],[.HomeContentTypeDoubleGood,.HomeContentTypeMulityGood,.HomeContentTypeRecommend],[.HomeContentTypeMiniAd],[.HomeContentTypeSupplyHead,.HomeContentTypeSupplyDetail,.HomeContentTypeSupplyFoot],[.HomeContentTypeFruitHead,.HomeContentTypeFruitSort,.HomeContentTypeFruitDetail]]
    
    var searchType = ["供应","求购","商品","店家"]
    
    var fruitSelectIndex = 0       //水果蔬菜section 删选按钮选中记录
    var orderbySalesUp = true      //水果蔬菜section 按销量排序
    var orderbyPriceUp = true      //水果蔬菜section 按价格排序
    var orderby = 0                //水果蔬菜section 数据请求的排序方式
    var pageIndex = 1              //水果蔬菜section 数据请求页数
    
    var menuType: [MenuType]!
    var 下拉视窗 : UIView!
    var categories = NSMutableArray()
    var advertisementAll : ZMDAdvertisementAll!
    var textInput: UITextField!
    
    var history = NSMutableArray()
    var newProducts = NSMutableArray()
    
    var navBackView : UIView!
    var navLine : UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // 让导航栏支持右滑返回功能
        ZMDTool.addInteractive(self.navigationController)
        self.updateUI()
        self.dataInit()
        self.fetchData()
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        //检测更新
        if APP_LAUNCHEDTIME == 1 {
            self.checkUpdate()
        }
//        self.fetchData()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(true)
        APP_LAUNCHEDTIME = APP_LAUNCHEDTIME + 1
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: checkUpdate
    func checkUpdate() {
        var version = "0.0.0"
        QNNetworkTool.checkUpdate { (error, dictionary) in
            if let dic = dictionary,arr = dic["results"] as? NSArray, resultCount = dic["resultCount"] as? Int where resultCount != 0 {
                if let dict = arr[0] as? NSDictionary {
                    if let appStoreVersion = dict["version"] as? String  {
                        version = appStoreVersion
                        saveObjectToUserDefaults("appStoreVersion", value: version)
                        self.compareTheVersion()
                    }
                }
            }
        }
    }
    
    func compareTheVersion() {
        let appStoreVersion = getObjectFromUserDefaults("appStoreVersion") as! String
        if appStoreVersion == "0.0.0" {
            return
        }
        let result = compareVersion(APP_VERSION, version2: appStoreVersion)
        if result == NSComparisonResult.OrderedAscending {
            self.commonAlertShow(true, btnTitle1: "确定", btnTitle2: "下一次", title: "版本更新", message: "检测到新版本\(appStoreVersion)可用\n是否立即更新?", preferredStyle: .Alert)
        }
    }
    
    
    //MARK:- UITableViewDataSource,UITableViewDelegate
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.userCenterData[section].count
    }
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.userCenterData.count
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return self.userCenterData[section][0].heightForHeadOfSection
    }
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headView = UIView(frame: CGRectMake(0, 0, kScreenWidth, 10))
        headView.backgroundColor = UIColor.clearColor()
        return headView
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let cellType = self.userCenterData[indexPath.section][indexPath.row]
        if cellType == .HomeContentTypeSupplyDetail {
            return self.specialHeights["supplyDetailCell"]!
        }
        if cellType == .HomeContentTypeFruitDetail {
            return self.specialHeights["fruitDetailCell"]!
        }
        return cellType.height
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch  self.userCenterData[indexPath.section][indexPath.row] {
        case .HomeContentTypeAd :
            return self.cellForHomeAd(tableView, indexPath: indexPath)
        case .HomeContentTypeMenu :
            return self.cellForHomeMenu(tableView, indexPath: indexPath)
        case .HomeContentTypeState :
            return self.cellForHomeState(tableView, IndexPath: indexPath)
        case .HomeContentTypeDoubleGood :
            return self.cellForHomeDoubleGood(tableView, IndexPath: indexPath)
        case .HomeContentTypeMulityGood :
            return self.cellForHomeMulityGood(tableView, IndexPath: indexPath)
        case .HomeContentTypeRecommend :
            return self.cellForHomeRecommend(tableView, indexPath: indexPath)
        case .HomeContentTypeMiniAd :
            return self.cellForHomeMiniAd(tableView, IndexPath: indexPath)
        case .HomeContentTypeSupplyHead:
            return self.cellForHomeSupplyHead(tableView, IndexPath: indexPath)
        case .HomeContentTypeSupplyDetail:
            return self.cellForHomeSupplyDetail(tableView, IndexPath: indexPath)
        case .HomeContentTypeSupplyFoot:
            return self.cellForHomeSupplyFoot(tableView, IndexPath: indexPath)
        case .HomeContentTypeFruitHead:
            return self.cellForHomeFruitHead(tableView, IndexPath: indexPath)
        case .HomeContentTypeFruitSort:
            return self.cellForHomeFruitSort(tableView, IndexPath: indexPath)
        case .HomeContentTypeFruitDetail:
            return self.cellForHomeFruitDetail(tableView, IndexPath: indexPath)
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == self.userCenterData.count-1 {
            if let advertisementAll = self.advertisementAll,topic = advertisementAll.topic {
                let advertisement = topic[indexPath.row]
                self.advertisementClick(advertisement)
            }
        }
    }
    
    //MARK: ***************代理方法*************
    //MARK: 触摸代理
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if self.advertisementAll == nil {
            self.fetchData()
        }
    }
    //MARK: TextFieldDelegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        if textField.text != "" {
            self.view.viewWithTag(100)?.removeFromSuperview()
            let vc = HomeBuyListViewController.CreateFromMainStoryboard() as! HomeBuyListViewController
            vc.titleForFilter = textField.text ?? ""
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
        }
        return true
    }
    //点击背景、收起键盘
    func textFieldDidBeginEditing(textField: UITextField) {
        let bgBtn = UIButton(frame: self.view.bounds)
        bgBtn.tag = 100
        self.presentPopupView(bgBtn, config: .None)
        bgBtn.rac_command = RACCommand(signalBlock: { (sender) -> RACSignal! in
            bgBtn.removeFromSuperview()
            self.textInput.resignFirstResponder()
            return RACSignal.empty()
        })
    }
    
    //MARK: 广告分区cycleScrollView delegate
    func clickImgAtIndex(index: Int) {
        //点击cycleScrollView中图片，响应事件
        if let advertisementAll = self.advertisementAll {
            let advertisement = advertisementAll.top![index]
            self.advertisementClick(advertisement)
        }
    }

    //MARK: CommonAlert Action重写
    override func alertDestructiveAction() {
        if let url = NSURL(string: APP_URL_IN_ITUNES) {
            UIApplication.sharedApplication().openURL(url)
        }
    }
    override func alertCancelAction() {
        
    }
    //MARK: 头部菜单 cell
    func cellForHomeHead(tableView: UITableView,indexPath: NSIndexPath)-> UITableViewCell {
        let cellId = "HeadCell"
        var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
        let menuTitles = self.categories
        if cell == nil {
            cell = UITableViewCell(style: .Default, reuseIdentifier: cellId)
            cell!.selectionStyle = .None
            cell!.contentView.backgroundColor = UIColor.whiteColor()
            
            let width = 80,height = 44
            let scrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: kScreenWidth - 44, height: 44)) //66
            scrollView.tag = 10001
            scrollView.backgroundColor = UIColor.clearColor()
            scrollView.showsHorizontalScrollIndicator = false
            //******这里设置scrollView的contentSize只会在创建cell的时候执行，
            //******请求数据成功时cell != nil，这部分代码不执行，所以要在其他地方进行设置contentSize
//            scrollView.contentSize = CGSize(width: width * menuTitles.count, height: height)
            cell?.contentView.addSubview(scrollView)

            
            //下部弹窗
            let 下拉 = UIButton(frame: CGRect(x: kScreenWidth - 44, y: 8, width: 44, height: 28))
            下拉.backgroundColor = UIColor.whiteColor()
            下拉.setImage(UIImage(named: "home_down"), forState: .Normal)
            下拉.setImage(UIImage(named: "home_up"), forState: .Selected)
            下拉.rac_signalForControlEvents(.TouchUpInside).subscribeNext({ (sender) -> Void in
                self.updateViewForNextMenu()
                if CGRectGetMinY(self.下拉视窗.frame) < 0  {
                    self.下拉视窗.frame = CGRect(x: 0, y: 0, width: kScreenWidth, height: 44+150)
                    self.viewShowWithBg(self.下拉视窗,showAnimation: .SlideInFromTop,dismissAnimation: .SlideOutToTop)
                } else {
                    self.dismissPopupView(self.下拉视窗)
                }
            })
            cell?.contentView.addSubview(下拉)
            cell?.contentView.addSubview(ZMDTool.getLine(CGRect(x: kScreenWidth - 44, y: 8, width: 0.5, height: 28)))
        }
        
        let width = 80,height = 44
        let scrollView = cell?.viewWithTag(10001) as! UIScrollView
        //******cell != nil 时为scrollView设置contentSize
        scrollView.contentSize = CGSize(width: width * menuTitles.count, height: height)
        for subView in scrollView.subviews {
            subView.removeFromSuperview()
        }
        var i = 0
        for title in menuTitles {
            let x = i * width,y = 0
            let frame = CGRect(x: x, y: y, width: width, height: height)
            i++
            
            let headBtn = UIButton(frame: frame)
            headBtn.setTitle((title as! ZMDCategory).Name, forState: .Normal)
            headBtn.titleLabel?.font = defaultDetailTextSize
            headBtn.setTitleColor(defaultDetailTextColor, forState: .Normal)
            headBtn.setTitleColor(defaultSelectColor, forState: .Selected)
            headBtn.titleLabel?.textAlignment = .Center
            headBtn.tag = 1000+i
            headBtn.rac_signalForControlEvents(.TouchUpInside).subscribeNext({ (sender) -> Void in
                //直接点击scrollView上的btn，进行页面跳转
                let homeBuyListViewController = HomeBuyListViewController.CreateFromMainStoryboard() as! HomeBuyListViewController
                let titleFilter = (sender as! UIButton).titleLabel?.text
                homeBuyListViewController.titleForFilter = titleFilter ?? ""
//                let category = menuTitles[(sender as!UIButton).tag-1-1000] as! ZMDCategory
//                homeBuyListViewController.Cid = category.Id.stringValue
                self.navigationController?.pushViewController(homeBuyListViewController, animated: true)
            })
            scrollView.addSubview(headBtn)
        }
        return cell!
    }
    //MARK: ****************TableViewCell****************
    //MARK: cellFor广告section
    func cellForHomeAd(tableView: UITableView,indexPath: NSIndexPath)-> UITableViewCell {
        let cellId = "AdCell"
        var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
        if cell == nil {
            cell = UITableViewCell(style: .Default, reuseIdentifier: cellId)
            cell!.selectionStyle = .None
            cell!.contentView.backgroundColor = UIColor.whiteColor()
        }
        if let v = cell?.viewWithTag(10001) {
            v.removeFromSuperview()
        }
        let cycleScroll = CycleScrollView(frame: CGRectMake(0, 0, kScreenWidth, kScreenWidth * 400 / 750))
        cycleScroll.tag = 10001
        cycleScroll.backgroundColor = UIColor.whiteColor()
        cycleScroll.delegate = self
        cycleScroll.autoScroll = true
        cycleScroll.autoTime = 2.5
        let imgUrls = NSMutableArray()
        
        if self.advertisementAll != nil && self.advertisementAll.top != nil {
            for id in self.advertisementAll.top! {
                var url = kImageAddressNew + (id.ResourcesCDNPath ?? "")
                if id.ResourcesCDNPath!.hasPrefix("http") {
                    url = id.ResourcesCDNPath!
                }
                url = url.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
                imgUrls.addObject(NSURL(string: url)!)
            }
            if imgUrls.count != 0 {
                cycleScroll.urlArray = imgUrls as [AnyObject]
            }
        }
        cell?.addSubview(cycleScroll)
        return cell!
    }
    
    //MARK: cellFor菜单section
    /// 菜单cell
    func cellForHomeMenu(tableView: UITableView,indexPath: NSIndexPath)-> UITableViewCell {
        let cellId = "MenuCell"
        var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
        if cell == nil {
            cell = UITableViewCell(style: .Default, reuseIdentifier: cellId)
            cell?.accessoryType = UITableViewCellAccessoryType.None
            cell!.selectionStyle = .None
            ZMDTool.configTableViewCellDefault(cell!)
            cell!.contentView.backgroundColor = UIColor.whiteColor()

            for var i=0;i<self.menuType.count;i++ {
                _ = 0
                let btnHeight = kScreenWidth * 210 / 750
                let width = kScreenWidth/CGFloat(self.menuType.count)
                let btn = UIButton(frame: CGRectMake(kScreenWidth/4*CGFloat(i), 0 ,width, btnHeight))
                btn.tag = 10000 + i
                btn.backgroundColor = UIColor.whiteColor()
                
                let label = UILabel(frame: CGRectMake(0, btnHeight/2 + 20, width, 14))
                label.font = UIFont.systemFontOfSize(14)
                label.textColor = defaultTextColor
                label.textAlignment =  .Center
                label.tag = 10010 + i
                btn.addSubview(label)
                
                let imgV = UIImageView(frame: CGRectMake(width/2-25, btnHeight/2 - 25 - 15, 50,50))
                imgV.tag = 10020 + i
                btn.addSubview(imgV)
                cell!.contentView.addSubview(btn)
            }
        }
        
        for var i=0;i<5;i++ {
            let menuType = self.menuType[i]
            let btn = cell?.contentView.viewWithTag(10000 + i) as! UIButton
            let label = cell?.contentView.viewWithTag(10010 + i) as! UILabel
            let imgV = cell?.contentView.viewWithTag(10020 + i) as! UIImageView
            btn.rac_command = RACCommand(signalBlock: { (sender) -> RACSignal! in
                switch menuType {
                case .kFeature :
                    if let url = NSURL(string: "appJNNT://") {
                        UIApplication.sharedApplication().openURL(url)
                    }
                    break
                case .kECommerce :
                    if let url = NSURL(string: "appJNNZ://") {
                        UIApplication.sharedApplication().openURL(url)
                    }
                    break
                default :
                    menuType.didSelect(self.navigationController!)
                }
                return RACSignal.empty()
            })
            label.text = menuType.title
            imgV.image = menuType.image
            
            
            //当请求数据成功时,更新cellForHomeMenu上btn的图片和title
            /*if let advertisementAll = self.advertisementAll,icon = advertisementAll.icon {
                if icon.count != 0 {
                    let icon = i>=2 ? icon[i+1] : icon[i]
                    //icon的title暂时自定义为 类目i
                    label.text = icon.Title
                    var url = kImageAddressNew + (icon.ResourcesCDNPath ?? "")
                    if icon.ResourcesCDNPath!.hasPrefix("http") {
                        url = icon.ResourcesCDNPath!
                    }
                    //没图片，暂时不用
                    imgV.sd_setImageWithURL(NSURL(string: url), placeholderImage: nil)
                }
            }*/
         }
        cell?.addLine()
        return cell!
    }
    /// 交易动态cell
    func cellForHomeState(tableView: UITableView,IndexPath:NSIndexPath)-> UITableViewCell {
        //cellHeight = 40
        let cellId = "stateCell"
        var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
        if cell == nil {
            cell = UITableViewCell(style: .Default, reuseIdentifier: cellId)
            ZMDTool.configTableViewCellDefault(cell!)
            cell?.accessoryType = .DisclosureIndicator
            cell?.selectionStyle = .None
            
            let text = "交易动态"
            let width = text.sizeWithFont(UIFont.systemFontOfSize(14), maxWidth: 200).width+10*kScreenWidth/375
            let label = ZMDTool.getLabel(CGRect(x: 10*kScreenWidth/375, y: 10*kScreenWidth/375, width: width, height: 20*kScreenWidth/375), text: text, fontSize: 13, textColor: UIColor.whiteColor(), textAlignment: .Center)
            ZMDTool.configViewLayerWithSize(label, size: 4)
            cell?.contentView.addSubview(label)
            label.backgroundColor = appThemeColorNew
            
            let text2 = "[xj**12] 新疆吐鲁番无核白葡萄 8吨"
            let detailLbl = ZMDTool.getLabel(CGRect(x: 12+width+10, y: 10*kScreenWidth/375, width: kScreenWidth-(12+width+10)-20, height: 14), text: text2, fontSize: 13, textColor: UIColor.whiteColor(), textAlignment: .Left)
            detailLbl.attributedText = text2.AttributedMutableText(["[xj**12]","新疆吐鲁番无核白葡萄 8吨"], colors: [appThemeColorNew,defaultTextColor])
            cell?.contentView.addSubview(detailLbl)
        }
        return cell!
    }
    
    //MARK: cellFor商品section
    ///商品 cell  offer（已抛弃）
    func cellForHomeGoods(tableView: UITableView,indexPath: NSIndexPath)-> UITableViewCell {
        let cellId = "goodsCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellId) as! AdvertisementOfferCell
        if  self.advertisementAll != nil {
            AdvertisementOfferCell.configCell(cell, advertisementAll: self.advertisementAll.offer)
        }
        return cell
    }
    ///商品DoubleGoodCell
    func cellForHomeDoubleGood(tableView: UITableView,IndexPath:NSIndexPath)-> UITableViewCell {
        //cellHeight = 98
        let cellId = "doubleGoodCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellId) as! HomeDoubleGoodCell
        ZMDTool.configTableViewCellDefault(cell)
        return cell
    }
    ///商品MulityGoodCell
    func cellForHomeMulityGood(tableView: UITableView,IndexPath:NSIndexPath)-> UITableViewCell {
        //cellHeigth = 110
        let cellId = "multiGoodCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellId) as! HomeMultiGoodCell
        ZMDTool.configTableViewCellDefault(cell)
        return cell
    }
    ///推荐 cell
    func cellForHomeRecommend(tableView: UITableView,indexPath: NSIndexPath)-> UITableViewCell {
        //cellHeight:70
        let cellId = "recommendCell"
        var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
        if cell == nil {
            cell = UITableViewCell(style: .Default, reuseIdentifier: cellId)
            cell!.selectionStyle = .None
            cell!.contentView.backgroundColor = UIColor.whiteColor()
            
            let scrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 140*kScreenWidth/750))
            scrollView.showsHorizontalScrollIndicator = false
            scrollView.tag = 10000
            cell?.contentView.addSubview(scrollView)
            
            for i in 0..<3 {
                let width = 280*kScreenWidth/375
                let view = NSBundle.mainBundle().loadNibNamed("CommentView", owner: nil, options: nil)[1] as! RecommendView
                view.frame = CGRect(x: CGFloat(i)*width, y: 0, width: width, height: 70*kScreenWidth/375)
                view.tag = 10001 + i
                scrollView.addSubview(view)
            }
        }
        let scrollView = cell?.contentView.viewWithTag(10000) as! UIScrollView
        scrollView.contentSize = CGSizeMake(3*280*kScreenWidth/375, 0)
        for i in 0..<3 {
            let view = scrollView.viewWithTag(10001+i) as! RecommendView
            view.topLbl.attributedText = view.topLbl.text?.AttributedMutableText(["推荐"], colors: [appThemeColorNew])
            view.botLbl.attributedText = view.botLbl.text?.AttributedMutableText(["推荐"], colors: [appThemeColorNew])
        }
        
        return cell!
    }
    
    //MARK: cellFor小广告section
    func cellForHomeMiniAd(tableView: UITableView,IndexPath:NSIndexPath)-> UITableViewCell {
        //cellHeight:90
        let cellId = "miniAdCell"
        var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
        if cell == nil {
            cell = UITableViewCell(style: .Default, reuseIdentifier: cellId)
            cell!.selectionStyle = .None
            cell!.contentView.backgroundColor = UIColor.whiteColor()
        }
        if let v = cell?.viewWithTag(10001) {
            v.removeFromSuperview()
        }
        let cycleScroll = CycleScrollView(frame: CGRectMake(0, 0, kScreenWidth, 90))
        cycleScroll.backgroundColor = UIColor.whiteColor()
        cycleScroll.isPageCenter = true
        cycleScroll.tag = 10001
        cycleScroll.delegate = self
        cycleScroll.autoScroll = true
        cycleScroll.autoTime = 2.5
        let imgUrls = NSMutableArray()
        
        if self.advertisementAll != nil && self.advertisementAll.top != nil {
            for id in self.advertisementAll.top! {
                var url = kImageAddressNew + (id.ResourcesCDNPath ?? "")
                if id.ResourcesCDNPath!.hasPrefix("http") {
                    url = id.ResourcesCDNPath!
                }
                url = url.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
                imgUrls.addObject(NSURL(string: url)!)
            }
            if imgUrls.count != 0 {
                cycleScroll.urlArray = imgUrls as [AnyObject]
            }
        }
        cell?.addSubview(cycleScroll)
        return cell!
    }
    
    //MARK:cellFor供应section
    /// 供求头部cell
    func cellForHomeSupplyHead(tableView: UITableView,IndexPath:NSIndexPath)-> UITableViewCell {
        //cellHeight :44
        let cellId = "supplyHeadCell"
        var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
        if cell == nil {
            cell = UITableViewCell(style: .Default, reuseIdentifier: cellId)
            cell!.selectionStyle = .None
            cell!.contentView.backgroundColor = UIColor.whiteColor()
            
            let customJumpBtn = CustomJumpBtns(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 44*kScreenWidth/375), menuTitle: ["供应大厅","求购大厅"], textColorForNormal: defaultTextColor, textColorForSelect: appThemeColorNew, IsLineAdaptText: true)
            customJumpBtn.finished = {(index:Int) -> Void in
                
            }
            cell?.contentView.addSubview(customJumpBtn)
        }
        return cell!
    }
    /// 供求详情cell
    func cellForHomeSupplyDetail(tableView: UITableView,IndexPath:NSIndexPath)-> UITableViewCell {
        let cell = UITableViewCell()
        cell.addLine()
        return cell
    }
    /// 供求底部cell
    func cellForHomeSupplyFoot(tableView: UITableView,IndexPath:NSIndexPath)-> UITableViewCell {
        let cellId = "supplyFootCell"
        var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
        if cell == nil {
            cell = UITableViewCell(style: .Default, reuseIdentifier: cellId)
            cell!.selectionStyle = .None
            cell!.contentView.backgroundColor = UIColor.whiteColor()
            
            let btn = ZMDTool.getButton(CGRect(x: 0, y: 0, width: 160, height: 50*kScreenWidth/375), textForNormal: "查看全部", fontSize: 15, textColorForNormal: defaultTextColor, backgroundColor: UIColor.clearColor(), blockForCli: { (sender) -> Void in
                print("查看全部")
            })
            btn.setImage(UIImage(named: "right"), forState: .Normal)
            btn.set("cx",value:kScreenWidth/2)
            cell?.contentView.addSubview(btn)
        }
        return cell!
    }
    
    //MARK:cellFor水果蔬菜section
    /// 水果蔬菜头部cell
    func cellForHomeFruitHead(tableView: UITableView,IndexPath:NSIndexPath)-> UITableViewCell {
        //cellHeight :44
        let cellId = "fruitHeadCell"
        var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
        if cell == nil {
            cell = UITableViewCell(style: .Default, reuseIdentifier: cellId)
            cell!.selectionStyle = .None
            cell!.contentView.backgroundColor = UIColor.whiteColor()
            
            let customJumpBtn = CustomJumpBtns(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 44*kScreenWidth/375), menuTitle: ["水果","蔬菜"], textColorForNormal: defaultTextColor, textColorForSelect: appThemeColorNew, IsLineAdaptText: true)
            customJumpBtn.finished = {(index:Int) -> Void in
                
            }
            cell?.contentView.addSubview(customJumpBtn)
            cell?.addLine()
        }
        return cell!
    }
    /// 水果蔬菜删选cell
    func cellForHomeFruitSort(tableView: UITableView,IndexPath:NSIndexPath)-> UITableViewCell {
        //cellHeight :55
        let cellId = "fruitSortCell"
        var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
        if cell == nil {
            cell = UITableViewCell(style: .Default, reuseIdentifier: cellId)
            cell!.selectionStyle = .None
            cell!.contentView.backgroundColor = UIColor.whiteColor()
            
            let filters = ["默认","交易量","价格","地区/产地"]
            let countForBtn = CGFloat(4)
            for i in 0..<filters.count {
                let btn = UIButton(frame: CGRect(x: CGFloat(i)*kScreenWidth/countForBtn, y: 0, width: kScreenWidth/countForBtn, height: 55*kScreenWidth/375))
                btn.tag = 1000 + i
                btn.backgroundColor = UIColor.whiteColor()
                btn.selected = i == self.fruitSelectIndex ? true : false
                btn.setTitleColor(defaultTextColor, forState: .Normal)
                btn.setTitleColor(appThemeColorNew, forState: .Selected)
                btn.setTitle(filters[i], forState: .Normal)
                btn.titleLabel?.font = UIFont.systemFontOfSize(13)
                
                btn.rac_command = RACCommand(signalBlock: { (sender) -> RACSignal! in
                    (sender as! UIButton).selected = !(sender as! UIButton).selected
                    self.fruitSelectIndex = (sender as! UIButton).tag - 1000
                    let orderbys = [(-1,-1),(17,18),(10,11),(0,0)]
                    
                    switch filters[(sender as! UIButton).tag-1000] {
                    case "默认":
                        self.orderby = 0
                    case "交易量":
                        let orderBy = orderbys[btn.tag-1000]
                        self.orderbySalesUp = btn.selected
                        self.orderby = self.orderbySalesUp ? orderBy.0 : orderBy.1
                    case "价格":
                        let orderBy = orderbys[btn.tag-1000]
                        self.orderbyPriceUp = btn.selected
                        self.orderby = self.orderbyPriceUp ? orderBy.0 : orderBy.1
                    default:
                        self.orderby = 1
                    }
                    
                    self.pageIndex = 1
                    self.requestFruitData(self.orderby)

                    return RACSignal.empty()
                })
                
                btn.addSubview(ZMDTool.getLine(CGRect(x: btn.frame.width-1, y: 18*kScreenWidth/375, width: 0.5, height: 20*kScreenWidth/375), backgroundColor: defaultLineColor))
                
                if filters[i] == "交易量" || filters[i] == "价格" {
                    let width = kScreenWidth/countForBtn
                    btn.imageEdgeInsets = UIEdgeInsets(top: 0, left: (width-50)/2 + 40, bottom: 0, right: 0)
                    btn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: (width-50)/2+16)
                    btn.setImage(UIImage(named: "list_price_normal"), forState: .Normal)
                    
//                    if self.fruitSelectIndex == i {
//                        let orderbyArray = [self.orderbySalesUp,self.orderbyPriceUp]
//                        btn.selected = orderbyArray[i-1]
//                        btn.setImage(UIImage(named: "list_price_down"), forState: .Normal)
//                        btn.setImage(UIImage(named: "list_price_up"), forState: .Selected)
//                        btn.setTitleColor(RGB(235,61,61,1.0), forState: .Normal)
//                    } else {
//                        btn.setImage(UIImage(named: "list_price_normal"), forState: .Normal)
//                    }
                }
                
                cell?.contentView.addSubview(btn)
                cell?.addLine()
            }
        }
        for i in 0..<4 {
            let btn = cell?.contentView.viewWithTag(1000+i) as! UIButton
            btn.selected = self.fruitSelectIndex == btn.tag - 1000
            
            if i == 1 || i == 2 {
                if self.fruitSelectIndex == i {
                    let orderbyArray = [self.orderbySalesUp,self.orderbyPriceUp]
                    btn.selected = orderbyArray[i-1]
                    btn.setImage(UIImage(named: "list_price_down"), forState: .Normal)
                    btn.setImage(UIImage(named: "list_price_up"), forState: .Selected)
                    btn.setTitleColor(appThemeColorNew, forState: .Normal)
                } else {
                    btn.setTitleColor(defaultTextColor, forState: .Normal)
                    btn.setImage(UIImage(named: "list_price_normal"), forState: .Normal)
                }
            }
        }
        return cell!
    }
    /// 水果蔬菜详情cell
    func cellForHomeFruitDetail(tableView: UITableView,IndexPath:NSIndexPath)-> UITableViewCell {
        return UITableViewCell()
    }

    //MARK: **************PrivateMethod*************
    //MARK:点击广告的响应方法
    func advertisementClick(advertisement: ZMDAdvertisement){
        if let other1 = advertisement.Other1,let other2 = advertisement.Other2,let linkUrl = advertisement.LinkUrl{
            let other1 = other1 as String
            let other2 = other2 as String   //最终参数
            let linkUrl = linkUrl as String //用于获取临时参数
            switch other1{
            case "Product":
                let vc = HomeBuyGoodsDetailViewController.CreateFromMainStoryboard() as! HomeBuyGoodsDetailViewController
                let arr = linkUrl.componentsSeparatedByString("/")
                vc.hidesBottomBarWhenPushed = true
                vc.productId = (arr[3] as NSString).integerValue
                self.navigationController?.pushViewController(vc, animated: false)
                break
            case "Seckill":
                break
            case "Topic":
                let vc = HomeBuyGoodsDetailViewController.CreateFromMainStoryboard() as! HomeBuyGoodsDetailViewController
                vc.productId = 8803
                vc.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(vc, animated: false)
                break
            case "Coupon":
                break
            default:
                let vc = MyWebViewController()
                vc.webUrl = linkUrl
                vc.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(vc, animated: false)
                break
            }
        } else {
            let linkUrl = advertisement.LinkUrl ?? "" as String
            let id = (linkUrl.stringByReplacingOccurrencesOfString("http://www.ksnongte.com/", withString: "") as NSString).integerValue
            if id != 0 {
                let vc = HomeBuyGoodsDetailViewController.CreateFromMainStoryboard() as! HomeBuyGoodsDetailViewController
                vc.productId = id
                self.pushToViewController(vc, animated: true, hideBottom: false)
            }else if linkUrl != "" {
                let vc = MyWebViewController()
                vc.webUrl = linkUrl
                self.pushToViewController(vc, animated: true, hideBottom: false)
            }
        }
    }
    // 下拉视窗
    class ViewForNextMenu: UIView {
        override init(frame: CGRect) {
            super.init(frame: frame)
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
    }
    
    func updateViewForNextMenu()  {
        let menuTitles = self.categories
        if self.下拉视窗 != nil {
            for subV in self.下拉视窗.subviews {
                subV.removeFromSuperview()
            }
        }
        
        self.下拉视窗 = UIView(frame: CGRect(x: 0, y: -1, width: kScreenWidth, height: 44+150))
        self.下拉视窗.backgroundColor = UIColor.clearColor()
        let topV = UIView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 44))
        topV.backgroundColor = UIColor.whiteColor()
        self.下拉视窗.addSubview(topV)
        let titleLbl = ZMDTool.getLabel(CGRect(x: 16, y: 0, width: 100, height: 44), text: " 选择分类", fontSize: 17)
        topV.addSubview(titleLbl)
        let 上拉 = UIButton(frame: CGRect(x: kScreenWidth - 44, y: 8, width: 44, height: 28))
        上拉.backgroundColor = UIColor.whiteColor()
        上拉.setImage(UIImage(named: "home_up"), forState: .Normal)
        上拉.rac_command = RACCommand(signalBlock: { (sender) -> RACSignal! in
            self.dismissPopupView(self.下拉视窗)
            return RACSignal.empty()
        })
        topV.addSubview(上拉)
        topV.addSubview(ZMDTool.getLine(CGRect(x: kScreenWidth - 44, y: 8, width: 0.5, height: 28)))
        
        var i = 0
        let btnBg = UIView(frame: CGRect(x: 0, y: 44, width: kScreenWidth, height: kScreenWidth * 280/750))
        btnBg.backgroundColor = UIColor(white: 1.0, alpha: 0.9)

        
        self.下拉视窗.addSubview(btnBg)
        for title in menuTitles {
            let width = kScreenWidth/CGFloat(3),height = CGFloat(50)
            let columnIndex  = i%3
            let rowIndex = i/3
            let x = CGFloat(columnIndex) * width ,y  = CGFloat(rowIndex)*50
            i++
            
            let menuBtn = UIButton(frame: CGRect(x: x, y: y, width: width, height: height))
            menuBtn.backgroundColor = UIColor.clearColor()
            menuBtn.setTitle((title as! ZMDCategory).Name, forState: .Normal)
            menuBtn.titleLabel?.font = defaultDetailTextSize
            menuBtn.setTitleColor(defaultTextColor, forState: .Normal)
            menuBtn.setTitleColor(defaultSelectColor, forState: .Selected)
            menuBtn.tag = 1000 + i
            menuBtn.rac_signalForControlEvents(.TouchUpInside).subscribeNext({ (sender) -> Void in
                let category = menuTitles[sender.tag - 1001] as! ZMDCategory
                let homeBuyListViewController = HomeBuyListViewController.CreateFromMainStoryboard() as! HomeBuyListViewController
                homeBuyListViewController.Cid = category.Id.stringValue
                homeBuyListViewController.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(homeBuyListViewController, animated: true)
            })
            btnBg.addSubview(menuBtn)
            ZMDTool.configViewLayerFrameWithColor(menuBtn, color: UIColor.whiteColor())
        }
    }
    
    func fetchNewProucts(){
        QNNetworkTool.fetchNewProduct { (products, dictionary, error) in
            if let products = products {
                self.history.removeAllObjects()
                self.history.addObjectsFromArray(products as [AnyObject])
                self.currentTableView.reloadData()
            }else{
                ZMDTool.showErrorPromptView(nil, error: error)
            }
        }
    }
    
    func fetchData(){
        QNNetworkTool.categories { (categories, error, dictionary) -> Void in
            if let categories = categories {
                self.categories.removeAllObjects()
                self.categories.addObjectsFromArray(categories as [AnyObject])

                self.currentTableView.reloadData()
            } else {
                ZMDTool.showErrorPromptView(nil, error: error)
            }
        }
        
        //获取浏览历史
        /*QNNetworkTool.fetchCustomerHistory { (history, dictionary, error) in
            if let history = history {
                self.history.removeAllObjects()
                self.history.addObjectsFromArray(history as [AnyObject])
                
                if self.history.count == 0 {
                    self.fetchNewProucts()
                    return
                }
                self.currentTableView.reloadData()
            }
        }*/
        
        QNNetworkTool.fetchMainPageInto { (advertisementAll, error, dictionary) -> Void in
            if advertisementAll != nil {
                self.advertisementAll = advertisementAll
                self.currentTableView.reloadData()
            }
        }
    }
    
    func requestFruitData(orderby:Int) {
        //...请求数据
//        self.currentTableView.reloadSections(NSIndexSet(index: 5), withRowAnimation: .None)
        self.currentTableView.reloadData()
    }
    
    private func dataInit(){
        self.menuType = [.kFeature,.kECommerce,.kSupply,.kDemand,.kEnterprise]
    }
    
    func updateUI() {
        self.currentTableView.backgroundColor = tableViewdefaultBackgroundColor
        self.viewForSearch()
        self.configRightItem()
    }
    
    //MAKR: 搜索View
    func viewForSearch() {
        self.textInput = UITextField(frame: CGRect(x: 12*kScreenWidth/375, y: 32*kScreenWidth/375, width: kScreenWidth*296/375, height: 34*kScreenWidth/375))
        self.textInput.placeholder = " 搜索你想要的"
        self.textInput.backgroundColor = RGB(223,223,223,1.0)
        self.textInput.alpha = 0.9
        self.textInput.layer.cornerRadius = 2
        self.textInput.layer.masksToBounds = true
        self.textInput.delegate = self
        
        let leftViewBtn = UIButton(frame: CGRect(x: 0, y: 4*kScreenWidth/375, width: 60*kScreenWidth/375, height: 36*kScreenWidth/375))
        leftViewBtn.backgroundColor = RGB(253,124,76,1.0)
        leftViewBtn.alpha = 1.0
        leftViewBtn.setImage(UIImage(named: "storeList_down"), forState: .Normal)
        leftViewBtn.setTitle("供应", forState: .Normal)
        leftViewBtn.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        leftViewBtn.titleLabel?.font = UIFont.systemFontOfSize(15)
        leftViewBtn.imageEdgeInsets = UIEdgeInsets(top: 2, left: 38*kScreenWidth/375, bottom: 0, right: -38*kScreenWidth/375)
        leftViewBtn.titleEdgeInsets = UIEdgeInsets(top: 0, left: -12*kScreenWidth/375, bottom: 0, right: 12*kScreenWidth/375)
        leftViewBtn.rac_command = RACCommand(signalBlock: { (sender) -> RACSignal! in
            (sender as!UIButton).selected = !(sender as!UIButton).selected
            self.view.endEditing(true)
            self.textInput.resignFirstResponder()
            let selectView = UIView(frame: CGRect(x: 12*kScreenWidth/375, y: 32*kScreenWidth/375, width: 60*kScreenWidth/375, height: 36*4*kScreenWidth/375))
            selectView.backgroundColor = RGB(253,124,76,1.0)
            selectView.alpha = 1.0
            ZMDTool.configViewLayer(selectView)
            for i in 0..<self.searchType.count {
                let title = self.searchType[i]
                let btn = UIButton(frame: CGRect(x: 0, y: 36*CGFloat(i)*kScreenWidth/375, width: 60*kScreenWidth/375, height: 36*kScreenWidth/375))
                btn.setTitle(title, forState: .Normal)
                btn.setTitleColor(UIColor.whiteColor(), forState: .Normal)
                btn.titleLabel?.font = UIFont.systemFontOfSize(15)
                btn.backgroundColor = UIColor.clearColor()
                btn.addSubview(ZMDTool.getLine(CGRect(x: 0, y: btn.frame.height-0.5, width: btn.frame.width, height: 0.5), backgroundColor: UIColor.whiteColor()))
                btn.rac_command = RACCommand(signalBlock: { (sender) -> RACSignal! in
                    selectView.removeFromSuperview()
                    leftViewBtn.setTitle((sender as! UIButton).titleLabel?.text, forState: .Normal)
                    return RACSignal.empty()
                })
                selectView.addSubview(btn)
            }
            selectView.showAsPop(setBgColor: false)
            return RACSignal.empty()
        })
        
        leftViewBtn.contentMode = UIViewContentMode.ScaleAspectFit
        self.textInput.leftView = leftViewBtn
        self.textInput.leftViewMode = .Always
        ZMDTool.configViewLayer(self.textInput)
        self.currentTableView.addSubview(self.textInput)
    }
    
    //MAKR: UINavigationRightItem
    func configRightItem() {
        let rightBtn = UIButton(frame: CGRect(x: 326, y: 32*kScreenWidth/375, width: 35, height: 35))
        let image = UIImage(named: "home_page_alock")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        rightBtn.setImage(image, forState: .Normal)
        rightBtn.rac_command = RACCommand(signalBlock: { (input) -> RACSignal! in
            let vc = MsgHomeViewController()
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: false)
            return RACSignal.empty()
        })
        self.view.addSubview(rightBtn)
    }
    
    
    //MARK:设置导航栏透明
    // MARK:配置navigationBar透明与否
    func getBackView(superView : UIView) {
        let backString = SYSTEM_VERSION_FLOAT >= 10.0 ? "_UIBarBackground" : "_UINavigationBarBackground"
        if superView.isKindOfClass(NSClassFromString(backString)!) {
            for view in superView.subviews {
                //移除分割线
                if view.isKindOfClass(UIImageView.classForCoder()) {
                    self.navLine = view
                    self.navLine.hidden = true
                }
            }
            self.navBackView = superView
            self.navBackView.alpha = 0
            self.navBackView.backgroundColor = navigationBackgroundColor
        } else if superView.isKindOfClass(NSClassFromString("_UIBackdropView")!) {
            superView.hidden = true
        }
        for view in superView.subviews {
            self.getBackView(view)
        }
    }
}
