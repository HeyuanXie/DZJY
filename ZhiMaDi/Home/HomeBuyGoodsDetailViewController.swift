
//
//  HomeBuyGoodsDetailViewController.swift
//  ZhiMaDi
//
//  Created by haijie on 16/2/25.
//  Copyright © 2016年 ZhiMaDi. All rights reserved.
//

import UIKit
import TYAttributedLabel
import MJRefresh
import WebKit

//Int的extension，判断当前int值是否在range范围内
extension Int {
    func isIn(range:NSArray)->Bool{
        var index = 0
        for item in range {
            if item as! Int == self {
                break
            }
            index++
        }
        if index == range.count {
            return false
        }else{
            return true
        }
    }
}

//商品详请
class HomeBuyGoodsDetailViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,QNShareViewDelegate,ZMDInterceptorProtocol{
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
    var countForBounghtLbl : UIButton!               // 购买数量Lbl
    @IBOutlet weak var countForShoppingCar: UILabel!    //购物车数量
    @IBOutlet weak var bottomV: UIView!
    var productAttrV : ZMDProductAttrView!
    var kTagEditViewShow = 100001
    
    var countForBounght = 1                         // 购买数量
    var goodsCellTypes: [GoodsCellType]!
    var navBackView : UIView!
    var navLine : UIView!
    var productId : Int!
    var productDetail : ZMDProductDetail!
    var attrSelectArray = NSMutableArray()          // 属性选择
    var collects = NSMutableArray()
    
    var isCollected = false        //判断是否已经收藏
    var shoppingItemId: NSNumber!
    
    //MARK: - *************LiftCircle**************
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupNavigation()
        self.updateUI()
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        self.getShoppingCartNumber()
        self.dataInit()
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(true)
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
        if tableView == self.currentTableView && self.productDetail == nil {
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
            return 286
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
        if let productDetail = self.productDetail {
            let imgUrl = kImageAddressMain + (productDetail.DetailsPictureModel?.DefaultPictureModel!.ImageUrl)!
            let image = UIImage(data: NSData(contentsOfURL: NSURL(string: imgUrl)!)!)
            let title = productDetail.Name
            let url = "\(kImageAddressMain)/\(productDetail.Id.integerValue)"
            let description = productDetail.description
            return (image!,url,title,description)
        }else{
            return (UIImage(named: "Share_Icon")!, kImageAddressMain, self.title ?? "", "疆南市场,物美价廉!")
        }
    }
    
    func present(alert: UIAlertController) -> Void {
        self.presentViewController(alert, animated: false, completion: nil)
    }

    
    func updateDetailView(webView:WKWebView) {
        let urlString = kImageAddressMain + "/product/ProductDetailview?productId=\(self.productId)"
        let requeset = NSURLRequest(URL: NSURL(string: urlString)!)
        webView.loadRequest(requeset)
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
            
        }
        if let v = cell?.viewWithTag(10001) {
            v.removeFromSuperview()
        }
        
