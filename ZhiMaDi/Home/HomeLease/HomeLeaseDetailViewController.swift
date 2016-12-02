//
//  HomeLeaseDetailViewController.swift
//  ZhiMaDi
//
//  Created by haijie on 16/3/28.
//  Copyright © 2016年 ZhiMaDi. All rights reserved.
//

import UIKit
import TYAttributedLabel
import MJRefresh
//租赁详请
class HomeLeaseDetailViewController:UIViewController,UITableViewDataSource,UITableViewDelegate,ZMDInterceptorProtocol,ZMDInterceptorNavigationBarShowProtocol,QNShareViewDelegate,LeasePackageViewDelegate {
    enum GoodsCellType{
        case HomeContentTypeAd                      /* 广告显示页 */
        case HomeContentTypeDetail                   /* 菜单参数栏目 */
        case HomeContentTypePackage                    /* 套餐栏目 */
        case HomeContentTypeDistribution             /* 商品配送栏目 */
        case HomeContentTypeStore                   /* 店家  */
        case HomeContentTypeNextMenu                /* 下面展示菜单 */
        init(){
            self = HomeContentTypeAd
        }
    }
    
    enum SecondTableCellType{
        case TypeImageText
        case TypeRemark
        case TypeReccomend
        init(){
            self = TypeImageText
        }
    }
    
    @IBOutlet weak var currentTableView: UITableView!
    var secondTableView: UITableView!
    var countForBounghtLbl : UIButton!               // 购买数量Lbl
    @IBOutlet weak var bottomV: UIView!
    
    var countForBounght = 0                         // 购买数量
    var goodsCellTypes: [GoodsCellType]!
    var secondCellType = SecondTableCellType.TypeImageText
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataInit()
        self.updateUI()
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        self.setupNewNavigation()
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
        if tableView == self.secondTableView {
            return 1
        }
        
