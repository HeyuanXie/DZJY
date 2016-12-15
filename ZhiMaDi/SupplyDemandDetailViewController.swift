//
//  SupplyDemandDetailViewController.swift
//  ZhiMaDi
//
//  Created by admin on 16/12/4.
//  Copyright © 2016年 ZhiMaDi. All rights reserved.
//

import UIKit
import TYAttributedLabel
import MJRefresh
import WebKit

//供求详请
class SupplyDemandDetailViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,QNShareViewDelegate,ZMDInterceptorProtocol,NewPagedFlowViewDelegate, NewPagedFlowViewDataSource {
    enum GoodsCellType{
        case HomeContentTypeAd                       /* 广告显示页 */
        case HomeContentTypeDetail                   /* 菜单参数栏目 */
        case HomeContentTypeDistribution             /* 商品产地 */
        case HomeContentTypeSeller                   /* 卖家联系方式  */
        case HomeContentTypeIntroductionHead         /* 商品说明头部 */
        case HomeContentTypeIntroductionDetail       /* 产品说明详情 */
        init(){
            self = HomeContentTypeAd
        }
    }
    
    @IBOutlet weak var currentTableView: UITableView!
    var type = 1    // 1为供应，2为求购
    var countForBounghtLbl : UIButton!               // 购买数量Lbl
    var productAttrV : ZMDProductAttrView!
    var kTagEditViewShow = 100001
    
    var countForBounght = 1                         // 购买数量
    var goodsCellTypes: [GoodsCellType]!
    var navBackView : UIView!
    var navLine : UIView!
    
    var supplyProductId : Int!
    var pageFlowView : NewPagedFlowView!
    
    var isCollected = false        //判断是否已经收藏
    var shoppingItemId: NSNumber!
    var data : ZMDSupplyProduct!    //从SupplyList传过来的product
    var imageArray = NSMutableArray()
    