        if self.productDetail != nil && self.productDetail.DetailsPictureModel != nil {
            let arr = NSMutableArray()
            if let pictureModel = self.productDetail.DetailsPictureModel!.PictureModels {
                for pic in pictureModel {
                    let imgUrl = kImageAddressMain + (pic.ImageUrl ?? "")
                    arr.addObject(NSURL(string: imgUrl)!)
                }
            }
            let cycleScroll = CycleScrollView(frame: CGRectMake(0, 14, kScreenWidth, 286))
            
            cycleScroll.tag = 10001
            cycleScroll.backgroundColor = UIColor.clearColor()
            cycleScroll.autoScroll = true
            cycleScroll.autoTime = 2.5
            if arr.count != 0 {
                cycleScroll.urlArray = arr as [AnyObject]
            }
            cell?.addSubview(cycleScroll)
        }
        return cell!
    }
    /// 商品详请 cell
    func cellForHomeDetail(tableView: UITableView,indexPath: NSIndexPath)-> UITableViewCell {
        let cellId = "detailCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellId) as! DZContentDetailCell
        if self.productDetail != nil {
            DZContentDetailCell.configDetailCell(cell, product: self.productDetail)
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
        //        DZContentSellerCell.configSellerCell(cell, seller: g_customer!)
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
        if let productDetail = self.productDetail {
            let webView = cell?.contentView.viewWithTag(1000) as! WKWebView
            let webUrl = kImageAddressMain + "/\(productDetail.Id.integerValue)"
            webView.loadRequest(NSURLRequest(URL: NSURL(string: webUrl)!))
        }
        return cell!
    }
    
    //MARK: - ************PrivateMethod*************
    //MARK: setupNavigation
    func setupNavigation() {
        self.title = "详情"
        
        let height = (self.navigationController?.navigationBar.frame.height)!
        let rightView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: height))
        let images = ["product_collect_03","product_share_02","common_more"]
        for i in 0..<3 {
            let btn = UIButton(frame: CGRect(x: CGFloat(i)*(30+5), y: 0, width: 30, height: height))
            btn.setImage(UIImage(named: images[i])?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal), forState: .Normal)
            rightView.addSubview(btn)
            btn.tag = 1000 + i
            btn.rac_command = RACCommand(signalBlock: { (sender) -> RACSignal! in
                switch (sender as! UIButton).tag {
                case 1000:
                    break
                case 1001:
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
        QNNetworkTool.fetchProductDetail(self.productId) { (productDetail, error, dictionary) -> Void in
            if productDetail != nil {
                self.productDetail = productDetail
                self.currentTableView.reloadData()
                //当用户登录状态下，才判断这些商品是否收藏
                if g_customerId != nil {
                    //请求数据完成后判断是否已经收藏
                    self.wheatherCollected()
                }
            } else {
                ZMDTool.showErrorPromptView(nil, error: error)
            }
        }
    }
    
    //MARK: 获取购物车数量
    func getShoppingCartNumber() {
        QNNetworkTool.fetchNumberForShoppingCart { (number, error) -> Void in
            if let number = number {
                self.countForShoppingCar.hidden = number == 0 ? true : false
                self.countForShoppingCar.text = "\(number)"
            }else{
                self.countForShoppingCar.hidden = true
            }
        }
    }
    
    func updateUI() {
        //设置购物车数量圆角
        self.countForShoppingCar.hidden = true
        ZMDTool.configViewLayerRound(self.countForShoppingCar)
        self.bottomV.backgroundColor = RGB(247,247,247,1)
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
                    if (shoppingItem as! ZMDShoppingItem).ProductName == (self.productDetail?.Name){
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
                    if (shoppingItem as! ZMDShoppingItem).ProductName == self.productDetail.Name{
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
                        postDic!.setValue(self.productDetail.Id.integerValue, forKey: "Id")
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

class ContentTypeDetailCell: UITableViewCell {
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var priceLbl: UILabel!
    @IBOutlet weak var priceLblWidthcon: NSLayoutConstraint!
    @IBOutlet weak var oldPriceLbl: UILabel!
    @IBOutlet weak var skuLbl: UILabel!
    @IBOutlet weak var isFreeLbl: UILabel!
    @IBOutlet weak var soldCountLbl: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    class func configProductDetailCell(cell:ContentTypeDetailCell!,product : ZMDProductDetail) {
        cell.nameLbl.text = product.Name.componentsSeparatedByString("）").last
        if let productPrice = product.ProductPrice {
            cell.priceLbl.text = "\(productPrice.Price)"
            cell.priceLblWidthcon.constant = "\(productPrice.Price)".sizeWithFont(defaultSysFontWithSize(20), maxWidth: 200).width + 5  //+5是因为有的计算出的width偏小，显示不全
            cell.layoutIfNeeded()
            let oldPrice = productPrice.OldPrice==nil ? productPrice.Price : productPrice.OldPrice
            cell.oldPriceLbl.text = "原价: \(oldPrice)"
            cell.oldPriceLbl.addCenterYLine()
        }
        
        let text = product.IsFreeShipping?.integerValue == 1 ? "包邮" : "不包邮"
        cell.skuLbl.attributedText = "是否免邮:  \(text)".AttributedMutableText(["是否包邮:"," \(text)"], colors: [defaultTextColor,defaultSelectColor])
        cell.skuLbl.font = UIFont.systemFontOfSize(16)
        cell.isFreeLbl.text = "销售量:  \(product.Sold.integerValue)件"
        cell.isFreeLbl.font = UIFont.systemFontOfSize(16)
        cell.soldCountLbl.text = ""
    }
}

class DZContentDetailCell : UITableViewCell {
    @IBOutlet weak var nameLbl : UILabel!
    @IBOutlet weak var priceLbl : UILabel!
    @IBOutlet weak var addressLbl : UILabel!
    @IBOutlet weak var limitLbl : UILabel!
    @IBOutlet weak var endTimeLbl : UILabel!
    
    class func configDetailCell(cell:DZContentDetailCell,product:ZMDProductDetail) {
        
    }
}

class DZContentSellerCell : UITableViewCell {
    @IBOutlet weak var phoneLbl : UILabel!
    @IBOutlet weak var qqLbl : UILabel!
    @IBOutlet weak var weixinLbl : UILabel!
    @IBOutlet weak var headImg : UIImageView!
    
    override func awakeFromNib() {
        self.frame = CGRect(x: 0, y: 0, width: kScreenWidth, height: 154*kScreenWidth/375)
        let lblWidth = kScreenWidth - 154*kScreenWidth/375
        let lblHeight = 154*kScreenWidth/(375*3)
//        self.phoneLbl.addSubview(ZMDTool.getLine(CGRect(x: 0, y: lblHeight-0.5, width: lblWidth, height: 0.5), backgroundColor: defaultLineColor))
//        self.qqLbl.addSubview(ZMDTool.getLine(CGRect(x: 0, y: lblHeight-0.5, width: lblWidth, height: 0.5), backgroundColor: defaultLineColor))
        for i in 0..<2 {
            self.addSubview(ZMDTool.getLine(CGRect(x: 0, y: CGFloat(i+1)*lblHeight, width: lblWidth, height: 0.5), backgroundColor: defaultLineColor))
        }
        self.headImg.addSubview(ZMDTool.getLine(CGRect(x: 0, y: 0, width: 0.5, height: 154*kScreenWidth/375), backgroundColor: defaultLineColor))
    }
    
    class func configSellerCell(cell:DZContentSellerCell,seller:ZMDCustomer) {
        
    }
}