        let cellType = self.goodsCellTypes[section]
        switch cellType {
        case .HomeContentTypeAd :
            return 1
        case .HomeContentTypePackage :
            return 1
        default :
            return 1
        }
    }
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if tableView == self.secondTableView {
            return 1
        }
        
        return self.goodsCellTypes.count
    }
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if tableView == self.secondTableView {
            return 10
        }
        
        let cellType = self.goodsCellTypes[section]
        switch cellType {
        case .HomeContentTypeAd :
            return 0
            
        default :
            return 16
        }
    }
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return  0
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if tableView == self.secondTableView {
            return indexPath.section == 0 ? 60 : 325
        }
        
        let cellType = self.goodsCellTypes[indexPath.section]
        switch cellType {
        case .HomeContentTypeAd :
            return kScreenWidth
        case .HomeContentTypeDetail :
            return 174
        case .HomeContentTypePackage :
            return 60
        case .HomeContentTypeDistribution :
            return 106
        case .HomeContentTypeStore :
            return 120
        case .HomeContentTypeNextMenu :
            return 60
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if tableView == self.secondTableView {
            switch secondCellType{
            case .TypeImageText:
                break
            case .TypeRemark:
                break
            default:
                break
            }
            if indexPath.section == 0 {
                return cellForHomeNextMenu(tableView, indexPath: indexPath)
            } else {
                return cellForSecond(tableView, indexPath: indexPath)
            }
        }
        
        let cellType = self.goodsCellTypes[indexPath.section]
        switch cellType {
        case .HomeContentTypeAd :
            return cellForHomeAd(tableView, indexPath: indexPath)
        case .HomeContentTypeDetail :
            return cellForHomeDetail(tableView, indexPath: indexPath)
        case .HomeContentTypePackage :
            return cellForHomeMenu(tableView, indexPath: indexPath)
        case .HomeContentTypeDistribution :
            return cellForHomeDistribution(tableView, indexPath: indexPath)
        case .HomeContentTypeStore :
            return cellForHomeStore(tableView, indexPath: indexPath)
        case .HomeContentTypeNextMenu :
            return cellForHomeNextMenu(tableView, indexPath: indexPath)
        }
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cellType = self.goodsCellTypes[indexPath.section]
        switch cellType {
        case .HomeContentTypePackage :
            self.packageViewShow()
            
            break
        default :
            break
        }
    }
    //MARK: QNShareViewDelegate
    func qnShareView(view: ShareView) -> (image: UIImage, url: String, title: String?, description: String)? {
        return (UIImage(named: "Share_Icon")!, "http://www.baidu.com", self.title ?? "", "成为喜特用户，享有更多服务!")
    }
    func present(alert: UIAlertController) -> Void {
        self.presentViewController(alert, animated: false, completion: nil)
    }
    //MARK: LeasePackageViewDelegate
    func removeBackgroundBtn() {
        //拿到灰色背景btn
        let btn = self.navigationController?.view.viewWithTag(5000) as! UIButton
        self.dismissPopupView(btn)
    }
    //MARK: -  PrivateMethod
    //MARK:
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
    
    //MARK: 广告 cell
    func cellForHomeAd(tableView: UITableView,indexPath: NSIndexPath)-> UITableViewCell {
        let cellId = "productImgCell"
        var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
        if cell == nil {
            cell = UITableViewCell(style: .Default, reuseIdentifier: cellId)
            cell!.selectionStyle = .None
            cell!.contentView.backgroundColor = UIColor.whiteColor()
            
            let cycleScroll = CycleScrollView(frame: CGRectMake(0, 0, kScreenWidth, kScreenWidth))
            cycleScroll.backgroundColor = UIColor.blueColor()
            let image = ["product_pic","product_pic"]
            cycleScroll.imgArray = image
            //            cycleScroll.delegate = self
            cycleScroll.autoScroll = true
            cycleScroll.autoTime = 2.5
            cell?.addSubview(cycleScroll)
        }
        return cell!
    }
    //MARK: 商品详请 cell
    func cellForHomeDetail(tableView: UITableView,indexPath: NSIndexPath)-> UITableViewCell {
        let cellId = "detailCell"
        var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
        if cell == nil {
            cell = UITableViewCell(style: .Default, reuseIdentifier: cellId)
            cell!.selectionStyle = .None
            cell!.contentView.backgroundColor = UIColor.whiteColor()
        }
        return cell!
    }
    //MARK: 商品套餐 cell
    func cellForHomeMenu(tableView: UITableView,indexPath: NSIndexPath)-> UITableViewCell {
        let cellId = "PackageCell"
        var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
        if cell == nil {
            cell = UITableViewCell(style: .Default, reuseIdentifier: cellId)
            cell!.selectionStyle = .None
            cell!.contentView.backgroundColor = UIColor.whiteColor()
            cell?.accessoryType = .DisclosureIndicator
            
            let label = UILabel(frame: CGRect(x: 12, y: 0, width: 200, height: 60))
            label.text = "选择套餐"
            label.textColor = defaultTextColor
            label.font = defaultSysFontWithSize(16)
            cell?.contentView.addSubview(label)
            
            let sizeTmp = "已选 套餐A/半年/1件".sizeWithFont(defaultSysFontWithSize(16), maxWidth: 300)
            let selectLbl = UILabel(frame: CGRect(x: kScreenWidth - (sizeTmp.width + 38) , y: 0, width: sizeTmp.width, height: 60))
            selectLbl.tag = 200
            selectLbl.font = defaultSysFontWithSize(16)
            selectLbl.textAlignment = .Center
            selectLbl.text = "已选 套餐A/半年/1件"
            selectLbl.textColor = defaultDetailTextColor
            cell?.contentView.addSubview(selectLbl)
        }
        return cell!
    }
    //MARK: 配送 cell HomeContentTypeDistribution
    func cellForHomeDistribution(tableView: UITableView,indexPath: NSIndexPath)-> UITableViewCell {
        let cellId = "DistributionCell"
        var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
        if cell == nil {
            cell = UITableViewCell(style: .Default, reuseIdentifier: cellId)
            cell!.selectionStyle = .None
            cell!.contentView.backgroundColor = UIColor.whiteColor()
        }
        let label = UILabel(frame: CGRect(x: 12, y: 24, width: 200, height: 17))
        label.text = "配送"
        label.textColor = defaultTextColor
        label.font = defaultSysFontWithSize(17)
        cell?.contentView.addSubview(label)
        let size = "配送".sizeWithFont(label.font, maxWidth: 100)
        let detailLbl = UILabel(frame: CGRect(x: 12 + size.width + 20, y: 24, width: kScreenWidth - (12 + size.width + 20) - 20 , height: 40))
        detailLbl.numberOfLines = 2
        detailLbl.text = "此商品由芝麻地发货"
        detailLbl.textColor = defaultTextColor
        detailLbl.font = defaultSysFontWithSize(17)
        cell?.contentView.addSubview(detailLbl)
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
        let datas = ["","","","","",""]
        if let scrollView = cell?.viewWithTag(10001) as? UIScrollView {
            var i = 0
            var scrollvWidth = CGFloat(0)
            for _ in datas {
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
                imgV.image = UIImage(named: "product_pic")
                view.addSubview(imgV)
                
                let priceLbl = UILabel(frame: CGRect(x: 0, y: 144 - 12 - 13, width: 80, height: 13))
                priceLbl.text = "原价：218.0"
                priceLbl.textColor = defaultTextColor
                priceLbl.font = defaultSysFontWithSize(12)
                view.addSubview(priceLbl)
                
                let titleLbl = UILabel(frame: CGRect(x: 0, y: 144 - 12 - 13 - 8 - 12, width: 80, height: 12))
                titleLbl.text = "家纺被"
                titleLbl.textAlignment = .Center
                titleLbl.textColor = defaultDetailTextColor
                titleLbl.font = defaultSysFontWithSize(12)
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
        return cell!
    }
    //MARK:  下一页菜单 cell
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
    func createFilterMenu() -> UIView{
        let titles = ["图文详情","评分","相关推荐"]
        let view = UIView(frame: CGRectMake(0 , 0, kScreenWidth, 60))
        for var i=0;i<titles.count;i++ {
            let btn = UIButton(frame:  CGRectMake(CGFloat(i) * kScreenWidth/3 , 0, kScreenWidth/3, 60))
            btn.backgroundColor = UIColor.clearColor()
            btn.setTitle(titles[i], forState: .Normal)
            btn.setTitle(titles[i], forState: .Normal)
            btn.setTitleColor(UIColor.blackColor(), forState: .Normal)
            btn.setTitleColor(UIColor.yellowColor(), forState: .Selected)
            btn.titleLabel?.font = UIFont.systemFontOfSize(17)
            view.addSubview(btn)
            btn.rac_signalForControlEvents(.TouchUpInside).subscribeNext({ (sender) -> Void in
            })
            if i < 2{
                let lineView = UIView(frame: CGRectMake(CGFloat(i + 1) * kScreenWidth/3, 18, 0.5, 21))
                lineView.backgroundColor = defaultLineColor
                view.addSubview(lineView)
            }
        }
        return view
    }
    func setupNewNavigation() {
    }
    
    private func dataInit(){
        self.goodsCellTypes = [.HomeContentTypeAd,.HomeContentTypeDetail,.HomeContentTypePackage,.HomeContentTypeDistribution,.HomeContentTypeStore, .HomeContentTypeNextMenu]
    }
    
    func footerRefresh(){
        UIView.animateWithDuration(0.38, animations: { () -> Void in
            var frame = self.currentTableView.frame
            self.secondTableView.frame = frame
            frame.origin = CGPoint(x: 0, y: frame.origin.y - frame.size.height)
            self.currentTableView.frame = frame
            }, completion: { (bool) -> Void in
                self.currentTableView.mj_footer.endRefreshing()
        })
    }
    // 顶部刷新
    func headerRefresh(){
        UIView.animateWithDuration(0.38, animations: { () -> Void in
            var frame = self.secondTableView.frame
            self.currentTableView.frame = frame
            frame.origin = CGPoint(x: 0, y: 64 + frame.size.height)
            self.secondTableView.frame = frame
            }, completion: { (bool) -> Void in
                self.secondTableView.mj_header.endRefreshing()
        })
    }
    func updateUI() {
        // 底部刷新
        let footer = MJRefreshAutoNormalFooter()
        // 顶部刷新
        let header = MJRefreshNormalHeader()
        footer.setRefreshingTarget(self, refreshingAction: Selector("footerRefresh"))
        header.setRefreshingTarget(self, refreshingAction: Selector("headerRefresh"))
        
        self.currentTableView.backgroundColor  = tableViewdefaultBackgroundColor
        self.currentTableView.mj_footer = footer
        
        self.bottomV.backgroundColor = RGB(247,247,247,1)
        secondTableView = UITableView(frame: CGRect(x: 0, y: CGRectGetMaxY(self.currentTableView.frame), width: kScreenWidth, height: self.currentTableView.frame.size.height))
        secondTableView.dataSource = self
        secondTableView.delegate = self
        self.view.addSubview(secondTableView)
        self.secondTableView.mj_header = header
        
        let titles = ["咨询","租赁合同","立即租赁"]
        var i = 0
        let colorsBg = [UIColor.clearColor(),UIColor.clearColor(),RGB(232,61,60,1)]
        for title in titles {
            let bottomBtn = UIButton(frame: CGRect(x: kScreenWidth/3 * CGFloat(i), y: 12, width: (kScreenWidth - 36)/3, height: 34))
            bottomBtn.setTitle(title, forState: .Normal)
            bottomBtn.titleLabel?.font = defaultSysFontWithSize(17)
            bottomBtn.backgroundColor = colorsBg[i]
            bottomBtn.tag = 1000 + i
            if i == 0 {
                bottomBtn.setTitleColor(defaultTextColor, forState: .Normal)
                bottomBtn.setImage(UIImage(named: "product_chat"), forState: .Normal)
            } else  if i == 1 {
                bottomBtn.setTitleColor(defaultTextColor, forState: .Normal)
                bottomBtn.setImage(UIImage(named: "product_contract"), forState: .Normal)
            } else {
                ZMDTool.configViewLayerWithSize(bottomBtn,size:14)
                bottomBtn.setTitleColor(UIColor.whiteColor(), forState: .Normal)
            }
            bottomBtn.rac_signalForControlEvents(.TouchUpInside).subscribeNext({ [weak self](sender) -> Void in
                if let StrongSelf = self {
                    if (sender as! UIButton).titleLabel!.text == titles[0] {
                        //咨询
                    } else if (sender as! UIButton).titleLabel?.text == titles[1] {
                        StrongSelf.contractViewShow()
                    } else if (sender as! UIButton).titleLabel?.text == titles[2] {
                        //租赁
                    }
                }
                })
            self.bottomV.addSubview(bottomBtn)
            i++
        }
    }
    //合同
    func contractViewShow(){
        let bg = UIView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight))
        bg.showAsPop()
        
        let nibView = NSBundle.mainBundle().loadNibNamed("LeaseContractView", owner: nil, options: nil) as NSArray
        let contractView = nibView.objectAtIndex(0) as? UIView
        contractView!.frame = CGRect(x: 34, y: 110, width: kScreenWidth - 68, height: kScreenHeight - 110 - 110)
        let closeBtn = contractView?.viewWithTag(10001) as! UIButton
        closeBtn.rac_signalForControlEvents(.TouchUpInside).subscribeNext { (sender) -> Void in
            contractView!.removePop()
            bg.removePop()
        }
        let selectBtn = contractView?.viewWithTag(10003) as! UIButton
        selectBtn.rac_signalForControlEvents(.TouchUpInside).subscribeNext { (sender) -> Void in
            selectBtn.selected = !selectBtn.selected
        }
        contractView?.showAsPop(setBgColor: false)
    }
    func packageViewShow() {
        let contractView = LeasePackageView.leasePackageView()
        contractView.delegate = self
        contractView.finished = {(package:String, term:String, count:Int) -> Void in
            let cell = self.currentTableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 2))
            let label = cell?.viewWithTag(200) as! UILabel
            
            label.text = "已选 \(package)/\(term)/\(count)件"
            let sizeTmp = label.text!.sizeWithFont(defaultSysFontWithSize(16), maxWidth: 300)
            label.frame = CGRect(x: kScreenWidth - (sizeTmp.width + 38) , y: 0, width: sizeTmp.width, height: 60)
        }
        contractView.frame = CGRect(x: 86, y: 0, width: kScreenWidth - 86, height: kScreenHeight)
        self.viewShowWithBgForNav(contractView,showAnimation: .SlideInFromRight,dismissAnimation: .SlideOutToRight)
    }
}
