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
    
    let specialHeights : [String:CGFloat] = ["supplyDetailCell":324,"fruitDetailCell":100]
    
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
            case .HomeContentTypeFruitDetail:
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
                return kScreenWidth * 80 / 750
                
                //******MiniAdSection********
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
                return UIImage(named: "01nongte")
            case .kECommerce:
                return UIImage(named: "02kacunwang")
            case .kSupply:
                return UIImage(named: "03gongying")
            case .kDemand:
                return UIImage(named: "04qiugou")
            case .kEnterprise:
                return UIImage(named: "05qiye")
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
                (viewController as! SupplyDemandListViewController).type = 1
                viewController.hidesBottomBarWhenPushed = true
            case .kDemand:
                viewController = SupplyDemandListViewController.CreateFromMainStoryboard() as! SupplyDemandListViewController
                (viewController as! SupplyDemandListViewController).type = 2
                viewController.hidesBottomBarWhenPushed = true
            case .kEnterprise:
                viewController = EnterpirseListViewController.CreateFromMainStoryboard() as! EnterpirseListViewController
                viewController.hidesBottomBarWhenPushed = true
            }
            viewController.title = self.title
            return viewController
        }
        
        //点击菜单选择，调用方法跳转
        func didSelect(navViewController:UINavigationController){
            navViewController.pushViewController(self.pushViewController, animated: false)
        }
    }
    
    //搜索时的类型枚举
    enum SearchType {
        case kSupply
        case kDemand
        case kGood
        case kStore
        
        init() {
            self = kSupply
        }
        
        var title : String {
            switch self {
            case .kSupply:
                return "供应"
            case .kDemand:
                return "求购"
            case .kGood:
                return "商品"
            case .kStore:
                return "店家"
            }
        }
        
        var targetVC : UIViewController {
            let viewController : UIViewController
            switch self {
            case .kGood:
                viewController = HomeBuyListViewController.CreateFromMainStoryboard() as! HomeBuyListViewController
            case .kStore:
                viewController = StoreShowListViewController.CreateFromMainStoryboard() as! StoreShowListViewController
            default :
                viewController = SupplyDemandListViewController.CreateFromMainStoryboard() as! SupplyDemandListViewController
            }
            return viewController
        }
    }
    
    @IBOutlet weak var currentTableView: UITableView!
    
    var userCenterData = [[UserCenterCellType.HomeContentTypeAd],[.HomeContentTypeMenu,.HomeContentTypeState],[.HomeContentTypeDoubleGood,.HomeContentTypeMulityGood/*,.HomeContentTypeRecommend*/],[.HomeContentTypeSupplyHead,.HomeContentTypeSupplyDetail,.HomeContentTypeSupplyFoot]]
    
    var searchTypes : [SearchType]!
    var searchType : SearchType = .kGood
    var timer : NSTimer!
    var selectView : UIView!    //搜索下拉View
    let topAdName = "mb_index_top_banner"          //顶部轮播图广告名
    
    var fruitSelectIndex = 0       //水果蔬菜section 删选按钮选中记录
    var orderbySalesUp = true      //水果蔬菜section 按销量排序
    var orderbyPriceUp = true      //水果蔬菜section 按价格排序
    var orderby = 0                //水果蔬菜section 数据请求的排序方式
    var pageIndex = 1              //水果蔬菜section 数据请求页数
    
    var menuType: [MenuType]!
    var 下拉视窗 : UIView!
    var categories = NSMutableArray()
    var advertisementAll : ZMDAdvertisementAll! //top、icon、guess、topic。。。
    var textInput: UITextField!
    
    var topAdArray = NSMutableArray()   //顶部轮播图
    var menus = NSMutableArray() //menuCell部分临时数据，
    var dongTaiIndex = 0    //用于取得交易动态当前动态
    var dongTaiArray = NSMutableArray()    //交易动态
    var enterpriseArray = NSMutableArray() //5个企业部分
    var miniProductsArray = NSMutableArray()//5个商品
    var recommendArray = NSMutableArray()   //推荐部分
    var supplyDemandArray = NSMutableArray()    //供求大厅
    var supplyType = 1  //1为供应、2为求购
    var productsArray = NSMutableArray() //水果蔬菜
    var friutIndex = 0      //记录水果蔬菜index
    
    var navBackView : UIView!
    var navLine : UIView!
    
    var networkObserver : Reachability!
    
    //MARK: - LifeCircle
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
        if let timer = self.timer {
            timer.fireDate = NSDate.distantPast()
        }
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(true)
        APP_LAUNCHEDTIME = APP_LAUNCHEDTIME + 1
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        if let selectView = self.selectView {
            selectView.removeFromSuperview()
        }
        if let timer = self.timer {
            timer.fireDate = NSDate.distantFuture()
        }
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
        let cellType = self.userCenterData[section][0]
        if cellType == .HomeContentTypeFruitDetail {
            return self.productsArray.count
//            return self.productsArray.count == 0 ? 0 : self.productsArray[self.friutIndex].count
        }
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
        if self.userCenterData[indexPath.section][0] == .HomeContentTypeFruitDetail {
            return self.specialHeights["fruitDetailCell"]!
        }
        let cellType = self.userCenterData[indexPath.section][indexPath.row]
        //使用AutoMenuCell时的高度
        if cellType == .HomeContentTypeMenu {
            return self.menus.count > 5 ? zoom(235) : zoom(124)
        }
        if cellType == .HomeContentTypeSupplyDetail {
            return self.supplyDemandArray.count == 0 ? 0 : CGFloat(self.supplyDemandArray.count)*38+20
        }
        return cellType.height
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if self.userCenterData[indexPath.section][0] == .HomeContentTypeFruitDetail {
            return self.cellForHomeFruitDetail(tableView, indexPath: indexPath)
        }
        switch  self.userCenterData[indexPath.section][indexPath.row] {
        case .HomeContentTypeAd :
            return self.cellForHomeAd(tableView, indexPath: indexPath)
        case .HomeContentTypeMenu :
            return self.cellForHomeAutoMenu(tableView, indexPath: indexPath)
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
            return self.cellForHomeFruitDetail(tableView, indexPath: indexPath)
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //点击底部商品cell
        if self.userCenterData[indexPath.section][0] == .HomeContentTypeFruitDetail {
            let product = self.productsArray[indexPath.row] as! ZMDProduct
            let vc = HomeBuyGoodsDetailViewController.CreateFromMainStoryboard() as! HomeBuyGoodsDetailViewController
            vc.productId = product.Id.integerValue
            self.pushToViewController(vc, animated: true, hideBottom: true)
            return
        }
        let cellType = self.userCenterData[indexPath.section][indexPath.row]
        if cellType == .HomeContentTypeState && self.dongTaiArray.count != 0 {
            let tradeProduct = self.dongTaiArray[self.dongTaiIndex] as! ZMDTradeProduct
            let vc = HomeBuyGoodsDetailViewController.CreateFromMainStoryboard() as! HomeBuyGoodsDetailViewController
            vc.productId = tradeProduct.ProductId.integerValue
            self.pushToViewController(vc, animated: true, hideBottom: true)
        }
    }
    
    //MARK: ***************代理方法*************
    //MARK: ScrollViewDelegate
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let rightBtn = self.view.viewWithTag(666)
        if scrollView == self.currentTableView {
            rightBtn?.hidden = scrollView.contentOffset.y > 64 ? true : false
        }
    }
    
    //MARK: TextFieldDelegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        if let text = textField.text {
            self.view.viewWithTag(100)?.removeFromSuperview()
            let viewController = self.searchType.targetVC
            switch self.searchType {
            case .kGood:
                (viewController as! HomeBuyListViewController).titleForFilter = text
            case .kStore:
                (viewController as! StoreShowListViewController).titleForFilter = text
            case .kSupply:
                (viewController as! SupplyDemandListViewController).type = 1
                (viewController as! SupplyDemandListViewController).q = text
                (viewController as! SupplyDemandListViewController).check = 2
            case .kDemand :
                (viewController as! SupplyDemandListViewController).type = 2
                (viewController as! SupplyDemandListViewController).q = text
                (viewController as! SupplyDemandListViewController).check = 2
            }
            self.pushToViewController(viewController, animated: true, hideBottom: true)
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
        if self.topAdArray.count != 0 {
            if let advertisement = self.topAdArray[index] as? ZMDAdvertisement {
                self.advertisementClick(advertisement)
            }
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
    //MARK: - ****************TableViewCell****************
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
        
        for id in self.topAdArray {
            let advertisement = id as! ZMDAdvertisement
            var url = kImageAddressMain+advertisement.ResourcesCDNPath!
            if advertisement.ResourcesCDNPath!.hasPrefix("http") {
                url = advertisement.ResourcesCDNPath!
            }
            url = url.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
            imgUrls.addObject(NSURL(string: url)!)
            if imgUrls.count != 0 {
                cycleScroll.urlArray = imgUrls as [AnyObject]
            }
        }
        cell?.addSubview(cycleScroll)
        return cell!
    }
    
    //MARK: cellFor菜单section
    /// 广告形式自适应个数MenuCell
    func cellForHomeAutoMenu(tableView:UITableView, indexPath: NSIndexPath) -> UITableViewCell {
        let cellId = "AutoMenuCell"
        var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
        if cell == nil {
            cell = UITableViewCell(style: .Default, reuseIdentifier: cellId)
            ZMDTool.configTableViewCellDefault(cell!)
        }
        for subView in cell!.contentView.subviews {
            subView.removeFromSuperview()
        }
        
        for var i=0;i<self.menus.count;i++ {
            let ad = self.menus[i] as! ZMDAdvertisement
            let btnHeight = zoom(124)
            let btnWidth = self.menus.count >= 5 ? kScreenWidth/5 : kScreenWidth/CGFloat(self.menus.count)
            let btnX = CGFloat(i%5)*btnWidth
            let btnY = i >= 5 ? zoom(110) : 0
            let btn = UIButton(frame: CGRect(x: btnX, y: btnY, width: btnWidth, height: btnHeight))
            btn.tag = 10000 + i
            btn.rac_command = RACCommand(signalBlock: { (sender) -> RACSignal! in
                self.advertisementClick(ad)
                return RACSignal.empty()
            })
            btn.backgroundColor = UIColor.whiteColor()
            
            let label = UILabel(frame: CGRectMake(0, zoom(90), btnWidth, zoom(14)))
            label.font = UIFont.systemFontOfSize(14)
            label.textColor = defaultTextColor
            label.textAlignment =  .Center
            label.tag = 10010 + i
            label.text = ad.Title
            btn.addSubview(label)
            
            let imgV = UIImageView(frame: CGRectMake(btnWidth/2-zoom(28.5), zoom(20), zoom(57),zoom(57)))
            imgV.tag = 10020 + i
            imgV.sd_setImageWithURL(NSURL(string: kImageAddressMain+ad.ResourcesCDNPath!))
            btn.addSubview(imgV)
            cell!.contentView.addSubview(btn)
        }
        cell?.addLine()
        return cell!
    }
    
    /// 交易动态cell
    func changeDongTai() {
        if self.dongTaiArray.count == 0 {
            return
        }
        self.dongTaiIndex = (self.dongTaiIndex+1)%self.dongTaiArray.count
        let product = self.dongTaiArray[self.dongTaiIndex] as! ZMDTradeProduct
        if let cell = self.currentTableView.cellForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 1)) {
            let detailLbl = cell.contentView.viewWithTag(10000) as! UILabel
            UIView.animateWithDuration(1) { () -> Void in
                detailLbl.text = product.ProductName + "  " + "\(product.Quantity)\(product.QuantityUnit)"
                detailLbl.textColor = defaultTextColor
            }
        }
    }
    func cellForHomeState(tableView: UITableView,IndexPath:NSIndexPath)-> UITableViewCell {
        //cellHeight = 40
        let cellId = "stateCell"
        var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
        if cell == nil {
            cell = UITableViewCell(style: .Default, reuseIdentifier: cellId)
            ZMDTool.configTableViewCellDefault(cell!)
            cell?.accessoryType = .DisclosureIndicator
            cell?.selectionStyle = .None
            
            let imgView = UIImageView(frame: CGRect(x: zoom(10), y: zoom(8), width: zoom(68), height: zoom(22)))
            imgView.image = UIImage(named: "交易动态")
            cell?.contentView.addSubview(imgView)
            
            let text2 = "[xj**12] 新疆吐鲁番无核白葡萄 8吨"
            let detailLbl = ZMDTool.getLabel(CGRect(x: zoom(10+68+10), y: 10*kScreenWidth/375, width: kScreenWidth-zoom((10+68+10)+20), height: zoom(14)), text: text2, fontSize: 12, textColor: UIColor.whiteColor(), textAlignment: .Left)
            detailLbl.tag = 10000
            detailLbl.attributedText = text2.AttributedMutableText(["[xj**12]","新疆吐鲁番无核白葡萄 8吨"], colors: [appThemeColorNew,defaultTextColor])
            cell?.contentView.addSubview(detailLbl)
            imgView.set("cy", value: zoom(20))
            detailLbl.set("cy", value: zoom(20))
        }
        
        return cell!
    }
    
    //MARK: cellFor商品section
    ///商品DoubleGoodCell
    func cellForHomeDoubleGood(tableView: UITableView,IndexPath:NSIndexPath)-> UITableViewCell {
        //cellHeight = 98
        let cellId = "doubleGoodCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellId) as! HomeDoubleGoodCell
        ZMDTool.configTableViewCellDefault(cell)
        cell.addLine()
        HomeDoubleGoodCell.configCell(cell, datas: self.miniProductsArray)
        if self.miniProductsArray.count > 1 {
            for i in 0..<2 {
                cell.btns[i].rac_command = RACCommand(signalBlock: { (sender) -> RACSignal! in
                    self.advertisementClick(self.miniProductsArray[i] as! ZMDAdvertisement)
                    //                    let vc = EnterpriseDetailViewController.CreateFromMainStoryboard() as! EnterpriseDetailViewController
                    //                    vc.enterpriseId = (self.enterpriseArray[i] as! ZMDEnterprise).Id.integerValue
                    //                    self.pushToViewController(vc, animated: true, hideBottom: true)
                    
                    //                    let vc = HomeBuyGoodsDetailViewController.CreateFromMainStoryboard() as! HomeBuyGoodsDetailViewController
                    //                    vc.productId = (self.miniProductsArray[i] as! ZMDAdvertisement).Id.integerValue
                    //                    self.pushToViewController(vc, animated: true, hideBottom: true)
                    return RACSignal.empty()
                })
            }
        }
        return cell
    }
    ///商品MulityGoodCell
    func cellForHomeMulityGood(tableView: UITableView,IndexPath:NSIndexPath)-> UITableViewCell {
        //cellHeigth = 110
        let cellId = "multiGoodCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellId) as! HomeMultiGoodCell
        cell.addLine()
        ZMDTool.configTableViewCellDefault(cell)
        HomeMultiGoodCell.configCell(cell, datas: self.miniProductsArray)
        if self.miniProductsArray.count > 4 {
            for i in 2..<5 {
                cell.btns[i-2].rac_command = RACCommand(signalBlock: { (sender) -> RACSignal! in
                    self.advertisementClick(self.miniProductsArray[i] as! ZMDAdvertisement)
                    //                    let vc = EnterpriseDetailViewController.CreateFromMainStoryboard() as! EnterpriseDetailViewController
                    //                    vc.enterpriseId = (self.enterpriseArray[i] as! ZMDEnterprise).Id.integerValue
                    //                    self.pushToViewController(vc, animated: true, hideBottom: true)
                    
                    //                    let vc = HomeBuyGoodsDetailViewController.CreateFromMainStoryboard() as! HomeBuyGoodsDetailViewController
                    //                    vc.productId = (self.miniProductsArray[i] as! ZMDAdvertisement).Id.integerValue
                    //                    self.pushToViewController(vc, animated: true, hideBottom: true)
                    return RACSignal.empty()
                })
            }
        }
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
            
            for i in 0..<5 {
                let width = 210*kScreenWidth/375
                let view = NSBundle.mainBundle().loadNibNamed("CommentView", owner: nil, options: nil)[1] as! RecommendView
                view.frame = CGRect(x: CGFloat(i)*width, y: 0, width: width, height: 70*kScreenWidth/375)
                view.tag = 20001 + i
                scrollView.addSubview(view)
            }
        }
        let scrollView = cell?.contentView.viewWithTag(10000) as! UIScrollView
        if self.enterpriseArray.count == 0 {
            return cell!
        }
        let count = self.enterpriseArray.count/2+self.enterpriseArray.count%2
        scrollView.contentSize = CGSizeMake(CGFloat(count)*210*kScreenWidth/375, 0)
        for i in 0..<count {
            let enterprise = self.enterpriseArray[i*2] as! ZMDEnterprise
            let view = scrollView.viewWithTag(20001+i) as! RecommendView
            view.topLbl.text = "推荐 "+enterprise.Name
            view.topLbl.attributedText = view.topLbl.text?.AttributedMutableText(["推荐"], colors: [appThemeColorNew])
            view.topBtn.rac_command = RACCommand(signalBlock: { (sender) -> RACSignal! in
                let vc = EnterpriseDetailViewController.CreateFromMainStoryboard() as! EnterpriseDetailViewController
                vc.enterpriseId = enterprise.Id.integerValue
                self.pushToViewController(vc, animated: true, hideBottom: true)
                return RACSignal.empty()
            })
            
            if 2*i+1 <= count {
                let enterprise2 = self.enterpriseArray[2*i+1] as! ZMDEnterprise
                view.botLbl.text = "推荐 "+enterprise2.Name
                view.botLbl.attributedText = view.botLbl.text?.AttributedMutableText(["推荐"], colors: [appThemeColorNew])
                view.botBtn.rac_command = RACCommand(signalBlock: { (sender) -> RACSignal! in
                    let vc = EnterpriseDetailViewController.CreateFromMainStoryboard() as! EnterpriseDetailViewController
                    vc.enterpriseId = enterprise2.Id.integerValue
                    self.pushToViewController(vc, animated: true, hideBottom: true)
                    return RACSignal.empty()
                })
            }
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
                var url = kImageAddressMain + (id.ResourcesCDNPath ?? "")
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
                self.supplyType = index + 1
                self.fetchSupplyDemand()
            }
            cell?.contentView.addSubview(customJumpBtn)
        }
        return cell!
    }
    /// 供求Listcell
    func cellForHomeSupplyDetail(tableView: UITableView,IndexPath:NSIndexPath)-> UITableViewCell {
        let cellId = "supplyDetailCell"
        var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
        if cell == nil {
            cell = UITableViewCell(style: .Default, reuseIdentifier: cellId)
            ZMDTool.configTableViewCellDefault(cell!)
            cell!.addLine()
            
            for i in 0..<self.supplyDemandArray.count {
                let view = UIView(frame: CGRect(x: 0, y: 10+CGFloat(i)*(38), width: kScreenWidth, height: 38))
                let leftLbl = ZMDTool.getLabel(CGRect(x: 10, y: 10, width: kScreenWidth-64, height: 18), text: "", fontSize: 16, textColor: defaultTextColor, textAlignment: .Left)
                let rightLbl = ZMDTool.getLabel(CGRect(x: kScreenWidth-64, y: 10, width: 53, height: 18), text: "", fontSize: 13, textColor: defaultDetailTextColor, textAlignment: .Right)
                let btn = ZMDTool.getButton(CGRect(x: 0, y: 0, width: kScreenWidth, height: 38), textForNormal: "", fontSize: 1, backgroundColor: UIColor.clearColor(), blockForCli: { (sender) -> Void in
                    //...
                })
                leftLbl.tag = 10000
                rightLbl.tag = 10001
                btn.tag = 10002
                view.addSubview(leftLbl)
                view.addSubview(rightLbl)
                view.addSubview(btn)
                view.tag = 20000+i
                cell?.contentView.addSubview(view)
            }
        }
        var index = -1
        for item in self.supplyDemandArray {
            let supplyItem = item as! ZMDSupplyProduct
            index = index + 1
            if let view = cell?.contentView.viewWithTag(20000+index) {
                let leftLbl = view.viewWithTag(10000) as! UILabel
                let rightLbl = view.viewWithTag(10001) as! UILabel
                let btn = view.viewWithTag(10002) as! UIButton
                let typeText = self.supplyType == 1 ? "供应" : "求购"
                leftLbl.text = typeText + "  " + supplyItem.Title
                leftLbl.attributedText = leftLbl.text?.AttributedText(typeText, color: appThemeColor)
                if let arr = supplyItem.CreatedOn.componentsSeparatedByCharactersInSet(NSCharacterSet(charactersInString: "T:")) as? NSArray where arr.count == 4 {
                    let time = (arr[1] as! String) + ":" + (arr[2] as! String)
                    rightLbl.text = time
                }
                btn.rac_command = RACCommand(signalBlock: { (sender) -> RACSignal! in
                    let vc = SupplyDemandDetailViewController.CreateFromMainStoryboard() as! SupplyDemandDetailViewController
                    vc.type = self.supplyType
                    vc.supplyProductId = supplyItem.Id.integerValue
                    self.pushToViewController(vc, animated: true, hideBottom: true)
                    return RACSignal.empty()
                })
            }
        }
        return cell!
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
                let vc = SupplyDemandListViewController.CreateFromMainStoryboard() as! SupplyDemandListViewController
                vc.type = self.supplyType
                self.pushToViewController(vc, animated: true, hideBottom: true)
            })
            btn.setImage(UIImage(named: "view-all"), forState: .Normal)
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
            let titles = NSMutableArray()
            for category in self.categories {
                titles.addObject((category as! ZMDXHYCategory).Name)
            }
            let customJumpBtn = CustomJumpBtns(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 44*kScreenWidth/375), menuTitle: titles as! [String], textColorForNormal: defaultTextColor, textColorForSelect: appThemeColorNew, IsLineAdaptText: true)
            customJumpBtn.finished = {(index:Int) -> Void in
                self.friutIndex = index
                self.fetchProductsAtIndex()
//                                    self.userCenterData = self.enterpriseArray.count == 0 ? [[UserCenterCellType.HomeContentTypeAd],[.HomeContentTypeMenu,.HomeContentTypeState],[.HomeContentTypeDoubleGood,.HomeContentTypeMulityGood/*,.HomeContentTypeRecommend*/],[.HomeContentTypeSupplyHead,.HomeContentTypeSupplyDetail,.HomeContentTypeSupplyFoot],[.HomeContentTypeFruitHead],[.HomeContentTypeFruitDetail]] : [[UserCenterCellType.HomeContentTypeAd],[.HomeContentTypeMenu,.HomeContentTypeState],[.HomeContentTypeDoubleGood,.HomeContentTypeMulityGood,.HomeContentTypeRecommend],[.HomeContentTypeSupplyHead,.HomeContentTypeSupplyDetail,.HomeContentTypeSupplyFoot],[.HomeContentTypeFruitHead],[.HomeContentTypeFruitDetail]]
//                self.currentTableView.reloadSections(NSIndexSet(index: 5), withRowAnimation: .None)
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
    func cellForHomeFruitDetail(tableView: UITableView,indexPath:NSIndexPath)-> UITableViewCell {
        let cellId = "fruitDetailCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellId)
        cell?.addLine()
        ZMDTool.configTableViewCellDefault(cell!)
        let product = self.productsArray[indexPath.row] as! ZMDProduct
//        let product = self.productsArray[self.friutIndex][indexPath.row] as! ZMDProduct
        let imgView = cell?.contentView.viewWithTag(10000) as! UIImageView
        let titleLbl = cell?.contentView.viewWithTag(10001) as! UILabel
        let priceLbl = cell?.contentView.viewWithTag(10002) as! UILabel
        imgView.sd_setImageWithURL(NSURL(string: kImageAddressMain+(product.DefaultPictureModel?.ImageUrl)!), placeholderImage: nil)
        titleLbl.text = product.Name
        priceLbl.text = (product.ProductPrice?.Price)!
        return cell!
    }
    
    //MARK: **************PrivateMethod*************
    //MARK:点击广告的响应方法
    func advertisementClick(advertisement: ZMDAdvertisement){
        if let other1 = advertisement.Other1, let other2 = advertisement.Other2 {
            let other1 = other1 as String
            let other2 = other2   //最终参数
            switch other1{
            case "Product":
                let vc = HomeBuyGoodsDetailViewController.CreateFromMainStoryboard() as! HomeBuyGoodsDetailViewController
                vc.productId = (other2 as NSString).integerValue
                self.pushToViewController(vc, animated: true, hideBottom: true)
                break
            case "Seckill":
                break
            case "Topic":
                let vc = HomeBuyListViewController.CreateFromMainStoryboard() as! HomeBuyListViewController
                vc.Cid = other2
                vc.As = "true"
                vc.title = advertisement.Title ?? ""
                self.pushToViewController(vc, animated: true, hideBottom: true)
                break
            case "Supply":
                let vc = SupplyDemandListViewController.CreateFromMainStoryboard() as! SupplyDemandListViewController
                vc.type = 1
                vc.check = 2
                self.pushToViewController(vc, animated: true, hideBottom: true)
            case "Demand":
                let vc = SupplyDemandListViewController.CreateFromMainStoryboard() as! SupplyDemandListViewController
                vc.type = 2
                vc.check = 2
                self.pushToViewController(vc, animated: true, hideBottom: true)
            case "EnterpriseList":
                let vc = EnterpirseListViewController.CreateFromMainStoryboard() as! EnterpirseListViewController
                self.pushToViewController(vc, animated: true, hideBottom: true)
            case "EnterpriseDetail":
                let vc = EnterpriseDetailViewController.CreateFromMainStoryboard() as! EnterpriseDetailViewController
                vc.enterpriseId = (other2 as NSString).integerValue
                self.pushToViewController(vc, animated: true, hideBottom: true)
            case "Web":
                let vc = MyWebViewController()
                vc.webUrl = other2
                self.pushToViewController(vc, animated: true, hideBottom: true)
            case "App":
                if UIApplication.sharedApplication().canOpenURL(NSURL(string: other2)!) {
                    UIApplication.sharedApplication().openURL(NSURL(string: other2)!)
                }
            case "Coupon":
                break
            default:
                break
            }
        }else{
            return
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
    
    //MARK: NetWork
    func getCache() {
        if let topDatas = HYNetworkCache.cacheJsonWithURL("MiniAd\(self.topAdName)"),ads = ZMDAdvertisement.mj_objectArrayWithKeyValuesArray(topDatas) {
            self.topAdArray.removeAllObjects()
            self.topAdArray.addObjectsFromArray(ads as [AnyObject])
            self.currentTableView.reloadData()
        }
        if let daoHangsData = HYNetworkCache.cacheJsonWithURL("MiniAdmbdz_index_nav"),arr = ZMDAdvertisement.mj_objectArrayWithKeyValuesArray(daoHangsData) {
            self.menus.removeAllObjects()
            self.menus.addObjectsFromArray(arr as [AnyObject])
            self.currentTableView.reloadData()
        }
        if let dongTaiDatas = HYNetworkCache.cacheJsonWithURL("HomeDongTai"),arr = ZMDTradeProduct.mj_objectArrayWithKeyValuesArray(dongTaiDatas) {
            self.dongTaiArray.removeAllObjects()
            self.dongTaiArray.addObjectsFromArray(arr as [AnyObject])
            self.currentTableView.reloadData()
        }
        if let topFiveDatas = HYNetworkCache.cacheJsonWithURL("MiniAdcompany_top_five"),ads = ZMDAdvertisement.mj_objectArrayWithKeyValuesArray(topFiveDatas) {
            self.miniProductsArray.removeAllObjects()
            self.miniProductsArray.addObjectsFromArray(ads as [AnyObject])
            self.currentTableView.reloadData()
        }
        if let enterpriseDatas = HYNetworkCache.cacheJsonWithURL("HomeEnterprise"),arr = ZMDEnterprise.mj_objectArrayWithKeyValuesArray(enterpriseDatas) {
            self.enterpriseArray.removeAllObjects()
            self.enterpriseArray.addObjectsFromArray(arr as [AnyObject])
            self.userCenterData = [[UserCenterCellType.HomeContentTypeAd],[.HomeContentTypeMenu,.HomeContentTypeState],[.HomeContentTypeDoubleGood,.HomeContentTypeMulityGood,.HomeContentTypeRecommend],[.HomeContentTypeSupplyHead,.HomeContentTypeSupplyDetail,.HomeContentTypeSupplyFoot]]
            self.currentTableView.reloadData()
        }
        if let supplyDemandDatas = HYNetworkCache.cacheJsonWithURL("HomeSupplyDemand\(self.supplyType)"),supplys = ZMDSupplyProduct.mj_objectArrayWithKeyValuesArray(supplyDemandDatas) {
            self.supplyDemandArray.removeAllObjects()
            self.supplyDemandArray.addObjectsFromArray(supplys as [AnyObject])
            self.currentTableView.reloadData()
        }
        if let mainCategoriesData = HYNetworkCache.cacheJsonWithURL("MainCategories"),categories = ZMDXHYCategory.mj_objectArrayWithKeyValuesArray(mainCategoriesData) {
            self.categories.removeAllObjects()
            self.categories.addObjectsFromArray(categories as [AnyObject])
            self.currentTableView.reloadData()
            self.userCenterData = self.enterpriseArray.count == 0 ? [[UserCenterCellType.HomeContentTypeAd],[.HomeContentTypeMenu,.HomeContentTypeState],[.HomeContentTypeDoubleGood,.HomeContentTypeMulityGood/*,.HomeContentTypeRecommend*/],[.HomeContentTypeSupplyHead,.HomeContentTypeSupplyDetail,.HomeContentTypeSupplyFoot],[.HomeContentTypeFruitHead],[.HomeContentTypeFruitDetail]] : [[UserCenterCellType.HomeContentTypeAd],[.HomeContentTypeMenu,.HomeContentTypeState],[.HomeContentTypeDoubleGood,.HomeContentTypeMulityGood,.HomeContentTypeRecommend],[.HomeContentTypeSupplyHead,.HomeContentTypeSupplyDetail,.HomeContentTypeSupplyFoot],[.HomeContentTypeFruitHead],[.HomeContentTypeFruitDetail]]
            self.productsArray.removeAllObjects()
            self.currentTableView.reloadData()
            for item in categories {
                let category = item as! ZMDXHYCategory
                if let productsData = HYNetworkCache.cacheJsonWithURL("ProductsInCategory\(category.Id)"),arr = ZMDProduct.mj_objectArrayWithKeyValuesArray(productsData) {
                    self.productsArray.addObject(arr)
                    self.userCenterData = self.enterpriseArray.count == 0 ? [[UserCenterCellType.HomeContentTypeAd],[.HomeContentTypeMenu,.HomeContentTypeState],[.HomeContentTypeDoubleGood,.HomeContentTypeMulityGood/*,.HomeContentTypeRecommend*/],[.HomeContentTypeSupplyHead,.HomeContentTypeSupplyDetail,.HomeContentTypeSupplyFoot],[.HomeContentTypeFruitHead],[.HomeContentTypeFruitDetail]] : [[UserCenterCellType.HomeContentTypeAd],[.HomeContentTypeMenu,.HomeContentTypeState],[.HomeContentTypeDoubleGood,.HomeContentTypeMulityGood,.HomeContentTypeRecommend],[.HomeContentTypeSupplyHead,.HomeContentTypeSupplyDetail,.HomeContentTypeSupplyFoot],[.HomeContentTypeFruitHead],[.HomeContentTypeFruitDetail]]
                    self.currentTableView.reloadData()
                }
            }
        }
    }
    
    func fetchData() {
        self.getCache()
        if self.networkObserver.currentReachabilityStatus() == .NotReachable {
            return
        }
        self.fetchTop()
        self.fetchDaoHang()
        self.fetchDongTai()
        self.fetchMiniProducts()
        self.fetchRecommend()
        self.fetchSupplyDemand()
        self.fetchProducts()
    }
    
    //MARK: 获取轮播图
    func fetchTop() {
        QNNetworkTool.fetchHomeMiniAd(self.topAdName) { (success, products, error) -> Void in
            if success! {
                self.topAdArray.removeAllObjects()
                self.topAdArray.addObjectsFromArray(products as! [AnyObject])
                self.currentTableView.reloadData()
            }
        }
    }
    //MARK: 获取导航
    func fetchDaoHang() {
        QNNetworkTool.fetchHomeMiniAd("mbdz_index_nav") { (success, products, error) -> Void in
            if success! {
                self.menus.removeAllObjects()
                self.menus.addObjectsFromArray(products as! [AnyObject])
                self.currentTableView.reloadData()
            }
        }
    }
    //MARK: 获取交易动态
    func fetchDongTai() {
        QNNetworkTool.fetchHomeDongTai { (history, dictionary, error) -> Void in
            if let history = history {
                self.dongTaiArray.removeAllObjects()
                self.dongTaiArray.addObjectsFromArray(history as [AnyObject])
                self.currentTableView.reloadData()
            }
        }
    }
    
    //MARK: 获取交易企业
    func fetchEnterprise() {
        QNNetworkTool.fetchHomeEnterprise { (success, enterprises, error) -> Void in
            if success {
                self.enterpriseArray.removeAllObjects()
                self.enterpriseArray.addObjectsFromArray(enterprises as! [AnyObject])
                self.currentTableView.reloadData()
            }
        }
    }
    //MARK: 获取推荐(推荐的即为交易企业)
    func fetchRecommend() {
        QNNetworkTool.fetchHomeEnterprise { (success, enterprises, error) -> Void in
            if success {
                self.enterpriseArray.removeAllObjects()
                self.enterpriseArray.addObjectsFromArray(enterprises as! [AnyObject])
                self.userCenterData = [[UserCenterCellType.HomeContentTypeAd],[.HomeContentTypeMenu,.HomeContentTypeState],[.HomeContentTypeDoubleGood,.HomeContentTypeMulityGood,.HomeContentTypeRecommend],[.HomeContentTypeSupplyHead,.HomeContentTypeSupplyDetail,.HomeContentTypeSupplyFoot]]
                self.currentTableView.reloadData()
            }
        }
    }
    
    //MARK: 获取5个产品
    func fetchMiniProducts() {
        QNNetworkTool.fetchHomeMiniAd("company_top_five") { (success, products, error) -> Void in
            if success! {
                self.miniProductsArray.removeAllObjects()
                self.miniProductsArray.addObjectsFromArray(products as! [AnyObject])
                self.currentTableView.reloadData()
            }
        }
    }
    
    
    //MARK: 获取供求大厅
    func fetchSupplyDemand() {
        QNNetworkTool.supplyDemandSearch(nil, page: 1, pageSize: 8, check: 2, q: "", type: self.supplyType, orderBy: 16, fromPrice: nil, toPrice: nil) { (error, products) -> Void in
            if let products = products {
                self.supplyDemandArray.removeAllObjects()
                self.supplyDemandArray.addObjectsFromArray(products as [AnyObject])
                self.currentTableView.reloadData()
            }
        }
    }
    
    //MARK: 获取最下面商品部分
    func fetchProducts() {
        //现获取所有的分类Id,然后遍历id取商品
        self.fetchCategories()
    }
    
    
    func fetchCategories(){
        let queue1 = dispatch_queue_create("categoryQueue", DISPATCH_QUEUE_CONCURRENT)
        dispatch_async(queue1) { () -> Void in
            QNNetworkTool.fetchMainCategories { (categories, error) -> Void in
                if let categories = categories {
                    self.categories.removeAllObjects()
                    self.categories.addObjectsFromArray(categories as [AnyObject])
                    self.currentTableView.reloadData()
                    self.userCenterData = self.enterpriseArray.count == 0 ? [[UserCenterCellType.HomeContentTypeAd],[.HomeContentTypeMenu,.HomeContentTypeState],[.HomeContentTypeDoubleGood,.HomeContentTypeMulityGood/*,.HomeContentTypeRecommend*/],[.HomeContentTypeSupplyHead,.HomeContentTypeSupplyDetail,.HomeContentTypeSupplyFoot],[.HomeContentTypeFruitHead],[.HomeContentTypeFruitDetail]] : [[UserCenterCellType.HomeContentTypeAd],[.HomeContentTypeMenu,.HomeContentTypeState],[.HomeContentTypeDoubleGood,.HomeContentTypeMulityGood,.HomeContentTypeRecommend],[.HomeContentTypeSupplyHead,.HomeContentTypeSupplyDetail,.HomeContentTypeSupplyFoot],[.HomeContentTypeFruitHead],[.HomeContentTypeFruitDetail]]
                    self.currentTableView.reloadData()
                    self.fetchProductsAtIndex()
                }else{
                    ZMDTool.showErrorPromptView(nil, error: error)
                }
            }
        }
    }
    
    func fetchProductsAtIndex() {
        if self.categories.count <= self.friutIndex {
            return
        }
        let category = self.categories[self.friutIndex] as! ZMDXHYCategory
        QNNetworkTool.fetchProductsInCategory(5, categoryId: category.Id.integerValue) { (products, WidgetName, error) -> Void in
            if let products = products {
                self.productsArray.removeAllObjects()
                self.productsArray.addObjectsFromArray(products as [AnyObject])
                self.userCenterData = self.enterpriseArray.count == 0 ? [[UserCenterCellType.HomeContentTypeAd],[.HomeContentTypeMenu,.HomeContentTypeState],[.HomeContentTypeDoubleGood,.HomeContentTypeMulityGood/*,.HomeContentTypeRecommend*/],[.HomeContentTypeSupplyHead,.HomeContentTypeSupplyDetail,.HomeContentTypeSupplyFoot],[.HomeContentTypeFruitHead],[.HomeContentTypeFruitDetail]] : [[UserCenterCellType.HomeContentTypeAd],[.HomeContentTypeMenu,.HomeContentTypeState],[.HomeContentTypeDoubleGood,.HomeContentTypeMulityGood,.HomeContentTypeRecommend],[.HomeContentTypeSupplyHead,.HomeContentTypeSupplyDetail,.HomeContentTypeSupplyFoot],[.HomeContentTypeFruitHead],[.HomeContentTypeFruitDetail]]
                self.currentTableView.reloadSections(NSIndexSet(index: 5), withRowAnimation: .None)
            }
        }
    }
    
    func fetchProducts(categories:NSArray) {
        self.productsArray.removeAllObjects()
        let group = dispatch_group_create()
        let queue = dispatch_get_global_queue(0, 0)
        for category in categories {
            let category = category as! ZMDXHYCategory
            dispatch_group_async(group, queue, { () -> Void in
                QNNetworkTool.fetchProductsInCategory(5, categoryId: category.Id.integerValue, completion: { (products, WidgetName, error) -> Void in
                    if let products = products {
                        self.productsArray.addObject(products)
                        //                    self.userCenterData = self.enterpriseArray.count == 0 ? [[UserCenterCellType.HomeContentTypeAd],[.HomeContentTypeMenu,.HomeContentTypeState],[.HomeContentTypeDoubleGood,.HomeContentTypeMulityGood/*,.HomeContentTypeRecommend*/],[.HomeContentTypeSupplyHead,.HomeContentTypeSupplyDetail,.HomeContentTypeSupplyFoot],[.HomeContentTypeFruitHead],[.HomeContentTypeFruitDetail]] : [[UserCenterCellType.HomeContentTypeAd],[.HomeContentTypeMenu,.HomeContentTypeState],[.HomeContentTypeDoubleGood,.HomeContentTypeMulityGood,.HomeContentTypeRecommend],[.HomeContentTypeSupplyHead,.HomeContentTypeSupplyDetail,.HomeContentTypeSupplyFoot],[.HomeContentTypeFruitHead],[.HomeContentTypeFruitDetail]]
//                        self.currentTableView.reloadData()
                    }
                })
            })
        }
        dispatch_group_notify(group, queue) { () -> Void in
            self.currentTableView.reloadData()
        }
    }
    
    private func dataInit(){
        self.menuType = [.kFeature,.kECommerce,.kSupply,.kDemand,.kEnterprise]
        self.searchTypes = [.kSupply,.kDemand,.kGood,.kStore]
        self.timer = NSTimer.scheduledTimerWithTimeInterval(1.5, target: self, selector: Selector("changeDongTai"), userInfo: nil, repeats: true)
        self.networkObserver = Reachability.reachabilityForInternetConnection()
    }
    
    func updateUI() {
        self.currentTableView.backgroundColor = tableViewdefaultBackgroundColor
        self.currentTableView.scrollsToTop = false
        self.viewForSearch()
        self.configRightItem()
    }
    
    //MAKR: - 搜索View
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
        leftViewBtn.setImage(UIImage(named: "arrow-down"), forState: .Normal)
        leftViewBtn.setTitle("商品", forState: .Normal)
        leftViewBtn.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        leftViewBtn.titleLabel?.font = UIFont.systemFontOfSize(15)
        leftViewBtn.imageEdgeInsets = UIEdgeInsets(top: 2, left: 38*kScreenWidth/375, bottom: 0, right: -38*kScreenWidth/375)
        leftViewBtn.titleEdgeInsets = UIEdgeInsets(top: 0, left: -12*kScreenWidth/375, bottom: 0, right: 12*kScreenWidth/375)
        leftViewBtn.rac_command = RACCommand(signalBlock: { (sender) -> RACSignal! in
            (sender as!UIButton).selected = !(sender as!UIButton).selected
            self.view.endEditing(true)
            self.textInput.resignFirstResponder()
            self.selectView = UIView(frame: CGRect(x: 12*kScreenWidth/375, y: 32*kScreenWidth/375, width: 60*kScreenWidth/375, height: 36*4*kScreenWidth/375))
            self.selectView.backgroundColor = RGB(253,124,76,1.0)
            self.selectView.alpha = 1.0
            ZMDTool.configViewLayer(self.selectView)
            for i in 0..<self.searchTypes.count {
                let searchType = self.searchTypes[i]
                let btn = UIButton(frame: CGRect(x: 0, y: 36*CGFloat(i)*kScreenWidth/375, width: 60*kScreenWidth/375, height: 36*kScreenWidth/375))
                btn.tag = 1000+i
                btn.setTitle(searchType.title, forState: .Normal)
                btn.setTitleColor(UIColor.whiteColor(), forState: .Normal)
                btn.titleLabel?.font = UIFont.systemFontOfSize(15)
                btn.backgroundColor = UIColor.clearColor()
                btn.addSubview(ZMDTool.getLine(CGRect(x: 0, y: btn.frame.height-0.5, width: btn.frame.width, height: 0.5), backgroundColor: UIColor.whiteColor()))
                btn.rac_command = RACCommand(signalBlock: { (sender) -> RACSignal! in
                    self.selectView.removeFromSuperview()
                    leftViewBtn.setTitle((sender as! UIButton).titleLabel?.text, forState: .Normal)
                    self.searchType = self.searchTypes[(sender as! UIButton).tag-1000]
                    return RACSignal.empty()
                })
                self.selectView.addSubview(btn)
            }
            self.selectView.showAsPop(setBgColor: false)
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
        rightBtn.setImage(UIImage(named: "message"), forState: .Normal)
        rightBtn.rac_command = RACCommand(signalBlock: { (input) -> RACSignal! in
            let vc = MsgHomeViewController()
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
            return RACSignal.empty()
        })
        rightBtn.tag = 666
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
