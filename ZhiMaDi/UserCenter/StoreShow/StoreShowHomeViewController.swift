//
//  StoreShowHomeViewController.swift
//  ZhiMaDi
//
//  Created by haijie on 16/4/20.
//  Copyright © 2016年 ZhiMaDi. All rights reserved.
//

import UIKit
import ReactiveCocoa
// 店铺首页
class StoreShowHomeViewController: UIViewController, ZMDInterceptorProtocol,ZMDInterceptorMoreProtocol, UITableViewDataSource, UITableViewDelegate,UISearchBarDelegate {
    enum StoreHomeCellType {
        case Head
        case Notice
        case Discount
        case Coupon
        case Recommend
        case Other
        var height : CGFloat {
            switch self {
            case Head:
                return 360/750 * kScreenWidth
            case Notice:
                return 45
            case Discount:
                return 85
            case Coupon:
                return 260/750 * kScreenWidth
            case Recommend:
                return 325
            default:
                return 0
            }
        }
        func heightForSection(section : Int) -> CGFloat {
            switch section {
            case 2 :
                return 46
            case 0 :
                return 0
            default :
                return 16
            }
        }
        func viewForSection(section : Int) -> UIView {
            switch section {
            case 2 :
                let headView = UIView(frame: CGRectMake(0, 0, kScreenWidth, 10))
                headView.backgroundColor = tableViewdefaultBackgroundColor
                let line = UIView(frame: CGRect(x: 12, y: 14, width: 5, height: 20))
                line.backgroundColor = RGB(235,61,61,1.0)
                headView.addSubview(line)
                let titleLbl = ZMDTool.getLabel(CGRect(x: CGRectGetMaxX(line.frame)+10, y: 15, width: 70, height: 15), text: "本店热卖", fontSize: 15)
                headView.addSubview(titleLbl)
                let hotLbl = ZMDTool.getLabel(CGRect(x: CGRectGetMaxX(titleLbl.frame), y: 16, width: 32, height: 16), text: "HOT", fontSize: 10,textColor: UIColor.whiteColor(),textAlignment: .Center)
                hotLbl.backgroundColor = RGB(235,61,61,1.0)
                headView.addSubview(hotLbl)
                return headView
            default :
                let headView = UIView(frame: CGRectMake(0, 0, kScreenWidth, 16))
                headView.backgroundColor = UIColor.clearColor()
                return headView
            }
        }
    }
    
    @IBOutlet weak var currentTableView: UITableView!
    
    let kServerAddress = "http://www.xjnongte.com"
    
    var isNoticeDetail = false  //noticeCell是否全部显示
    var storeId:NSNumber!
    var celltypes = [[StoreHomeCellType.Head/*,.Notice*//*,.Discount*/],/*[.Coupon],*/[.Recommend,.Recommend]]
    let kTagPageControl = 10001
    let kTagScrollView = 10002
    