    //MARK: - *************LiftCircle**************
    override func viewDidLoad() {
        super.viewDidLoad()
        self.fetchData()
        self.setupNavigation()
        self.dataInit()
        self.updateUI()
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        self.currentTableView.reloadData()
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(true)
        if let pageFlowView = self.pageFlowView {
            pageFlowView.stopTimer()
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK:- Action进入购物车
    //进入购物车(不是添加商品到购物车)
    @IBAction func AddProductToCard(sender: UIButton) {
        // 购物车
        let vc = ShoppingCartViewController.CreateFromMainStoryboard() as! ShoppingCartViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    //MARK:- UITableViewDataSource,UITableViewDelegate
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if tableView == self.currentTableView && self.data == nil {
            return 0
        }
        return self.goodsCellTypes.count
    }
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let cellType = self.goodsCellTypes[section]
        switch cellType {
        case .HomeContentTypeDistribution :
            return 11*kScreenWidth/375
        case .HomeContentTypeIntroductionHead :
            return 11*kScreenWidth/375
        case .HomeContentTypeSeller :
            return g_isLogin! ? 0 : 34*kScreenWidth/375
        default :
            return 0
        }
    }
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return  0
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        let cellType = self.goodsCellTypes[indexPath.section]
        switch cellType {
        case .HomeContentTypeAd :
            return 286*kScreenWidth/375 //image是236
        case .HomeContentTypeDetail :
            return 127
        case .HomeContentTypeDistribution :
            return 54
        case .HomeContentTypeSeller :
            return 154*kScreenWidth/375
        case .HomeContentTypeIntroductionHead :
            return 54
        case .HomeContentTypeIntroductionDetail :
            return 214*kScreenWidth/375
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellType = self.goodsCellTypes[indexPath.section]
        switch cellType {
        case .HomeContentTypeAd :
            return cellForHomeAd(tableView, indexPath: indexPath)
        case .HomeContentTypeDetail :
            return cellForHomeDetail(tableView, indexPath: indexPath)
        case .HomeContentTypeDistribution :
            return cellForDistribution(tableView, indexPath: indexPath)
        case .HomeContentTypeSeller :
            return cellForSeller(tableView, indexPath: indexPath)
        case .HomeContentTypeIntroductionHead :
            return cellForIntroductionHead(tableView, indexPath: indexPath)
        case .HomeContentTypeIntroductionDetail :
            return cellForIntroductionDetail(tableView, indexPath: indexPath)
        }
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cellType = self.goodsCellTypes[section]
        if cellType == .HomeContentTypeSeller && !g_isLogin {
            let view = UIView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 34*kScreenWidth/375))
            view.backgroundColor = RGB(253,246,216,1.0)
            let label = ZMDTool.getLabel(view.bounds, text: "点击登录,查看详细联系方式", fontSize: 14)
            label.textAlignment = .Center
            label.attributedText = label.text?.AttributedText("点击登录", color: appThemeColorNew)
            let btn = ZMDTool.getButton(view.bounds, textForNormal: "", fontSize: 0, backgroundColor: UIColor.clearColor(), blockForCli: { (sender) -> Void in
                let vc = LoginViewController.CreateFromLoginStoryboard() as! LoginViewController
                //                self.presentViewController(vc, animated: true, completion: nil)
                self.pushToViewController(vc, animated: true, hideBottom: true)
                //                ZMDTool.enterLoginViewController()
            })
            view.addSubview(label)
            view.addSubview(btn)
            return view
        }
        return nil
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cellType = self.goodsCellTypes[indexPath.section]
    }
    
    //MARK: - ***************Delegate***************
    //MARK: QNShareViewDelegate
    //分享的body，返回一个data，通过data.image可以取到image
    func qnShareView(view: ShareView) -> (image: UIImage, url: String, title: String?, description: String)? {
        if let data = self.data {
            let imgUrl = kImageAddressMain + (data.SupplyDemandPictures[0].PictureUrl)
            let image = UIImage(data: NSData(contentsOfURL: NSURL(string: imgUrl)!)!)
            let title = data.Title
            let url = "\(kImageAddressMain)/\(data.Id.integerValue)"
            let description = data.Description ?? ""
            return (image!,url,title,description)
        }else{
            return (UIImage(named: "Share_Icon")!, kImageAddressMain, self.title ?? "", "疆南市场,物美价廉!")
        }
    }
    
    func present(alert: UIAlertController) -> Void {
        self.presentViewController(alert, animated: false, completion: nil)
    }
    
    
    func updateDetailView(webView:WKWebView) {
        
    }
    
    //MARK: NewPageFlowViewDelegate
    func sizeForPageInFlowView(flowView: NewPagedFlowView!) -> CGSize {
        return CGSizeMake(236*kScreenWidthZoom6, 236*kScreenWidthZoom6);
    }
    func didSelectCell(subView: UIView!, withSubViewIndex subIndex: Int) {
        
    }
    
    //MARK: NewPageFlowViewDelegate
    func numberOfPagesInFlowView(flowView: NewPagedFlowView!) -> Int {
        if let data = self.data {
            return data.SupplyDemandPictures.count
        }
        return 0
    }
    func flowView(flowView: NewPagedFlowView!, cellForPageAtIndex index: Int) -> UIView! {
        guard let bannerView = flowView.dequeueReusableCell() as? PGIndexBannerSubiew else {
            let bannerView = PGIndexBannerSubiew(frame: CGRect(x: 0, y: 0, width: 236*kScreenWidthZoom6, height: 236*kScreenWidthZoom6))
            bannerView.layer.cornerRadius = 4
            bannerView.layer.masksToBounds = true
            if let url = self.imageArray[index] as? NSURL {
                bannerView.mainImageView.sd_setImageWithURL(url, placeholderImage: nil)
            }
            bannerView.mainImageView.sd_setImageWithURL(self.imageArray[index] as! NSURL, placeholderImage: nil)
            return bannerView
        }
        bannerView.layer.cornerRadius = 4
        bannerView.layer.masksToBounds = true
        if let mainImageView = bannerView.mainImageView,url = self.imageArray[index] as? NSURL {
            mainImageView.sd_setImageWithURL(url, placeholderImage: nil)
        }
        return bannerView
    }
    
    func didScrollToPage(pageNumber: Int, inFlowView flowView: NewPagedFlowView!) {
        
    }
    
    //MARK: - *********TableViewCell**********
    /// 广告 cell
    func cellForHomeAd(tableView: UITableView,indexPath: NSIndexPath)-> UITableViewCell {
        let cellId = "adCell"
        var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
        if cell == nil {
            cell = UITableViewCell(style: .Default, reuseIdentifier: cellId)
            ZMDTool.configTableViewCellDefault(cell!)
            cell!.selectionStyle = .None
            cell!.contentView.backgroundColor = RGB(239,240,241,1.0)
 
            
            let width = 236*kScreenWidthZoom6
            let scrollView = UIScrollView(frame: CGRect(x: 0, y: 14*kScreenWidthZoom6, width: kScreenWidth, height: width))
            scrollView.tag = 10001
            scrollView.showsHorizontalScrollIndicator = false
            cell?.contentView.addSubview(scrollView)
            
            self.pageFlowView = NewPagedFlowView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: width))
            self.pageFlowView.tag = 10000
            self.pageFlowView.backgroundColor = UIColor.clearColor()
            self.pageFlowView.delegate = self
            self.pageFlowView.dataSource = self
            self.pageFlowView.autoTime = 2.5
            self.pageFlowView.minimumPageAlpha = 0.1
            self.pageFlowView.minimumPageScale = 0.85
            self.pageFlowView.orientation = NewPagedFlowViewOrientationHorizontal
            //提前告诉有多少页
            self.pageFlowView.orginPageCount = self.imageArray.count;
            self.pageFlowView.isOpenAutoScroll = true

            //初始化pageControl
            let pageControl = UIPageControl(frame: CGRect(x: 0, y: (236+14+13)*kScreenWidthZoom6, width: kScreenWidth-24-8, height: 8))
            cell?.contentView.addSubview(pageControl)
            pageControl.tag = 10002
            pageControl.currentPageIndicatorTintColor = appThemeColorNew
            pageControl.pageIndicatorTintColor = RGB(209,210,211,1.0)
            self.pageFlowView.pageControl = pageControl
            
            scrollView.addSubview(self.pageFlowView)
        }
        
        let scrollView = cell?.contentView.viewWithTag(10001) as! UIScrollView
        let pageFlowView = scrollView.viewWithTag(10000) as! NewPagedFlowView
        if self.data != nil && self.data.SupplyDemandPictures != nil {
            pageFlowView.reloadData()
        }
        return cell!
    }
    /// 商品详请 cell
    func cellForHomeDetail(tableView: UITableView,indexPath: NSIndexPath)-> UITableViewCell {
        let cellId = "detailCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellId) as! DZContentDetailCell
        if self.data != nil {
            if self.type == 1 {
                DZContentDetailCell.configDetailCell(cell, product: self.data, isDemand: false)
            }else{
                DZContentDetailCell.configDetailCell(cell, product: self.data, isDemand: true)
            }
        }
        return cell
    }
    /// 产地cell
    func cellForDistribution(tableView: UITableView,indexPath: NSIndexPath)-> UITableViewCell {
        let cellId = "distributionCell"
        var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
        if cell == nil {
            cell = UITableViewCell(style: .Default, reuseIdentifier: cellId)
            ZMDTool.configTableViewCellDefault(cell!)
            cell!.selectionStyle = .None
            cell!.contentView.backgroundColor = UIColor.whiteColor()
            
            let label = ZMDTool.getLabel(CGRect(x: 10, y: 0, width: kScreenWidth-10-20-5, height: 54), text: "", fontSize: 16, textColor: defaultTextColor, textAlignment: .Left)
            label.tag = 1000
            let btn = ZMDTool.getButton(CGRect(x: kScreenWidth-20, y: 17, width: 20, height: 20), textForNormal: "", fontSize: 0, backgroundColor: UIColor.clearColor(), blockForCli: { (sender) -> Void in
                //...More
            })
            cell?.contentView.addSubview(label)
            cell?.addLine()
            cell?.addSubview(btn)
        }
        
        let label = cell?.contentView.viewWithTag(1000) as! UILabel
        label.text = "喀什小河村民小组经济合作社"
        return cell!
    }
    
    /// 卖家联系方式cell
    func cellForSeller(tableView: UITableView,indexPath: NSIndexPath)-> UITableViewCell {
        let cellId = "sellerCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellId) as! DZContentSellerCell
        if let data = self.data {
            DZContentSellerCell.configSellerCell(cell, data:data)
        }
        return cell
    }
    /// 产品说明头部cell
    func cellForIntroductionHead(tableView: UITableView,indexPath: NSIndexPath)-> UITableViewCell {
        let cellId = "introductionHeadCell"
        var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
        if cell == nil {
            cell = UITableViewCell(style: .Default, reuseIdentifier: cellId)
            ZMDTool.configTableViewCellDefault(cell!)
            cell!.selectionStyle = .None
            cell!.contentView.backgroundColor = UIColor.whiteColor()
            
            let colorLbl = ZMDTool.getLine(CGRect(x: 12, y: 0, width: 5, height: 19), backgroundColor: appThemeColorNew)
            colorLbl.set("cy", value: 54/2)
            let textLbl = ZMDTool.getLabel(CGRect(x: CGRectGetMaxX(colorLbl.frame)+5, y: 0, width: 100, height: 20), text: "产品说明", fontSize: 15)
            textLbl.set("cy", value: 54/2)
            cell?.contentView.addSubview(colorLbl)
            cell?.contentView.addSubview(textLbl)
        }
        return cell!
    }
    /// 产品说明详情cell
    func cellForIntroductionDetail(tableView: UITableView,indexPath: NSIndexPath)-> UITableViewCell {
        let cellId = "introductionDetailCell"
        var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
        if cell == nil {
            cell = UITableViewCell(style: .Default, reuseIdentifier: cellId)
            cell!.selectionStyle = .None
            cell!.contentView.backgroundColor = UIColor.whiteColor()
            
            let wkUserContentController = WKUserContentController()
            let jScript = "var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width'); document.getElementsByTagName('head')[0].appendChild(meta);"
            let wkUScript = WKUserScript(source: jScript, injectionTime: .AtDocumentEnd, forMainFrameOnly: true)
            wkUserContentController.addUserScript(wkUScript)
            let wkWebConfig = WKWebViewConfiguration()
            wkWebConfig.userContentController = wkUserContentController
            
            let webView = WKWebView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 214*kScreenWidth/375), configuration: wkWebConfig)
            webView.scrollView.showsVerticalScrollIndicator = false
            webView.scrollView.showsHorizontalScrollIndicator = false
            webView.tag = 1000
            cell?.contentView.addSubview(webView)
        }
        if let data = self.data {
            let webView = cell?.contentView.viewWithTag(1000) as! WKWebView
            let webUrl = kImageAddressMain + "/\(data.Id.integerValue)"
            webView.loadRequest(NSURLRequest(URL: NSURL(string: webUrl)!))
        }
        return cell!
    }
    
    //MARK: - ************PrivateMethod*************
    //MARK: fetchData
    func fetchData() {
        
    }
    //MARK: setupNavigation
    func setupNavigation() {
        self.title = "详情"
        
        let height = (self.navigationController?.navigationBar.frame.height)!
        let rightView = UIView(frame: CGRect(x: 0, y: 0, width: 85, height: height))
        let images = ["collect01","分享","common_more"]
        for i in 0..<3 {
            let btn = UIButton(frame: CGRect(x: CGFloat(i)*(25+3), y: (height-25)/2.0, width: 25, height: 25))
            btn.setImage(UIImage(named: images[i])?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal), forState: .Normal)
            rightView.addSubview(btn)
            btn.tag = 1000 + i
            btn.rac_command = RACCommand(signalBlock: { (sender) -> RACSignal! in
                switch (sender as! UIButton).tag {
                case 1000:
                    
                    break
                case 1001:
//                    ZMDShareSDKTool.
                    break
                default:
                    break
                }
                return RACSignal.empty()
            })
        }
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightView)
    }
    
    private func dataInit(){
        self.goodsCellTypes = [.HomeContentTypeAd,.HomeContentTypeDetail,.HomeContentTypeDistribution,.HomeContentTypeSeller,.HomeContentTypeIntroductionHead,.HomeContentTypeIntroductionDetail]
        if self.type == 2 {
            self.goodsCellTypes = [.HomeContentTypeDetail,.HomeContentTypeDistribution,.HomeContentTypeSeller,.HomeContentTypeIntroductionHead,.HomeContentTypeIntroductionDetail]
        }
        if let data = self.data, pictures = data.SupplyDemandPictures {
            self.imageArray.removeAllObjects()
            for pic in pictures
            {
                let imgUrl = kImageAddressMain + (pic.PictureUrl ?? "")
                self.imageArray.addObject(NSURL(string: imgUrl)!)
            }
        }
    }
    
    func updateUI() {
        let tableViewFooterView = UIView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 57*kScreenWidth/375))
        tableViewFooterView.backgroundColor = RGB(239,240,241,1.0)
        let label = ZMDTool.getLabel(CGRect(x: 0, y: 0, width: kScreenWidth, height: 57*kScreenWidth/375), text: "- 已经到底了 -", fontSize: 15, textColor: RGB(172,173,174,1.0), textAlignment: .Center)
        tableViewFooterView.addSubview(label)
        self.currentTableView.tableFooterView = tableViewFooterView
    }
    
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
    
    //MARK:判断是否已经收藏
    func wheatherCollected() {
        //先遍历已经收藏的items,如果其中包含当前item，则self.isCollected = true
        QNNetworkTool.fetchShoppingCart(2){(shoppingItems, dictionary, error) -> Void in
            if let shoppingItems = shoppingItems {
                var index = 0
                for shoppingItem in shoppingItems {
                    if (shoppingItem as! ZMDShoppingItem).ProductName == (self.data?.Title){
                        self.isCollected = true
                        self.shoppingItemId = shoppingItem.Id
                        break
                    }
                    index++
                }
                if index == shoppingItems.count{
                    self.isCollected = false
                }
            }
        }
    }
    
    //MARK:收藏和取消收藏
    func collect() {
        if g_isLogin! {
            //先遍历已经收藏的items,如果其中包含当前item，则self.isCollected = true
            QNNetworkTool.fetchShoppingCart(2){(shoppingItems, dictionary, error) -> Void in
                for shoppingItem in shoppingItems ?? [] {
                    if (shoppingItem as! ZMDShoppingItem).ProductName == self.data.Title{
                        self.isCollected = true
                        self.shoppingItemId = shoppingItem.Id
                        break
                    }
                }
                if self.isCollected {
                    //再次点击取消收藏
                    QNNetworkTool.deleteCartItem(self.shoppingItemId.stringValue, carttype: 2, completion: { (succeed, dictionary, error) -> Void in
                        if succeed != nil {
                            self.isCollected = false
                            ZMDTool.showPromptView("已取消收藏")
                        }else{
                            ZMDTool.showPromptView("取消收藏失败")
                        }
                    })
                }else{
                    if let productAttrV = self.productAttrV {
                        let postDic = productAttrV.getPostData(self.countForBounght, IsEdit: false)
                        if postDic == nil {
                            return
                        }
                        postDic!.setValue(self.data.Id.integerValue, forKey: "Id")
                        postDic!.setValue(2, forKey: "CartType")
                        postDic!.setValue(g_customerId!, forKey: "CustomerId")
                        QNNetworkTool.addProductToCart(postDic!, completion: { (succeed, dictionary, error) -> Void in
                            if succeed! {
                                self.isCollected = true
                                ZMDTool.showPromptView("收藏成功")
                            } else {
                                ZMDTool.showErrorPromptView(dictionary, error: error, errorMsg: "收藏失败")
                            }
                        })
                    }
                }
            }
        } else {
            self.commonAlertShow(true, title: "提示:未登录!", message: "是否立即登录?", preferredStyle: UIAlertControllerStyle.Alert)
        }
    }
    
    //MARK:-alertDestructiveAction 重写
    override func alertDestructiveAction() {
        ZMDTool.enterLoginViewController()
    }
}

