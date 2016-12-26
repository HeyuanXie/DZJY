
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
        case HomeContentTypeAd                      /* 广告显示页 */
        case HomeContentTypeDetail                   /* 菜单参数栏目 */
        case HomeContentTypeMenu                    /* 菜单选择栏目 */
        case HomeContentTypeDistribution             /* 商品配送栏目 */
        case HomeContentTypeStore                   /* 店家  */
        case HomeContentTypeDaPeiGou               /* 搭配购商品 */
        case HomeContentTypeLoadMore
        init(){
            self = HomeContentTypeAd
        }
    }
    enum SecondCellType {
        case SecondDetail,SecondScore,SecondParameter
        init(){
            self = SecondDetail
        }
    }
    @IBOutlet weak var currentTableView: UITableView!
    var secondTableView: UITableView!                  //上拉加载的下面一个tableView
    var scoreTableView: UITableView!                    //SecondTable上的评分tableView
    var countForBounghtLbl : UIButton!               // 购买数量Lbl
    @IBOutlet weak var countForShoppingCar: UILabel!    //购物车数量
    @IBOutlet weak var bottomV: UIView!
    var productAttrV : ZMDProductAttrView!
    var kTagEditViewShow = 100001
    
    var countForBounght = 1                         // 购买数量
    var goodsCellTypes: [GoodsCellType]!
    var secondCellType = SecondCellType()
    var navBackView : UIView!
    var navLine : UIView!
    var productId : Int!
    var productDetail : ZMDProductDetail!
    var attrSelectArray = NSMutableArray()          // 属性选择
    var collects = NSMutableArray()
    
    var isCollected = false        //判断是否已经收藏
    var shoppingItemId: NSNumber!
    dynamic var isSecondTableView = false   //当前是否为第二个tableView
    
    var responsitoryNumber = 15          //商品库存量
    
    
    //MARK: - LifeCircle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.getResponsitoryNubmer()
        self.updateUI()
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        self.getShoppingCartNumber()
        self.dataInit()
        self.getBackView((self.navigationController?.navigationBar)!)
        //从购物车返回到secondTableView中，在这里设置navigationBar
        if self.isSecondTableView {
            self.setupNavigation()
            if self.navBackView != nil {
                self.navLine.hidden = false
                self.navBackView.backgroundColor = UIColor.whiteColor()
                self.navBackView.alpha = 1.0
            }
        }else{
            self.setupNavigationWithBg()            //如果登陆了,在dataInit中-->wheatherIsCollected中会执行setupNavigationWithBg
            //如果没登录，就要在这里设置navigationBar
        }
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(true)
        if self.navBackView != nil {
            self.navBackView.alpha = 1.0
            self.navLine.alpha = 1.0
            self.navLine.hidden = false
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
        vc.tabBarHidden = true
        self.pushToViewController(vc, animated: true, hideBottom: true)
    }
    
    //MARK:- UITableViewDataSource,UITableViewDelegate
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.secondTableView {
            return 1
        }
        if tableView == self.scoreTableView {
            return 1
        }
        
        let cellType = self.goodsCellTypes[section]
        switch cellType {
        case .HomeContentTypeAd :
            return 1
        case .HomeContentTypeMenu :
            return 1
        case .HomeContentTypeDaPeiGou :
            return 1
        default :
            return 1
        }
    }
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if tableView == self.currentTableView && self.productDetail == nil {
            return 0
        }
        if tableView == self.secondTableView {
            return 2
        }
        if tableView == self.scoreTableView {
            return 1
        }
        
        return self.goodsCellTypes.count
    }
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if tableView == self.secondTableView {
            return 10
        }
        //scoreTable的”好评率“
        if tableView == self.scoreTableView {
            return 60
        }
        
        let cellType = self.goodsCellTypes[section]
        switch cellType {
        case .HomeContentTypeAd :
            return 0
        case .HomeContentTypeLoadMore :
            return 0
        default :
            return 16
        }
    }
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return  0
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if self.scoreTableView != nil && tableView == self.scoreTableView {
            return 40   //tmpCell,没有评论时
            //            return 325 //CommentViewCell
        }
        if tableView == self.secondTableView {
            return indexPath.section == 0 ? 60 : kScreenHeight - 64 - 80 - 58
        }
        
        let cellType = self.goodsCellTypes[indexPath.section]
        switch cellType {
        case .HomeContentTypeAd :
            return kScreenWidth
        case .HomeContentTypeDetail :
            return 122
        case .HomeContentTypeMenu :
            return ZMDProductAttrView.getHeight(self.productDetail) + 60
        case .HomeContentTypeDistribution :
            return 106
        case .HomeContentTypeStore :
            //            return 120
            return 60 //暂时隐藏店铺活动部分
        case .HomeContentTypeDaPeiGou :
            return 60 + 144 + 56
        case .HomeContentTypeLoadMore :
            return 40
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //secondTableView的ScoreCell上的scoreTableView的delegate(页面中的第三个tableView)
        if tableView == self.scoreTableView{
            let tmpCell = UITableViewCell(style: .Default, reuseIdentifier: "tmpCell")
            tmpCell.selectionStyle = .None
            tmpCell.textLabel?.textColor = RGB(79,79,79,1.0)
            tmpCell.textLabel?.textAlignment = .Left
            tmpCell.textLabel?.text = "这是第一次检讨此商品!"
            return tmpCell
        }
        
        //第二个table
        if tableView == self.secondTableView {
            switch self.secondCellType {
            case .SecondDetail:
                if indexPath.section == 0 {
                    return cellForHomeNextMenu(tableView, indexPath: indexPath)
                } else {
                    return cellImageTextForSecond(tableView, indexPath: indexPath)
                }
            case .SecondScore:
                if indexPath.section == 0 {
                    return cellForHomeNextMenu(tableView, indexPath: indexPath)
                } else {
                    return cellScoreForSecond(tableView, indexPath: indexPath)
                }
            default:
                if indexPath.section == 0 {
                    return cellForHomeNextMenu(tableView, indexPath: indexPath)
                } else {
                    return cellParmForSecond(tableView, indexPath: indexPath)
                }
            }
        }
        
        //第一个table
        let cellType = self.goodsCellTypes[indexPath.section]
        switch cellType {
        case .HomeContentTypeAd :
            return cellForHomeAd(tableView, indexPath: indexPath)
        case .HomeContentTypeDetail :
            return cellForHomeDetail(tableView, indexPath: indexPath)
        case .HomeContentTypeMenu :
            return cellForHomeMenu(tableView, indexPath: indexPath)
        case .HomeContentTypeDistribution :
            return cellForHomeDistribution(tableView, indexPath: indexPath)
        case .HomeContentTypeStore :
            return cellForHomeStore(tableView, indexPath: indexPath)
        case .HomeContentTypeDaPeiGou :
            return cellForHomeDapeigou(tableView, indexPath: indexPath)
        case .HomeContentTypeLoadMore :
            return cellForHomeLoadMore(tableView,indexPath: indexPath)
        }
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if tableView == self.scoreTableView{
            let view = UIView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 61))
            view.backgroundColor = UIColor.whiteColor()
            
            let percentLabel = ZMDTool.getLabel(CGRect(x: 0, y: 0, width: kScreenWidth * 1 / 3, height: 60), text: "好评率: 0%", fontSize: 15)
            percentLabel.textAlignment = .Center
            percentLabel.attributedText = percentLabel.text?.AttributedMutableText([percentLabel.text!,"0%"], colors: [defaultTextColor,.redColor()])
            view.addSubview(percentLabel)
            
            let allBtn = ZMDTool.getButton(CGRect(x: kScreenWidth/2 + 5 , y: 15, width: (kScreenWidth/2 - 20)/2, height: 30), textForNormal: "全部 (0)", fontSize: 15, backgroundColor: .whiteColor(), blockForCli: { (sender) -> Void in
                
            })
            let attributeString = allBtn.titleLabel?.text?.AttributeText(["全部"," (0)"], colors: [defaultTextColor,UIColor.lightGrayColor()], textSizes: [15,13])
            allBtn.titleLabel?.attributedText = attributeString
            ZMDTool.configViewLayer(allBtn)
            ZMDTool.configViewLayerFrameWithColor(allBtn, color: UIColor.darkGrayColor())
            view.addSubview(allBtn)
            
            let imgBtn = ZMDTool.getButton(CGRect(x: CGRectGetMaxX(allBtn.frame) + 10, y: 15, width: CGRectGetWidth(allBtn.frame), height: 30), textForNormal: "晒图", fontSize: 15, backgroundColor: .whiteColor(), blockForCli: { (sender) -> Void in
                
            })
            ZMDTool.configViewLayer(imgBtn)
            ZMDTool.configViewLayerFrameWithColor(imgBtn, color: UIColor.darkGrayColor())
            view.addSubview(imgBtn)
            
            let line = ZMDTool.getLine(CGRect(x: 0, y: 60, width: kScreenWidth, height: 1))
            view.addSubview(line)
            return view
        }
        return nil
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cellType = self.goodsCellTypes[indexPath.section]
        switch cellType {
        case .HomeContentTypeStore :
            let vc = StoreShowHomeViewController.CreateFromMainStoryboard() as! StoreShowHomeViewController
            vc.storeId = self.productDetail.Store.Id
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
        default :
            break
        }
    }
    //MARK: - scrollView
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView != self.currentTableView {
            return
        }
        var alaph = (scrollView.contentOffset.y) / 150.0
        alaph = alaph > 1 ? 1 : alaph
        if alaph > 0.5 {
            self.setupNavigation()
        }else{
            self.setupNavigationWithBg()
        }
        if self.navBackView != nil {
            if alaph == 0 {
                self.navLine.hidden = true
            } else {
                self.navLine.alpha = alaph
                self.navLine.hidden = false
            }
            self.navBackView.alpha = alaph
        }
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        if let cell = self.currentTableView.visibleCells.last {
            if cell.reuseIdentifier == "loadMoreCell" {
                self.currentTableView.mj_footer.hidden = false
            } else {
                self.currentTableView.mj_footer.hidden = true
            }
        }
    }
    
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
    
    //MARK: - ****************TableViewCell****************
    //MARK: Second cell
    func cellImageTextForSecond(tableView:UITableView,indexPath:NSIndexPath)-> UITableViewCell {
        let cellId = "SecondImageTextCell"
        var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
        if cell == nil{
            cell = UITableViewCell(style: .Default, reuseIdentifier: cellId)
            cell!.selectionStyle = .None
            cell!.contentView.backgroundColor = UIColor.grayColor()
            
            let height = kScreenHeight - 64 - 80 - 58
            //加载图文详情
            let wkUController = WKUserContentController()
            let jScript = "var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width'); document.getElementsByTagName('head')[0].appendChild(meta);"
            let wkUScript = WKUserScript(source: jScript, injectionTime: .AtDocumentEnd, forMainFrameOnly: true)
            wkUController.addUserScript(wkUScript)
            let wkWebConfig = WKWebViewConfiguration()
            wkWebConfig.userContentController = wkUController
            
            let webView = WKWebView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: height), configuration: wkWebConfig)
            webView.scrollView.showsVerticalScrollIndicator = false
            cell?.contentView.addSubview(webView)
            self.updateDetailView(webView)
        }
        return cell!
    }
    
    func cellScoreForSecond(tableView:UITableView,indexPath:NSIndexPath)-> UITableViewCell {
        let cellId = "SecondScoreCell"
        var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
        if cell == nil{
            cell = UITableViewCell(style: .Default, reuseIdentifier: cellId)
            cell?.selectionStyle = .None
            cell?.contentView.backgroundColor = UIColor.whiteColor()
            
            let height = kScreenHeight - 64 - 80 - 58
            self.scoreTableView = UITableView(frame: CGRectMake(0, 0, kScreenWidth, height), style: UITableViewStyle.Plain)
            cell?.contentView.addSubview(self.scoreTableView)
            
            scoreTableView.delegate = self
            scoreTableView.dataSource = self
        }
        return cell!
    }
    
    func cellParmForSecond(tableView:UITableView,indexPath:NSIndexPath)->UITableViewCell {
        let cellId = "ParmSecondCell"
        var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
        if cell == nil{
            cell = UITableViewCell(style: .Default, reuseIdentifier: cellId)
            cell?.selectionStyle = .None
            cell?.contentView.backgroundColor =  UIColor.whiteColor()
            
            let height = kScreenHeight - 64 - 80 - 58
            let parmView = UIView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: height))
            parmView.backgroundColor = defaultBackgroundGrayColor
        }
        return cell!
    }
    
    func updateDetailView(webView:WKWebView) {
        let urlString = kImageAddressMain + "/product/ProductDetailview?productId=\(self.productId)"
        let requeset = NSURLRequest(URL: NSURL(string: urlString)!)
        webView.loadRequest(requeset)
    }
    //MARK:  secondTable 的菜单选择cell
    func cellForHomeNextMenu(tableView: UITableView,indexPath: NSIndexPath)-> UITableViewCell {
        let cellId = "NextMenuCell"
        var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
        if cell == nil {
            cell = UITableViewCell(style: .Default, reuseIdentifier: cellId)
            cell!.selectionStyle = .None
            cell!.contentView.backgroundColor = UIColor.whiteColor()
            cell?.addSubview(self.createFilterMenu())
        }
        return cell!
    }
    
    func cellForSecond(tableView: UITableView,indexPath: NSIndexPath)-> UITableViewCell {
        let cellId = "testCell"
        var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
        if cell == nil {
            cell = UITableViewCell(style: .Default, reuseIdentifier: cellId)
            cell!.selectionStyle = .None
            cell!.contentView.backgroundColor = UIColor.whiteColor()
            
            let nibView = NSBundle.mainBundle().loadNibNamed("CommentView", owner: nil, options: nil) as NSArray
            let remarkV = nibView.objectAtIndex(0) as? UIView
            remarkV!.frame = CGRectMake(0,0, kScreenWidth, 325)
            cell?.contentView.addSubview(remarkV!)
        }
        return cell!
    }
    
    //MARK: scoreTableView的cell
    func cellForScoreTableView(tableView: UITableView,indexPath: NSIndexPath)-> UITableViewCell {
        let cellId = "scoreCell"
        var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
        if cell == nil {
            cell = UITableViewCell(style: .Default, reuseIdentifier: cellId)
            cell?.selectionStyle = .None
            let scoreView = NSBundle.mainBundle().loadNibNamed("CommentView", owner: nil, options: nil).first as! UIView
            cell?.contentView.addSubview(scoreView)
        }
        return cell!
    }
    
    //MARK: 广告 cell
    func cellForHomeAd(tableView: UITableView,indexPath: NSIndexPath)-> UITableViewCell {
        let cellId = "productImgCell"
        var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
        if cell == nil {
            cell = UITableViewCell(style: .Default, reuseIdentifier: cellId)
            cell!.selectionStyle = .None
            cell!.contentView.backgroundColor = UIColor.whiteColor()
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
            let cycleScroll = CycleScrollView(frame: CGRectMake(0, 0, kScreenWidth, kScreenWidth))
            cycleScroll.tag = 10001
            cycleScroll.backgroundColor = UIColor.clearColor()
            //            cycleScroll.delegate = self
            cycleScroll.autoScroll = true
            cycleScroll.autoTime = 2.5
            if arr.count != 0 {
                cycleScroll.urlArray = arr as [AnyObject]
            }
            cell?.addSubview(cycleScroll)
        }
        return cell!
    }
    //MARK: 商品详请 cell
    func cellForHomeDetail(tableView: UITableView,indexPath: NSIndexPath)-> UITableViewCell {
        let cellId = "detailCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellId) as! ContentTypeDetailCell
        if self.productDetail != nil {
            ContentTypeDetailCell.configProductDetailCell(cell, product: self.productDetail)
        }
        return cell
    }
    //MARK: 商品购买选项 cell(购买数量、颜色尺寸)
    func cellForHomeMenu(tableView: UITableView,indexPath: NSIndexPath)-> UITableViewCell {
        let cellId = "menuOtherCell"
        var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
        if cell == nil {
            cell = UITableViewCell(style: .Default, reuseIdentifier: cellId)
            cell!.selectionStyle = .None
            cell!.contentView.backgroundColor = UIColor.whiteColor()
        }
        if self.view.viewWithTag(kTagEditViewShow) == nil {
            let editView = self.editViewShow(self.productDetail, SciId: 0)
            cell!.contentView.addSubview(editView)
        }
        return cell!
    }
    
    func editViewShow(productDetail:ZMDProductDetail,SciId:Int) -> UIView {
        let editView = UIView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: ZMDProductAttrView.getHeight(productDetail) + 60))
        editView.tag = kTagEditViewShow
        editView.backgroundColor = UIColor.whiteColor()
        
        productAttrV = ZMDProductAttrView(frame: CGRect.zero, productDetail: productDetail)
        productAttrV.SciId = SciId
        productAttrV.frame = CGRectMake(0, 0,kScreenWidth, productAttrV.getHeight())
        editView.addSubview(productAttrV)
        
        let countView = CountView(frame: CGRect(x: kScreenWidth - 12 - 120, y: CGRectGetMaxY(productAttrV.frame) + 10, width: 120, height: 40))
        countView.theMaxNumber = self.responsitoryNumber
        countView.finished = {(count)->Void in
            self.countForBounght = count
        }
        countView.countForBounght = 1
        countView.updateUI()
        editView.addSubview(countView)
        
        let countLbl = UILabel(frame: CGRect(x: 12, y: CGRectGetMaxY(productAttrV.frame), width: 200, height: 60))
        let kucunText = "（库存量: \(self.responsitoryNumber)）"
        var countText = "购买数量\(kucunText)"
        countText = "购买数量"
        countLbl.attributedText = countText.AttributedMutableText(["购买数量",countText], colors: [defaultTextColor,defaultDetailTextColor])
        countLbl.font = defaultSysFontWithSize(16)
        editView.addSubview(countLbl)
        return editView
    }
    //MARK: 配送 cell HomeContentTypeDistribution
    func cellForHomeDistribution(tableView: UITableView,indexPath: NSIndexPath)-> UITableViewCell {
        let cellId = "DistributionCell"
        var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
        if cell == nil {
            cell = UITableViewCell(style: .Default, reuseIdentifier: cellId)
            cell!.selectionStyle = .None
            cell!.contentView.backgroundColor = UIColor.whiteColor()
            let label = UILabel(frame: CGRect(x: 12, y: 24, width: 200, height: 40))
            label.text = "配送"
            label.textColor = defaultTextColor
            label.font = defaultSysFontWithSize(17)
            cell?.contentView.addSubview(label)
            let size = "配送".sizeWithFont(label.font, maxWidth: 100)
            let detailLbl = UILabel(frame: CGRect(x: 12 + size.width + 20, y: 24, width: kScreenWidth - (12 + size.width + 20) - 20 , height: 60))
            detailLbl.numberOfLines = 0
            let store = self.productDetail.Store
            let storeName = store.Name == nil ? "---" : store.Name
            let deliveryTime = self.productDetail.DeliveryTimeName ?? "3-6个工作日"
            if storeName == nil {
                detailLbl.text = "商品下单后预计\(deliveryTime)送达"
            }else{
                detailLbl.text = "此商品由 \(storeName) 发货,预计下单后\(deliveryTime)送达"
            }
            
            detailLbl.textColor = defaultDetailTextColor
            detailLbl.font = defaultSysFontWithSize(16)
            detailLbl.attributedText = detailLbl.text?.AttributeText([storeName,deliveryTime], colors: [defaultTextColor,defaultTextColor], textSizes: [16,16])
            cell?.contentView.addSubview(detailLbl)
        }
        return cell!
    }
    //MARK: 店家 cell
    func cellForHomeStore(tableView: UITableView,indexPath: NSIndexPath)-> UITableViewCell {
        let cellId = "storeCell"
        var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
        if cell == nil {
            cell = UITableViewCell(style: .Default, reuseIdentifier: cellId)
            cell!.selectionStyle = .None
            cell!.contentView.backgroundColor = UIColor.whiteColor()
        }
        (cell?.viewWithTag(100) as! UIButton).rac_command = RACCommand(signalBlock: { (sender) -> RACSignal! in
            //展开店铺活动全部信息
            
            return RACSignal.empty()
        })
        (cell?.viewWithTag(200) as!UILabel).text = self.productDetail.Store.Name
        return cell!
    }
    //MARK: 搭配购 cell
    func cellForHomeDapeigou(tableView: UITableView,indexPath: NSIndexPath)-> UITableViewCell {
        let cellId = "dapeigouCell"
        var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
        if cell == nil {
            cell = UITableViewCell(style: .Default, reuseIdentifier: cellId)
            cell!.selectionStyle = .None
            cell!.contentView.backgroundColor = UIColor.whiteColor()
        }
        if self.productDetail != nil && self.productDetail.BundledItems != nil {
            let datas = self.productDetail.BundledItems!
            if let scrollView = cell?.viewWithTag(10001) as? UIScrollView {
                var i = 0
                var scrollvWidth = CGFloat(0)
                for bundledItem in datas {
                    var x = 0
                    if i == 0 {
                        x = 12
                    } else {
                        x = 12 + 80 + (36 + 80) * (i-1)
                        let addLbl = UILabel(frame: CGRect(x: x, y: 46, width: 36, height: 15))
                        addLbl.textColor = UIColor.blackColor()
                        addLbl.text = "+"
                        addLbl.textAlignment = .Center
                        addLbl.font = defaultSysFontWithSize(15)
                        scrollView.addSubview(addLbl)
                    }
                    //主
                    if i > 0 {
                        x += 36
                    }
                    let view = UIView(frame: CGRect(x: x, y: 0, width: 80, height: 144))
                    let imgV = UIImageView(frame: CGRect(x: 0, y: 12, width: 80, height: 80))
                    if let pictureModel = bundledItem.DetailsPictureModel?.DefaultPictureModel {
                        let imgUrl = kImageAddressMain + (pictureModel.ImageUrl ?? "")
                        imgV.sd_setImageWithURL(NSURL(string: imgUrl)!)
                    }
                    view.addSubview(imgV)
                    
                    let priceLbl = UILabel(frame: CGRect(x: 0, y: 144 - 12 - 13, width: 80, height: 13))
                    if let productPrice = bundledItem.ProductPrice {
                        priceLbl.text = "原价:\(productPrice.OldPrice ?? "")"
                    }
                    priceLbl.textColor = defaultTextColor
                    priceLbl.font = defaultSysFontWithSize(12)
                    view.addSubview(priceLbl)
                    
                    let titleLbl = UILabel(frame: CGRect(x: 0, y: 144 - 12 - 13 - 8 - 12, width: 80, height: 12))
                    titleLbl.text = bundledItem.Name
                    titleLbl.textAlignment = .Center
                    titleLbl.textColor = defaultDetailTextColor
                    titleLbl.font = defaultSysFontWithSize(12)
                    //                    titleLbl.adjustsFontSizeToFitWidth = true
                    view.addSubview(titleLbl)
                    scrollView.addSubview(view)
                    i++
                    if i == datas.count-1 {
                        scrollvWidth = CGRectGetMaxX(view.frame) + 80 + 12
                    }
                    scrollView.contentSize = CGSize(width: scrollvWidth, height: 0)
                }
            }
            let textArray = ["组合价：","613.00","（已为你节省：100)"]
            let label = TYAttributedLabel(frame: CGRect(x: 12, y: 207 + 15, width: kScreenWidth - 24, height: 22))
            label.textColor = defaultTextColor
            label.backgroundColor = UIColor.clearColor()
            label.font = defaultSysFontWithSize(15)
            label.textAlignment = .Left
            label.characterSpacing = 0
            let colors = [defaultTextColor,UIColor.redColor(),defaultDetailTextColor]
            var i = 0
            for text in textArray {
                let attributedStr = NSMutableAttributedString(string: text)
                attributedStr.addAttributeTextColor(colors[i])
                attributedStr.addAttributeFont(defaultSysFontWithSize(15))
                label.appendTextAttributedString(attributedStr)
                i++
            }
            cell?.contentView.addSubview(label)
        }
        return cell!
    }
    
    func cellForHomeLoadMore(tableView:UITableView,indexPath:NSIndexPath)->UITableViewCell{
        let cellId = "loadMoreCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellId)
        let btn = cell?.contentView.viewWithTag(100) as! UIButton
        btn.rac_command = RACCommand(signalBlock: { (sender) -> RACSignal! in
            self.footerRefresh()
            return RACSignal.empty()
        })
        return cell!
    }
    //MARK:第二个table的menu
    func createFilterMenu() -> UIView{
        let titles = ["图文详情","评分","产品参数"]
        var btnArr = NSMutableArray()
        let view = UIView(frame: CGRectMake(0 , 0, kScreenWidth, 60))
        for var i=0;i<titles.count;i++ {
            let btn = UIButton(frame:  CGRectMake(CGFloat(i) * kScreenWidth/3 , 0, kScreenWidth/3-3, 60))
            //默认第一个是selected
            if i == 0 {
                btn.selected = true
            }
            btn.backgroundColor = UIColor.clearColor()
            btn.setTitle(titles[i], forState: .Normal)
            btn.setTitle(titles[i], forState: .Normal)
            btn.setTitleColor(RGB(79,79,79,1.0), forState: .Normal)
            btn.setTitleColor(defaultSelectColor, forState: .Selected)
            btn.titleLabel?.font = UIFont.systemFontOfSize(17)
            btn.tag = 1000 + i
            btnArr.addObject(btn)
            view.addSubview(btn)
            
            if i < 2{
                let lineView = UIView(frame: CGRectMake(CGFloat(i + 1) * kScreenWidth/3, 18, 1, 21))
                lineView.backgroundColor = defaultLineColor
                view.addSubview(lineView)
            }
            
            btn.rac_signalForControlEvents(.TouchUpInside).subscribeNext({ (sender) -> Void in
                let btnClicked = sender as! UIButton
                self.secondCellType = [SecondCellType.SecondDetail,.SecondScore,.SecondParameter][btnClicked.tag - 1000]
                for btn in btnArr {
                    let theBtn = btn as! UIButton
                    if btnClicked.titleLabel?.text != theBtn.titleLabel?.text {
                        theBtn.selected = false
                    }else{
                        theBtn.selected = true
                    }
                }
                self.secondTableView.reloadData()
            })
        }
        return view
    }
    //MARK:第二个table的navigation
    func setupNavigation() {
        let item = UIBarButtonItem(image: UIImage(named: "Navigation_Back")!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate), style: UIBarButtonItemStyle.Done, target: self, action: Selector("back"))
        item.customView?.tintColor = UIColor.whiteColor()
        self.navigationItem.leftBarButtonItem = item
        let rightItem: UIBarButtonItem
        if self.isCollected {
            //收藏状态下的rightItem
            rightItem = UIBarButtonItem(image: UIImage(named: "product_collect_04")!.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal), style: UIBarButtonItemStyle.Done, target: self, action: Selector("collect"))
        }else{
            rightItem = UIBarButtonItem(image: UIImage(named: "product_collect_03")!.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal), style: UIBarButtonItemStyle.Done, target: self, action: Selector("collect"))
        }
        rightItem.customView?.tintColor = UIColor.whiteColor()
        self.navigationItem.rightBarButtonItem = rightItem
    }
    
    //MARK:第一个table的navigation
    func setupNavigationWithBg() {
        let item = UIBarButtonItem(image: UIImage(named: "product_return")!.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal), style: UIBarButtonItemStyle.Done, target: self, action: Selector("back"))
        item.customView?.tintColor = UIColor.whiteColor()
        self.navigationItem.leftBarButtonItem = item
        
        let rightItem: UIBarButtonItem
        if self.isCollected {
            //收藏状态下的rightItem
            rightItem = UIBarButtonItem(image: UIImage(named: "product_collect_02")!.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal), style: UIBarButtonItemStyle.Done, target: self, action: Selector("collect"))
        }else{
            rightItem = UIBarButtonItem(image: UIImage(named: "product_collect_01")!.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal), style: UIBarButtonItemStyle.Done, target: self, action: Selector("collect"))
        }
        rightItem.customView?.tintColor = UIColor.whiteColor()
        self.navigationItem.rightBarButtonItem = rightItem
    }
    private func dataInit(){
        //        if self.productDetail.Store.discount == nil {
        //            self.goodsCellTypes = [.HomeContentTypeAd,.HomeContentTypeDetail,.HomeContentTypeMenu,.HomeContentTypeDistribution,.HomeContentTypeStore,/*.HomeContentTypeDaPeiGou*/.HomeContentTypeLoadMore]
        //        }
        self.goodsCellTypes = [.HomeContentTypeAd,.HomeContentTypeDetail,.HomeContentTypeMenu,.HomeContentTypeDistribution,.HomeContentTypeStore,/*.HomeContentTypeDaPeiGou*/.HomeContentTypeLoadMore]
        
        QNNetworkTool.fetchProductDetail(self.productId) { (productDetail, error, dictionary) -> Void in
            if productDetail != nil {
                self.productDetail = productDetail
                if self.productDetail.ProductType?.integerValue == 15 {
                    // 如果ProductType==15，有搭配产品，table的结构就如下：
                    self.goodsCellTypes = [.HomeContentTypeAd,.HomeContentTypeDetail,.HomeContentTypeMenu,.HomeContentTypeDistribution,.HomeContentTypeStore,.HomeContentTypeDaPeiGou]
                }
                self.currentTableView.reloadData()
                //当用户登录状态下，才判断这些商品是否收藏
                if g_customerId != nil {
                    //请求数据完成后判断是否已经收藏
                    self.wheatherCollected()
                }
                //MARK:如果productAttrV还没显示出来就点击"加入购物车",会通过productAttr->getPostData得到参数，而productAttr为nil，会crash
                if self.productAttrV == nil {
                    self.editViewShow(self.productDetail, SciId: 0)
                }
            } else {
                ZMDTool.showErrorPromptView(nil, error: nil, errorMsg: error)
            }
        }
    }
    //在第一个table上拉刷新
    func footerRefresh(){
        UIView.animateWithDuration(0.38, animations: { () -> Void in
            var frame = self.currentTableView.frame
            //第一个table顶部是超出了64的，所以secondTable要+64
            frame.origin = CGPoint(x: 0, y: frame.origin.y + 64)
            frame.size = CGSizeMake(kScreenWidth, kScreenHeight - 64 - 58)
            self.secondTableView.frame = frame
            frame.origin = CGPoint(x: 0, y: frame.origin.y - frame.size.height - 64)
            self.currentTableView.frame = frame
            }, completion: { (bool) -> Void in
                self.currentTableView.mj_footer.endRefreshing()
                self.setupNavigation()
                if self.navBackView != nil {
                    self.navLine.hidden = false
                    self.navBackView.backgroundColor = UIColor.whiteColor()
                    self.navBackView.alpha = 1.0
                }
                let btn = self.view.viewWithTag(10000)
                self.view.bringSubviewToFront(btn!)
        })
        self.isSecondTableView = true
    }
    // 在第二个table下拉刷新
    func headerRefresh(){
        UIView.animateWithDuration(0.38, animations: { () -> Void in
            var frame = self.secondTableView.frame
            frame.origin = CGPoint(x: 0, y: frame.origin.y - 64)
            frame.size = CGSizeMake(kScreenWidth, kScreenHeight - 64)
            self.currentTableView.frame = CGRect(x: 0, y: -64, width: kScreenWidth, height: kScreenHeight-64)
            self.currentTableView.contentOffset = CGPoint(x: 0, y: 0)
            frame.origin = CGPoint(x: 0, y: 64 + frame.size.height)
            self.secondTableView.frame = frame
            }, completion: { (bool) -> Void in
                self.secondTableView.mj_header.endRefreshing()
                self.currentTableView.mj_footer.hidden = true
        })
        self.isSecondTableView = false
    }
    
    func getResponsitoryNubmer() {
        QNNetworkTool.fetchRepositoryNumber(self.productId) { (number, error) in
            if let number = number {
                self.responsitoryNumber = number
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
        
        // 底部刷新
        let footer = MJRefreshAutoNormalFooter()
        // 顶部刷新
        let header = MJRefreshNormalHeader()
        footer.setRefreshingTarget(self, refreshingAction: Selector("footerRefresh"))
        header.setRefreshingTarget(self, refreshingAction: Selector("headerRefresh"))
        
        self.currentTableView.backgroundColor  = tableViewdefaultBackgroundColor
        self.currentTableView.mj_footer = footer
        self.currentTableView.mj_footer.hidden = true
        
        self.bottomV.backgroundColor = RGB(247,247,247,1)
        
        secondTableView = UITableView(frame: CGRect(x: 0, y: CGRectGetMaxY(self.currentTableView.frame) + 100, width: kScreenWidth, height: self.currentTableView.frame.size.height))
        secondTableView.separatorStyle = .None
        secondTableView.dataSource = self
        secondTableView.delegate = self
        self.view.addSubview(secondTableView)
        self.secondTableView.mj_header = header
        self.secondTableView.reloadData()
        
        scoreTableView = UITableView(frame: CGRectZero)
        
        let titles = ["咨询","分享赚佣金","加入购物车"]
        var i = 0
        let colorsBg = [UIColor.clearColor(),RGB(225,188,42,1),RGB(232,61,60,1)]
        for title in titles {
            //加入购物车
            let bottomBtn = UIButton(frame: CGRect(x: kScreenWidth/3 * CGFloat(i) + 18, y: 12, width: kScreenWidth/3 - 30, height: 34))
            bottomBtn.backgroundColor = UIColor.clearColor()
            bottomBtn.setTitle(title, forState: .Normal)
            if kScreenHeightZoom <= 1 {
                bottomBtn.titleLabel?.font = defaultSysFontWithSize(14)
            }else{
                bottomBtn.titleLabel?.font = defaultSysFontWithSize(17)
            }
            bottomBtn.backgroundColor = colorsBg[i]
            bottomBtn.tag = 1000 + i
            if i == 0 {
                bottomBtn.setTitleColor(defaultTextColor, forState: .Normal)
                bottomBtn.setImage(UIImage(named: "product_chat"), forState: .Normal)
            } else {
                ZMDTool.configViewLayer(bottomBtn)
                bottomBtn.setTitleColor(UIColor.whiteColor(), forState: .Normal)
            }
            bottomBtn.rac_signalForControlEvents(.TouchUpInside).subscribeNext({ [weak self](sender) -> Void in
                if (sender as! UIButton).titleLabel!.text == titles[0] {
                    //咨询dsd
                    ZMDTool.showPromptView("该功能暂未开放")
                } else if (sender as! UIButton).titleLabel?.text == titles[1] {
                    //分享赚佣金
                    if let strongSelf = self {
                        //                        let shareView = ShareView()
                        //                        shareView.delegate = strongSelf
                        //shareView.showShareView()
                        ZMDShareSDKTool.shareWithMenu(strongSelf.view)
                    }
                } else if (sender as! UIButton).titleLabel?.text == titles[2] {
                    //MARK:加入购物车
                    if let strongSelf = self,productAttrV = strongSelf.productAttrV {
                        if !g_isLogin {
                            strongSelf.commonAlertShow(true, title: "提示:未登录!", message: "是否立即登录?", preferredStyle: .Alert)
                            return
                        }
                        var postDic = productAttrV.getPostData(strongSelf.countForBounght,IsEdit: false)
                        if productAttrV.isAllSelected == false {
                            ZMDTool.showPromptView("请选择商品属性!")
                            strongSelf.currentTableView.contentOffset = CGPoint(x: 0, y: 40)
                        }
                        if postDic == nil {
                            return
                        }
                        postDic!.setValue(strongSelf.productDetail.Id.integerValue, forKey: "Id")
                        postDic!.setValue(1, forKey: "CartType")
                        ZMDTool.showActivityView(nil)
                        QNNetworkTool.fetchShoppingCart(1, completion: { (shoppingItems, dictionary, error) -> Void in
                            var count = 0
                            var theShoppingItem: ZMDShoppingItem!
                            for item in shoppingItems! {
                                let shoppingItem = item as! ZMDShoppingItem
                                if shoppingItem.ProductId == strongSelf.productDetail.Id {
                                    theShoppingItem = shoppingItem
                                    break
                                }
                                count++
                            }
                            if count == shoppingItems?.count {
                                //购物车中没有将要添加的商品，添加商品
                                QNNetworkTool.addProductToCart(postDic!, completion: { (succeed, dictionary, error) -> Void in
                                    ZMDTool.hiddenActivityView()
                                    if succeed! {
                                        strongSelf.getShoppingCartNumber()
                                        ZMDTool.showPromptView("添加成功")
                                    }else {
                                        ZMDTool.showPromptView("添加失败")
                                    }
                                })
                            }else{
                                //购物车中已有将要添加的商品，修改商品
                                postDic = strongSelf.productAttrV.getPostData(strongSelf.countForBounght, IsEdit: true)
                                postDic?.setValue(theShoppingItem.Id.integerValue, forKey: "SciId")
                                postDic?.setValue(NSNumber(int:theShoppingItem.Quantity.intValue + strongSelf.countForBounght), forKey: "Quantity")
                                postDic?.setValue(1, forKey: "carttype")
                                
                                QNNetworkTool.editCartItemAttribute(postDic!, completion: { (succeed, dictionary, error) -> Void in
                                    ZMDTool.hiddenActivityView()
                                    if succeed!{
                                        strongSelf.getShoppingCartNumber()
                                        ZMDTool.showPromptView("添加成功")
                                    }else{
                                        ZMDTool.showPromptView("添加失败")
                                    }
                                })
                            }
                        })
                    }
                }
                })
            self.bottomV.addSubview(bottomBtn)
            //暂时隐藏咨询和分享
            //isIn是Int的extension，判断int型的值是否在某个范围中
            if i.isIn([0]){
                bottomBtn.hidden = true
            }else{
                bottomBtn.set("x", value: 12)
                bottomBtn.set("w", value: kScreenWidth-2*12)
            }
            i++
        }
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
            self.refreshNavigation()
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
                            self.refreshNavigation()
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
                                self.refreshNavigation()
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
    
    func refreshNavigation() {
        //收藏(取消收藏)完成，改变导航栏的rightItem(根据isSecondTableView选择方法)
        if self.isSecondTableView == false {
            self.setupNavigationWithBg()
        }else{
            self.setupNavigation()
        }
    }
    
    //MARK:-alertDestructiveAction 重写
    override func alertDestructiveAction() {
        let vc = LoginViewController.CreateFromLoginStoryboard() as! LoginViewController
        self.pushToViewController(vc, animated: true, hideBottom: true)
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
        
        cell.isFreeLbl.font = UIFont.systemFontOfSize(16)
        cell.soldCountLbl.font = UIFont.systemFontOfSize(16)
        if product.IsFreeShipping?.integerValue == 1 {
            cell.isFreeLbl.attributedText = "是否免邮: 包邮".AttributedMutableText(["是否包邮:","包邮"], colors: [defaultTextColor,defaultSelectColor])
            cell.soldCountLbl.text = "销售量:  \(product.Sold.integerValue)件"
        }else{
            cell.isFreeLbl.text = "销售量:  \(product.Sold.integerValue)件"
            cell.soldCountLbl.text = ""
        }
    }
}