    var indexSkip = 0
    var productsArray = NSMutableArray()
    var storeDetail:ZMDStoreDetail!
    var availableCategories = NSArray() //临时用
    override func viewDidLoad() {
        super.viewDidLoad()
        self.currentTableView.backgroundColor = tableViewdefaultBackgroundColor
        self.currentTableView.bounces = false
        
        self.dataInit()
        self.requestData()
        self.setupNewNavigation()
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
//        self.currentTableView.reloadData()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK:- UITableViewDataSource,UITableViewDelegate
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.celltypes[section].first == .Recommend {
            return self.productsArray.count/2 + self.productsArray.count%2
        }
        return  self.celltypes[section].count
    }
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.celltypes.count
    }
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
       return StoreHomeCellType.Other.heightForSection(section)
    }
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 1 {
            return 0.5
        }else{
            return 0
        }
    }
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return StoreHomeCellType.Other.viewForSection(section)
    }
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 0.5))
        view.backgroundColor = defaultLineColor
        return view
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if self.isNoticeDetail && indexPath.section == 0 && indexPath.row == 1 {
            return 60
        }
        if self.celltypes[indexPath.section].first == .Recommend{
            return 325
        }
        return self.celltypes[indexPath.section][indexPath.row].height
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var celltype:StoreHomeCellType
        if self.celltypes[indexPath.section].first == .Recommend {
            celltype = .Recommend
        }else{
            celltype = self.celltypes[indexPath.section][indexPath.row]
        }
        switch celltype {
        case .Head :
            let cellId = "HeadCell"
            var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
            ZMDTool.configTableViewCellDefault(cell!)
            cell?.selectionStyle = .None
            var tag = 10001
            let imgBg = cell?.viewWithTag(tag++) as! UIImageView    //店铺背景图
            let storeLbl = cell?.viewWithTag(tag++) as! UILabel     //店铺名称
            let detailLbl = cell?.viewWithTag(tag++) as! UILabel    //主营
            let followBtn = cell?.viewWithTag(tag++) as! UIButton
            let imgHead = cell?.viewWithTag(tag++) as! UIImageView
            cell?.contentView.sendSubviewToBack(imgBg)
            ZMDTool.configViewLayerRound(imgHead)
//            imgBg.image = UIImage.colorImage(RGB(72,72,69,1))
            imgBg.image = UIImage(named: "store_home_bg")
            imgBg.userInteractionEnabled = false
            ZMDTool.configViewLayerWithSize(followBtn, size: 17)
            
            if self.storeDetail != nil {
                if let urlStr = self.storeDetail.PictureUrl,url = NSURL(string: kServerAddress + urlStr){
                    imgHead.sd_setImageWithURL(url, placeholderImage: nil)
                }
                if let text = self.storeDetail.Name {
                    storeLbl.text = text
                }
                if let text = self.storeDetail.Host {
                    detailLbl.text = text
                }
            }

            followBtn.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 12)
            followBtn.setImage(UIImage(named: "user_pingfen_selected.png"), forState: .Selected)
            followBtn.setTitle("已关注", forState: .Selected)
            //关注btn临时
            followBtn.rac_command = RACCommand(signalBlock: { (sender) -> RACSignal! in
                let btn = sender as!UIButton
                btn.selected = !btn.selected
                btn.titleLabel?.font = btn.selected ? UIFont.systemFontOfSize(14) : UIFont.systemFontOfSize(17)
                btn.titleEdgeInsets = btn.selected ? UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8) : UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
                return RACSignal.empty()
            })
            //关注btn
            /*followBtn.rac_command = RACCommand(signalBlock: { (sender) -> RACSignal! in
                QNNetworkTool.collectStores(self.storeId.integerValue,collect:!(sender as!UIButton).selected, completion: { (succeed, error, dictionary) -> Void in
                    if succeed! {
                        (sender as! UIButton).selected = !(sender as! UIButton).selected
                        (sender as!UIButton).selected == true ? ZMDTool.showPromptView("关注成功") : ZMDTool.showPromptView("已取消关注")
                    }else{
                        (sender as!UIButton).selected == true ? ZMDTool.showPromptView("取消关注失败") : ZMDTool.showPromptView("关注失败")
                    }
                })
                print("关注店铺\((sender as! UIButton).selected)")
                return RACSignal.empty()
            })*/
            return cell!
        case .Notice :
            let cellId = "NoticeCell"
            var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
            if cell == nil {
                cell = UITableViewCell(style: .Subtitle, reuseIdentifier: cellId)
                cell?.accessoryType = UITableViewCellAccessoryType.None
                cell!.selectionStyle = .None
                
                ZMDTool.configTableViewCellDefault(cell!)
                let icon = UIImageView(frame: CGRect(x: 11, y: 15, width: 16, height: 14))
                icon.image = UIImage(named: "store_notice")
                cell?.contentView.addSubview(icon)
                
                let lbl = ZMDTool.getLabel(CGRect(x: 36, y: 0, width: kScreenWidth-36-44, height: 46), text: "", fontSize: 14)
                lbl.tag = 10001
                cell?.contentView.addSubview(lbl)
                
                let detailLbl = ZMDTool.getLabel(CGRect(x: 36, y: 0, width: kScreenWidth-36-44, height: 60), text: "", fontSize: 14)
                detailLbl.tag = 10002
                cell?.contentView.addSubview(detailLbl)
                detailLbl.numberOfLines = 0
                detailLbl.hidden = true
                if self.isNoticeDetail {
                    lbl.hidden = true
                    detailLbl.hidden = false
                }
                //下部弹窗
                let downBtn = UIButton(frame: CGRect(x: kScreenWidth - 44, y: 0, width: 44, height: 45))
                downBtn.backgroundColor = UIColor.whiteColor()
                let imageName = self.isNoticeDetail ? "home_up" : "home_down"
                downBtn.setImage(UIImage(named: imageName), forState: .Normal)
                downBtn.rac_command = RACCommand(signalBlock: { (sender) -> RACSignal! in
                    (sender as!UIButton).selected = !(sender as!UIButton).selected
                    
                    self.isNoticeDetail = !self.isNoticeDetail
                    self.currentTableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: 1, inSection: 0)], withRowAnimation: UITableViewRowAnimation.None)
                    return RACSignal.empty()
                })

                cell?.contentView.addSubview(downBtn)
            }
            let lbl = cell?.viewWithTag(10001) as! UILabel
            lbl.text = "店铺公告:1、满2000减20,满1000免；垃圾上单；分类及案例；解放啦睡觉了；放假啦；数据的垃圾多死"
            let detailLbl = cell?.viewWithTag(10002) as! UILabel
            detailLbl.text = lbl.text
            //通过detailLbl.text计算出自适应的高度，返回给一个全局变量，设置heightForRow
            return cell!
        case .Discount :
            //
            let cellId = "DiscountCell"
            var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
            if cell == nil {
                cell = UITableViewCell(style: .Subtitle, reuseIdentifier: cellId)
                cell?.accessoryType = UITableViewCellAccessoryType.None
                cell!.selectionStyle = .None
                
                ZMDTool.configTableViewCellDefault(cell!)
                self.scrollView(0,cell: cell!)
            }
            return cell!
        case .Coupon :
            let cellId = "CouponCell"
            var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
            if cell == nil {
                cell = UITableViewCell(style: .Subtitle, reuseIdentifier: cellId)
                cell?.accessoryType = UITableViewCellAccessoryType.None
                cell!.selectionStyle = .None
            }
            let cycleScroll = CycleScrollView(frame: CGRectMake(12, 10, kScreenWidth-24, 260/750 * kScreenWidth-20))
            cycleScroll.backgroundColor = UIColor.blueColor()
            let image = ["home_banner01","home_banner02","home_banner03","home_banner04","home_banner05"]
            cycleScroll.imgArray = image
            //            cycleScroll.delegate = self
            cycleScroll.autoScroll = true
            cycleScroll.autoTime = 2.5
            cell?.addSubview(cycleScroll)
            return cell!
        case .Recommend :
            let cellId = "DoubleGoodsCell"
            let cell = tableView.dequeueReusableCellWithIdentifier(cellId) as! DoubleGoodsTableViewCell
            cell.goodsImgVLeft.image = UIImage(named: "home_banner02")
            cell.goodsImgVRight.image = UIImage(named: "home_banner04")
            cell.selectionStyle = .None
            let productL = self.productsArray[indexPath.row*2] as! ZMDProduct
            if indexPath.section*2+1 <= self.productsArray.count-1 {
                let productR = self.productsArray[indexPath.row*2 + 1] as! ZMDProduct
                cell.rightBtn.rac_command = RACCommand(signalBlock: { (sender) -> RACSignal! in
                    self.pushDetailVC(productR)
                    return RACSignal.empty()
                })
                DoubleGoodsTableViewCell.configCell(cell, product: productL, productR: productR)
            }else{
                DoubleGoodsTableViewCell.configCell(cell, product: productL, productR: nil)
            }
            
            cell.leftBtn.rac_command = RACCommand(signalBlock: { (sender) -> RACSignal! in
                self.pushDetailVC(productL)
                return RACSignal.empty()
            })
            return cell
            
        default :
            return UITableViewCell()
        }
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

    }
    
    //MARK: - UISearchBarDelegate
    func searchBarSearchButtonClicked(searchBar: UISearchBar)  {
        self.view.endEditing(true)
        let homeBuyListViewController = HomeBuyListViewController.CreateFromMainStoryboard() as! HomeBuyListViewController
        homeBuyListViewController.isStore = true
        homeBuyListViewController.hideSearch = true
        homeBuyListViewController.storeId = self.storeId
        homeBuyListViewController.titleForFilter = searchBar.text ?? ""
        self.navigationController?.pushViewController(homeBuyListViewController, animated: false)
        //移除灰色背景
        self.view.viewWithTag(1000)?.removeFromSuperview()
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        let btn = UIButton(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight))
        self.view.addSubview(btn)
        btn.tag = 1000
        btn.backgroundColor = defaultGrayColor
        btn.alpha = 0.2
        btn.rac_command = RACCommand(signalBlock: { (sender) -> RACSignal! in
            //移除灰色背景btn
            self.view.viewWithTag(1000)!.removeFromSuperview()
            searchBar.resignFirstResponder()
            return RACSignal.empty()
        })
    }

    //MARK: IBAction
    //进入购物车
    @IBAction func enterShoppingCar(sender: UIButton) {
        let vc = ShoppingCartViewController.CreateFromMainStoryboard() as! ShoppingCartViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    //店铺首页
    @IBAction func storeHomeBtnCli(sender: UIButton) {
        self.currentTableView.contentOffset = CGPoint(x: 0, y: 0)
    }
    //商品分类
    @IBAction func goodsSortBtnCli(sender: UIButton) {
        let vc = StoreShowGoodsSortViewController()
        vc.storeId = self.storeId.integerValue
        vc.categories = self.availableCategories//临时用
        self.navigationController?.pushViewController(vc, animated: true)
    }
    //联系卖家
    @IBAction func sellerBtnCli(sender: UIButton) {
        self.commonAlertShow(true,title: "注意:", message: "卖家联系方式为:15377679415,是否现在联系?", preferredStyle: .Alert)
    }
    //MARK: - alertDestructiveAction重写
    override func alertDestructiveAction() {
        let phone = "15377679415"
//        UIApplication.sharedApplication().openURL(NSURL(string: "tel://+\(phone)")!)  //method1
         
/*        //method2
        let str = "tel:"+phone
        let vc = MyWebViewController()
        vc.webUrl = str
        self.navigationController?.pushViewController(vc, animated: true)
*/
        let str = "telprompt://"+phone    //method3
        UIApplication.sharedApplication().openURL(NSURL(string: str)!)
    }
    
    //MARK: -  PrivateMethod
    func setupNewNavigation() {
        let searchView = UIView(frame: CGRectMake(0, 0, kScreenWidth - 120, 44))
        let searchBar = UISearchBar(frame: CGRectMake(0, 4, kScreenWidth - 120, 36))
        searchBar.tag = 1000
        searchBar.backgroundImage = UIImage.imageWithColor(UIColor.clearColor(), size: searchBar.bounds.size)
        searchBar.placeholder = "搜索店铺商品"
        searchBar.layer.borderColor = UIColor.grayColor().CGColor
        searchBar.layer.borderWidth = 0.5
        searchBar.layer.cornerRadius = 6
        searchBar.layer.masksToBounds = true
        searchBar.delegate = self
        searchView.addSubview(searchBar)
        self.navigationItem.titleView = searchView
    }
    
    func dataInit() {
        
    }
    
    //MARK: requestData
    func requestData() {
        QNNetworkTool.fetchStoreHomePages(12, pageNumber: self.indexSkip, StoreId: self.storeId.integerValue, orderBy: 0, Q: "",isNew: false) { (store, products, categories, error, dictionary) -> Void in
            if store != nil {
                self.storeDetail = store
            }
            if let products = products {
                self.productsArray.addObjectsFromArray(products as [AnyObject])
            }
            if let categories = categories {
                self.availableCategories = categories
            }
            self.currentTableView.reloadData()
        }
    }
    func scrollView(y:CGFloat,cell:UITableViewCell) {
        let scrollView = UIScrollView(frame: CGRect(x: 0, y:12, width: kScreenWidth, height: 60))
        scrollView.backgroundColor = UIColor.clearColor()
        scrollView.scrollsToTop = false
        scrollView.pagingEnabled = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.delegate = self
        scrollView.tag = kTagScrollView
        cell.contentView.addSubview(scrollView)
        
        let width = CGFloat(140)
        let spacing = CGFloat(8)
        var i = 0
        for _ in ["","",""] {
            let projectV = self.projectView((width+spacing)*CGFloat(i))
            scrollView.addSubview(projectV)
            i++
        }
        scrollView.contentSize = CGSizeMake((width+spacing)*CGFloat(i), 0)
        scrollView.bounces = true
        scrollView.contentInset = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
        scrollView.contentOffset.x = -12
    }
    func projectView(x:CGFloat) -> UIView {
        let width = CGFloat(140),height = CGFloat(60)
        let view = UIButton(frame: CGRect(x: x, y: 0, width: width, height: height))
        view.backgroundColor = RGB(250,65,120,1)
        let titleLbl = ZMDTool.getLabel(CGRect(x: 12, y: 15, width: width-24, height: 13), text: "￥5满193使用", fontSize: 13)
        view.addSubview(titleLbl)
        let detailLbl = ZMDTool.getLabel(CGRect(x: 50, y: CGRectGetMaxY(titleLbl.frame)+8, width: width-62, height: 15), text: "￥立即领取>", fontSize: 10)
        detailLbl.backgroundColor = RGB(255,252,202,1)
        ZMDTool.configViewLayerWithSize(detailLbl, size: 7)
        view.addSubview(detailLbl)
        return view
    }
    
    func pushDetailVC(product:ZMDProduct){
        let vc = HomeBuyGoodsDetailViewController.CreateFromMainStoryboard() as! HomeBuyGoodsDetailViewController
        vc.productId = product.Id.integerValue
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