class DZContentDetailCell : UITableViewCell {
    @IBOutlet weak var quantityNameLbl : UILabel!
    @IBOutlet weak var nameLbl : UILabel!
    @IBOutlet weak var priceLbl : UILabel!
    @IBOutlet weak var priceUnitLbl : UILabel!
    @IBOutlet weak var addressLbl : UILabel!
    @IBOutlet weak var limitLbl : UILabel!
    @IBOutlet weak var endTimeLbl : UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.priceUnitLbl.hidden = true
    }
    
    class func configDetailCell(cell:DZContentDetailCell,product:ZMDSupplyProduct,isDemand:Bool) {
        cell.nameLbl.text = product.Title
        cell.priceLbl.text = "\(product.Price.floatValue) /\(product.PriceUnit)"
        cell.priceLbl.attributedText = cell.priceLbl.text?.AttributeText(["\(product.Price.floatValue)","/\(product.PriceUnit)"], colors: [appThemeColorNew,defaultTextColor], textSizes: [20,14], bolds: [true,false])
        cell.addressLbl.text = product.AreaName.componentsSeparatedByString(">>").first!+" "+product.AreaName.componentsSeparatedByString(">>").last!
        cell.limitLbl.text = "\(product.Quantity)\(product.QuantityUnit)/\(product.MinQuantity ?? 0)\(product.MinQuantityUnit)起订"
        cell.endTimeLbl.text = "截止至: \(product.EndTime.componentsSeparatedByString("T").first!)"

        if isDemand {
            cell.quantityNameLbl.text = "采购量"
            cell.limitLbl.text = "\(product.Quantity)\(product.QuantityUnit)"
        }
    }
}

class DZContentSellerCell : UITableViewCell {
    @IBOutlet weak var phoneLbl : UILabel!
    @IBOutlet weak var qqLbl : UILabel!
    @IBOutlet weak var weixinLbl : UILabel!
    
    override func awakeFromNib() {
        self.frame = CGRect(x: 0, y: 0, width: kScreenWidth, height: 154*kScreenWidth/375)
        let lblHeight = 154*kScreenWidth/(375*3)
        for i in 0..<2 {
            self.addSubview(ZMDTool.getLine(CGRect(x: 0, y: CGFloat(i+1)*lblHeight, width: kScreenWidth, height: 0.5), backgroundColor: defaultLineColor))
        }
    }
    
    class func configSellerCell(cell:DZContentSellerCell,data:ZMDSupplyProduct) {
        let phoneText = "手机号: \(data.Phone)"
        let qqText = "QQ号: \(data.QQ)"
        let weixinText = "微信号: 就不告诉你"
        cell.phoneLbl.attributedText = phoneText.AttributedText("手机号:", color: RGB(173,174,175,1.0))
        cell.qqLbl.attributedText = qqText.AttributedText("QQ号:", color: RGB(173,174,175,1.0))
        cell.weixinLbl.attributedText = weixinText.AttributedText("微信号:", color: RGB(173,174,175,1.0))
    }
}

